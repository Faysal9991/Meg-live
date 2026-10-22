import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'test_helpers.dart';

String _frame(Map<String, dynamic> message) => jsonEncode({'message': message});

Map<String, dynamic> _agency(int id, int rank, int diamonds) => {
  'id': id,
  'rank': rank,
  'agent_name': 'Agency $id',
  'user_id': 0,
  'logo': null,
  'diamonds': diamonds,
  'total_hosts_diamonds': diamonds,
  'total_hosts_count': 3,
};

Map<String, dynamic> _ranked(int uid, int rank, String scoreKey, int score) => {
  'id': uid + 1000,
  'user': {'uid': uid},
  'rank': rank,
  'full_name': 'User $uid',
  'profile_image': null,
  'level': null,
  'is_host': scoreKey == 'gift_diamonds',
  'is_agent': false,
  'is_reseller': false,
  'is_moderator': false,
  scoreKey: score,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthController authController;
  late _CountingAdapter adapter;
  late LiveStreamingController controller;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    authController = _DashboardAuth();
    authController.profile.value = buildTestProfile(uid: 202);
    authController.token.value = 'test-token';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (call) async => call.method == 'getAll' ? <String, Object>{} : true,
        );
    authController.preferences = await StreamingSharedPreferences.instance;
    Get.put<AuthController>(authController);
    adapter = _CountingAdapter();
    controller = Get.put(
      LiveStreamingController(dio: Dio()..httpClientAdapter = adapter),
    );
  });

  tearDown(Get.reset);

  test('agency snapshot replaces the list in backend order', () {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_AGENCIES_UPDATE,
        'revision': 1,
        'agencies': [_agency(2, 1, 1100), _agency(1, 2, 1000)],
      }),
    );
    expect(controller.topSlidingAgentRankingList.map((a) => a['id']), [2, 1]);

    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_AGENCIES_UPDATE,
        'revision': 3,
        'agencies': [_agency(1, 1, 1000), _agency(2, 2, 900)],
      }),
    );
    expect(controller.topSlidingAgentRankingList.map((a) => a['id']), [1, 2]);
    expect(controller.isRankingLive(TOP_AGENCIES_UPDATE), isTrue);
  });

  test('older or duplicate revisions are ignored', () {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_AGENCIES_UPDATE,
        'revision': 5,
        'agencies': [_agency(1, 1, 1000)],
      }),
    );
    for (final revision in [5, 4]) {
      controller.handleDashboardSocketMessage(
        _frame({
          'type': TOP_AGENCIES_UPDATE,
          'revision': revision,
          'agencies': <dynamic>[],
        }),
      );
    }
    expect(controller.topSlidingAgentRankingList, hasLength(1));
  });

  test('empty snapshot clears the list', () {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_AGENCIES_UPDATE,
        'revision': 1,
        'agencies': [_agency(1, 1, 1000)],
      }),
    );
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_AGENCIES_UPDATE,
        'revision': 2,
        'agencies': <dynamic>[],
      }),
    );
    expect(controller.topSlidingAgentRankingList, isEmpty);
  });

  test('each ranking type keeps its own revision counter', () {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_HOSTS_UPDATE,
        'revision': 100,
        'top_hosts': [_ranked(202, 1, 'gift_diamonds', 5000)],
      }),
    );
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_CONTRIBUTORS_UPDATE,
        'revision': 50,
        'top_contributors': [_ranked(303, 1, 'diamonds_contributed', 8000)],
      }),
    );

    final host = controller.topHostList.single;
    expect(host.uid, 202);
    expect(host.rank, 1);
    expect(host.giftDiamonds, 5000);
    expect(host.level, isNull);
    final contributor = controller.topContributorList.single;
    expect(contributor.uid, 303);
    expect(contributor.diamondsContributed, 8000);
  });

  test('malformed frames are ignored without throwing', () {
    for (final frame in [
      'not json',
      jsonEncode([1, 2]),
      jsonEncode({'message': 'text'}),
      _frame({'type': TOP_HOSTS_UPDATE, 'revision': '1', 'top_hosts': []}),
      _frame({'type': TOP_HOSTS_UPDATE, 'revision': 1, 'top_hosts': {}}),
    ]) {
      controller.handleDashboardSocketMessage(frame);
    }
    expect(controller.topHostList, isEmpty);
    expect(controller.isRankingLive(TOP_HOSTS_UPDATE), isFalse);
  });

  test('socket-pushed rankings skip REST fetches', () async {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_HOSTS_UPDATE,
        'revision': 1,
        'top_hosts': [_ranked(202, 1, 'gift_diamonds', 5000)],
      }),
    );
    controller.handleDashboardSocketMessage(
      _frame({
        'type': TOP_CONTRIBUTORS_UPDATE,
        'revision': 1,
        'top_contributors': <dynamic>[],
      }),
    );

    await controller.loadTopHostList();
    await controller.loadTopContributorList();

    expect(adapter.requests, isEmpty);
  });

  test("another user's load_profile does not overwrite the profile", () {
    controller.handleDashboardSocketMessage(
      _frame({
        'type': LOAD_PROFILE,
        'user': {'uid': 101},
        'diamonds': 4500,
        'level': {'id': 1, 'level': 0, 'diamonds': 0},
      }),
    );
    expect(authController.profile.value.user?.uid, 202);
    expect(authController.profile.value.diamonds, 1000);
  });

  test('profile merge keeps nested user fields and reads purchase counter', () {
    final profile = buildTestProfile(uid: 202, phone: '01711111111');
    final merged = profile.mergedJson({
      'user': {'uid': 202},
      'diamonds': 700,
      'reseller_purchased_diamonds': 500,
      'level': {'id': 3, 'level': 2, 'diamonds': 1000},
    });
    final updated = Profile.fromJson(merged);
    expect(updated.user?.phone, '01711111111');
    expect(updated.diamonds, 700);
    expect(updated.reseller_purchased_diamonds, 500);
    expect(updated.level['level'], 2);
  });

  void pushAllRankings(int revision) {
    for (final entry in {
      TOP_AGENCIES_UPDATE: 'agencies',
      TOP_HOSTS_UPDATE: 'top_hosts',
      TOP_CONTRIBUTORS_UPDATE: 'top_contributors',
    }.entries) {
      controller.handleDashboardSocketMessage(
        _frame({'type': entry.key, 'revision': revision, entry.value: []}),
      );
    }
  }

  testWidgets('socket snapshots do not trigger ranking or room polling', (
    tester,
  ) async {
    controller.handleDashboardConnectionState(const Connected());
    expect(controller.isRankingLoading(TOP_HOSTS_UPDATE), isTrue);
    pushAllRankings(100);
    expect(controller.isRankingLoading(TOP_HOSTS_UPDATE), isFalse);
    await tester.pump(const Duration(minutes: 1));
    await controller.loadMissingRankings();
    expect(adapter.requests, isEmpty);
  });

  testWidgets('reconnect accepts fresh revisions without ranking API calls', (
    tester,
  ) async {
    controller.handleDashboardConnectionState(const Connected());
    pushAllRankings(100);
    controller.handleDashboardConnectionState(const Reconnecting());
    expect(controller.isStreamingWebSocketConnected.value, isFalse);
    expect(controller.isRankingReconnecting(TOP_HOSTS_UPDATE), isTrue);

    controller.handleDashboardConnectionState(const Reconnected());
    expect(controller.isRankingLoading(TOP_HOSTS_UPDATE), isTrue);
    expect(controller.isRankingReconnecting(TOP_HOSTS_UPDATE), isTrue);
    pushAllRankings(1);
    await tester.pump();
    await tester.pump(const Duration(minutes: 1));
    expect(controller.isRankingLive(TOP_HOSTS_UPDATE), isTrue);
    expect(controller.isRankingReconnecting(TOP_HOSTS_UPDATE), isFalse);
    expect(
      adapter.requests.map((request) => request.path),
      unorderedEquals([kProfileRetrieveUrl(202), kLiveRoomListUrl]),
    );
  });

  testWidgets('legacy backend gets one fallback per ranking per session', (
    tester,
  ) async {
    controller.handleDashboardConnectionState(const Connected());
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();
    final rankingPaths = [
      kManualAgentListUrl,
      kTopHostListUrl,
      kTopContributorListUrl,
    ];
    expect(
      adapter.requests.map((request) => request.path),
      unorderedEquals(rankingPaths),
    );
    controller.handleDashboardConnectionState(const Reconnecting());
    controller.handleDashboardConnectionState(const Reconnected());
    await tester.pump(const Duration(minutes: 1));
    await controller.loadMissingRankings();
    await tester.pump();
    for (final path in rankingPaths) {
      expect(
        adapter.requests.where((request) => request.path == path),
        hasLength(1),
      );
    }
  });

  test(
    'concurrent resume/reconnect recovery shares profile and room requests',
    () async {
      adapter.barrier = Completer<void>();
      final first = controller.recoverDashboardState();
      final second = controller.recoverDashboardState();
      await adapter.waitForRequests(2);
      expect(adapter.requests, hasLength(2));
      adapter.barrier!.complete();
      await Future.wait([first, second]);
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'server profile applies lower and null levels without local progress',
    () {
      controller.viewers.assignAll([
        {
          'uid': 202,
          'level': {'level': 1},
        },
        {
          'uid': 303,
          'level': {'level': 7},
        },
      ]);
      controller.handleDashboardSocketMessage(
        _frame({
          'type': LOAD_PROFILE,
          'user': {'uid': 202},
          'diamonds': 700,
          'reseller_purchased_diamonds': 500,
          'level': {'level': 0},
        }),
      );
      expect(authController.profile.value.level['level'], 0);
      expect(authController.profile.value.diamonds, 700);
      expect(authController.profile.value.reseller_purchased_diamonds, 500);
      expect(authController.profile.value.user?.phone, '01700000000');
      expect(controller.viewers.first['level']['level'], 0);
      expect(controller.viewers.last['level']['level'], 7);
      controller.handleDashboardSocketMessage(
        _frame({
          'type': LOAD_PROFILE,
          'user': {'uid': 202},
          'level': null,
        }),
      );
      expect(authController.profile.value.level, isNull);
      expect(controller.viewers.first['level'], isNull);
      expect(authController.profile.value.diamonds, 700);
    },
  );

  test('late REST profile cannot overwrite a newer socket profile', () async {
    adapter.barrier = Completer<void>();
    final recovery = controller.refreshLoggedInProfile();
    await adapter.waitForRequests(1);
    controller.handleDashboardSocketMessage(
      _frame({
        'type': LOAD_PROFILE,
        'user': {'uid': 202},
        'diamonds': 777,
      }),
    );
    adapter.barrier!.complete();
    await recovery;
    expect(authController.profile.value.diamonds, 777);
  });

  testWidgets(
    'exhausted transport retries restart the socket without polling',
    (tester) async {
      final sockets = <_FakeSocket>[];
      final socketController = LiveStreamingController(
        dio: Dio()..httpClientAdapter = adapter,
        dashboardSocketFactory: (_, _) {
          final socket = _FakeSocket();
          sockets.add(socket);
          return socket;
        },
      );
      await socketController.initWebSocketClient();
      await sockets.single._connection.controller.close();
      await tester.pump(const Duration(seconds: 29));
      expect(sockets, hasLength(1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(sockets, hasLength(2));
      expect(sockets.first.closed, isTrue);
      expect(adapter.requests, isEmpty);
      socketController.onClose();
      for (final socket in sockets) {
        await socket.dispose();
      }
    },
  );

  test(
    'concurrent socket starts share the device lookup and one transport',
    () async {
      final auth = authController as _DashboardAuth;
      auth.deviceLookup = Completer<String>();
      final sockets = <_FakeSocket>[];
      final socketController = LiveStreamingController(
        dashboardSocketFactory: (uri, backoff) {
          expect(uri.query, '202');
          final socket = _FakeSocket();
          sockets.add(socket);
          return socket;
        },
      );
      final first = socketController.initWebSocketClient();
      final second = socketController.initWebSocketClient();
      expect(auth.deviceLookups, 1);
      auth.deviceLookup!.complete('device-id');
      await Future.wait([first, second]);
      expect(sockets, hasLength(1));
      socketController.onClose();
      expect(sockets.single.closed, isTrue);
      await sockets.single.dispose();
    },
  );

  test(
    'controller disposal during device lookup cannot open a late socket',
    () async {
      final auth = authController as _DashboardAuth;
      auth.deviceLookup = Completer<String>();
      var created = 0;
      final socketController = LiveStreamingController(
        dashboardSocketFactory: (_, _) {
          created++;
          return _FakeSocket();
        },
      );
      final initialization = socketController.initWebSocketClient();
      socketController.onClose();
      auth.deviceLookup!.complete('device-id');
      await initialization;
      expect(created, 0);
    },
  );

  test(
    'logout clears dashboard state and ignores an in-flight profile',
    () async {
      pushAllRankings(100);
      adapter.barrier = Completer<void>();
      final recovery = controller.refreshLoggedInProfile();
      await adapter.waitForRequests(1);
      authController.token.value = '';
      authController.profile.value = Profile();
      await Future<void>.delayed(Duration.zero);
      adapter.barrier!.complete();
      await recovery;
      expect(authController.profile.value.user, isNull);
      expect(controller.liveRankingTypes, isEmpty);
      expect(controller.topHostList, isEmpty);
      expect(controller.listLiveRoom, isEmpty);
    },
  );

  Map<String, dynamic> room(int id, {int viewers = 1}) => {
    'channel_id': id,
    'type': STREAMING,
    'viewers_count': viewers,
    'owner_profile': {'uid': id, 'blocks': []},
  };

  test('consecutive room events update the feed without REST requests', () {
    controller.handleDashboardSocketMessage(_frame(room(1)));
    controller.handleDashboardSocketMessage(_frame(room(2)));
    controller.handleDashboardSocketMessage(
      _frame({
        'type': UPDATE_VIEWERS_COUNT,
        'channel_id': 1,
        'viewers_count': 5,
      }),
    );
    expect(controller.listFilterLiveStreams.map((room) => room['channel_id']), [
      1,
      2,
    ]);
    expect(controller.listFilterLiveStreams.first['viewers_count'], 5);
    controller.handleDashboardSocketMessage(
      _frame({'type': DELETE_LIVE, 'channel_id': 1}),
    );
    expect(controller.listFilterLiveStreams.single['channel_id'], 2);
    expect(adapter.requests, isEmpty);
  });

  test(
    'late room snapshot preserves newer socket additions and removals',
    () async {
      adapter.barrier = Completer<void>();
      adapter.responses[kLiveRoomListUrl] = {
        'live_room_list': [room(1)],
      };
      final recovery = controller.tryToLoadLiveRoomList();
      await adapter.waitForRequests(1);
      controller.handleDashboardSocketMessage(_frame(room(2, viewers: 5)));
      controller.handleDashboardSocketMessage(
        _frame({'type': DELETE_LIVE, 'channel_id': 1}),
      );
      adapter.barrier!.complete();
      await recovery;
      expect(controller.listFilterLiveStreams.single['channel_id'], 2);
      expect(controller.listFilterLiveStreams.single['viewers_count'], 5);
    },
  );
}

class _DashboardAuth extends TestAuthController {
  Completer<String>? deviceLookup;
  int deviceLookups = 0;

  @override
  Future<String> getUniqueDeviceId() {
    deviceLookups++;
    return deviceLookup?.future ?? Future.value('test-device');
  }
}

class _FakeSocket implements WebSocket {
  final _messages = StreamController<dynamic>.broadcast();
  final _connection = _FakeConnection();
  bool closed = false;

  @override
  Stream<dynamic> get messages => _messages.stream;

  @override
  Connection get connection => _connection;

  @override
  void close([int? code, String? reason]) => closed = true;

  Future<void> dispose() async {
    await _messages.close();
    await _connection.controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConnection extends Stream<ConnectionState> implements Connection {
  final controller = StreamController<ConnectionState>.broadcast();

  @override
  ConnectionState get state => const Connecting();

  @override
  StreamSubscription<ConnectionState> listen(
    void Function(ConnectionState)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => controller.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

class _CountingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Map<String, dynamic> responses = {};
  Completer<void>? barrier;
  final Map<int, Completer<void>> _requestWaiters = {};

  Future<void> waitForRequests(int count) => requests.length >= count
      ? Future.value()
      : _requestWaiters.putIfAbsent(count, () => Completer<void>()).future;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    for (final entry in _requestWaiters.entries) {
      if (requests.length >= entry.key && !entry.value.isCompleted) {
        entry.value.complete();
      }
    }
    if (barrier != null) await barrier!.future;
    return ResponseBody.fromString(
      jsonEncode(
        responses[options.path] ??
            {
              'top_hosts': [],
              'top_contributors': [],
              'manual_agent_list': [],
              'live_room_list': [],
              'profile': {
                'user': {'uid': 202},
                'diamonds': 1000,
              },
            },
      ),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
