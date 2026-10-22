import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'test_helpers.dart';

Map<String, dynamic> _profile(int uid, int balance, dynamic level) => {
  'user': {'uid': uid},
  'diamonds': balance,
  'level': level,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestAuthController auth;
  late _Profiles profiles;
  late _RechargeAdapter backend;
  late BusinessController controller;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    auth = TestAuthController();
    auth.profile.value = buildTestProfile(uid: 101);
    auth.token.value = 'reseller-token';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (call) async => call.method == 'getAll' ? <String, Object>{} : true,
        );
    auth.preferences = await StreamingSharedPreferences.instance;
    Get.put<AuthController>(auth);
    profiles = _Profiles();
    profiles.searchedProfile.value = _profile(202, 100, {'level': 1});
    Get.put<ProfileController>(profiles);
    backend = _RechargeAdapter();
    controller = BusinessController(dio: Dio()..httpClientAdapter = backend);
  });

  tearDown(Get.reset);

  Future<void> open(WidgetTester tester) => tester.pumpWidget(
    GetMaterialApp(
      home: const Scaffold(body: SizedBox()),
      getPages: [
        GetPage(
          name: Routes.AUTH,
          page: () => const Scaffold(body: Text('Sign in')),
        ),
      ],
    ),
  );

  Future<void> finish(WidgetTester tester, Future<void> recharge) async {
    var completed = false;
    recharge.whenComplete(() => completed = true);
    for (var frame = 0; frame < 30 && !completed; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(
      completed,
      isTrue,
      reason: 'Recharge did not finish after pending work ran',
    );
    await recharge;
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets(
    '201 updates the reseller and buyer using their own server profiles',
    (tester) async {
      await open(tester);
      await finish(
        tester,
        controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 50),
      );
      expect(auth.profile.value.user?.uid, 101);
      expect(auth.profile.value.diamonds, 900);
      expect(auth.profile.value.level['level'], 0);
      expect(auth.profile.value.user?.phone, '01700000000');
      expect(profiles.searchedProfile['user']['uid'], 202);
      expect(profiles.searchedProfile['diamonds'], 777);
      expect(profiles.searchedProfile['level']['level'], 3);
      expect(profiles.searchedProfile['reseller_purchased_diamonds'], 500);
      expect(backend.requests.single.data, {
        'customer_id': 202,
        'diamonds': 50,
      });
      expect(
        backend.requests.single.headers['Authorization'],
        'Token reseller-token',
      );
      expect(controller.resellerRechargeHistoryList, hasLength(1));
    },
  );

  testWidgets(
    'older backend recovers the buyer instead of adding coins locally',
    (tester) async {
      await open(tester);
      backend.response.remove('customer_profile');
      profiles.responses[202] = _profile(202, 321, null);
      await finish(
        tester,
        controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 50),
      );
      expect(profiles.fetched, [202]);
      expect(profiles.searchedProfile['diamonds'], 321);
      expect(profiles.searchedProfile['level'], isNull);
    },
  );

  testWidgets('204 leaves wallets, levels and history unchanged', (
    tester,
  ) async {
    await open(tester);
    backend.status = 204;
    await finish(
      tester,
      controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 50),
    );
    expect(auth.profile.value.diamonds, 1000);
    expect(auth.profile.value.level['level'], 1);
    expect(profiles.searchedProfile['diamonds'], 100);
    expect(controller.resellerRechargeHistoryList, isEmpty);
  });

  testWidgets('duplicate submission while pending sends one transfer', (
    tester,
  ) async {
    await open(tester);
    backend.transferGate = Completer<void>();
    final first = controller.tryToRechargeResellerToClient(
      customerId: 202,
      diamonds: 50,
    );
    final duplicate = controller.tryToRechargeResellerToClient(
      customerId: 202,
      diamonds: 50,
    );
    for (var frame = 0; frame < 30 && backend.requests.isEmpty; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(backend.requests, hasLength(1));
    expect(controller.loadingResellerRecharge.value, isTrue);
    backend.transferGate!.complete();
    await finish(tester, Future.wait([first, duplicate]).then((_) {}));
    expect(backend.requests, hasLength(1));
  });

  testWidgets(
    'uncertain transfer recovers profiles and history without retrying POST',
    (tester) async {
      await open(tester);
      backend.failTransfer = true;
      profiles.responses[101] = _profile(101, 940, {'level': 0});
      profiles.responses[202] = _profile(202, 444, {'level': 2});
      await finish(
        tester,
        controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 50),
      );
      expect(
        backend.requests.where((request) => request.method == 'POST'),
        hasLength(1),
      );
      expect(
        backend.requests.where(
          (request) => request.path == kResellerRechargeHistoryListUrl,
        ),
        hasLength(1),
      );
      expect(profiles.fetched, [101, 202]);
      expect(auth.profile.value.diamonds, 940);
      expect(profiles.searchedProfile['diamonds'], 444);
      expect(controller.loadingResellerRecharge.value, isFalse);
    },
  );

  testWidgets('invalid input never submits a transfer', (tester) async {
    await open(tester);
    await finish(
      tester,
      controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 0),
    );
    expect(backend.requests, isEmpty);
    expect(auth.profile.value.diamonds, 1000);
  });

  testWidgets('401 clears the expired session and opens login', (tester) async {
    await open(tester);
    backend.status = 401;
    await finish(
      tester,
      controller.tryToRechargeResellerToClient(customerId: 202, diamonds: 50),
    );
    expect(auth.token.value, isEmpty);
    expect(auth.profile.value.user, isNull);
    expect(find.text('Sign in'), findsOneWidget);
    expect(controller.resellerRechargeHistoryList, isEmpty);
  });
}

class _Profiles extends ProfileController {
  final fetched = <int>[];
  final responses = <int, Map<String, dynamic>>{};

  @override
  Future<dynamic> fetchProfile({required int userId}) async {
    fetched.add(userId);
    return responses[userId];
  }
}

class _RechargeAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 201;
  bool failTransfer = false;
  Completer<void>? transferGate;
  final response = <String, dynamic>{
    'reseller_history': {'id': 91},
    'reseller_profile': _profile(101, 900, {'level': 0}),
    'customer_profile': {
      ..._profile(202, 777, {'level': 3}),
      'reseller_purchased_diamonds': 500,
    },
  };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final transfer = options.path == kResellerRechargeCreateUrl;
    if (transferGate != null && transfer) await transferGate!.future;
    if (transfer && failTransfer) {
      throw DioException.connectionTimeout(
        requestOptions: options,
        timeout: const Duration(seconds: 30),
      );
    }
    return ResponseBody.fromString(
      jsonEncode(transfer ? response : {'reseller_histories': []}),
      transfer ? status : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
