import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import 'test_helpers.dart';

class _LiveController extends LiveStreamingController {
  @override
  Future<dynamic> createLiveKitToken({required String channelName}) async =>
      null;

  @override
  void fetchGiftList() {}

  @override
  void loadContributionRankingList({required int userId}) {}
}

class _PackageController extends VVIPorVipPackageController {
  @override
  Future<void> ensureKingPackageCatalogLoaded() async {}
}

class _Participant extends Fake implements RemoteParticipant {
  @override
  bool get isSpeaking => false;
  @override
  String get name => 'Connected host';
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    final auth = TestAuthController()..profile.value = buildTestProfile();
    Get.put<AuthController>(auth);
    Get.put<LiveStreamingController>(
      _LiveController()..channelName.value = '100',
    );
    Get.put<VVIPorVipPackageController>(_PackageController());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => call.method == 'requestPermissions'
              ? {for (final permission in call.arguments as List) permission: 1}
              : 1,
        );
  });
  tearDown(() async {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });

  testWidgets(
    'a participant present on the first frame needs no late screen dimensions',
    (tester) async {
      Get.find<LiveStreamingController>().listRenderView.add(
        ParticipantTrack(
          participant: _Participant(),
          videoTrack: null,
          isScreenShare: false,
        ),
      );
      await tester.pumpWidget(
        NeumorphicTheme(
          theme: AppTheme.neumorphicTheme,
          child: GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const LiveStreamingView(
              channelName: '100',
              isBroadcaster: false,
              followers: [],
              blocks: [],
              level: null,
              vVipOrVipPreference: {'vvip_or_vip_preference': null},
              fullName: 'Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Connected host'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('live room remains usable when opening and dismissing controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      NeumorphicTheme(
        theme: AppTheme.neumorphicTheme,
        child: GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Text('Room list')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Get.to(
      () => const LiveStreamingView(
        channelName: '100',
        isBroadcaster: false,
        followers: [],
        blocks: [],
        level: {'level': 1},
        vVipOrVipPreference: {},
        fullName: 'Host',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Do you wanna close?'), findsOneWidget);
    Navigator.of(tester.element(find.text('Do you wanna close?'))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(LiveStreamingView), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('VIEWS'), findsOneWidget);
    await tester.tap(find.text('WAITING'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('WAITING'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    'assets/others/gift.png',
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('SEND GIFTS'), findsOneWidget);
    Navigator.of(tester.element(find.text('SEND GIFTS'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    final confirm = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'OK'))
        .onPressed!;
    confirm();
    confirm(); // A second close event must not pop the room list.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Room list'), findsOneWidget);
    expect(find.byType(LiveStreamingView), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
