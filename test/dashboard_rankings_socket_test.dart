import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

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
  late AuthController authController;
  late _CountingAdapter adapter;
  late LiveStreamingController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    authController = TestAuthController();
    authController.profile.value = buildTestProfile(uid: 202);
    Get.put<AuthController>(authController);
    adapter = _CountingAdapter();
    controller = LiveStreamingController(
      dio: Dio()..httpClientAdapter = adapter,
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
}

class _CountingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'top_hosts': [], 'top_contributors': []}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
