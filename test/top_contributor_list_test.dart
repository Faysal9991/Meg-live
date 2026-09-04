import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);
  });

  tearDown(Get.reset);

  test('loads and parses the top contributor list', () async {
    final adapter = _TopContributorAdapter();
    final controller = LiveStreamingController(
      dio: Dio()..httpClientAdapter = adapter,
    );

    await controller.loadTopContributorList();

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.path, kTopContributorListUrl);
    expect(controller.loadingTopContributorList.value, isFalse);
    expect(controller.topContributorList, hasLength(1));
    expect(controller.topContributorList.single.uid, 101);
    expect(controller.topContributorList.single.fullName, 'Top Supporter');
    expect(controller.topContributorList.single.seconds, 7200);
  });

  test('accepts the top host envelope for a matching response shape', () async {
    final adapter = _TopContributorAdapter(useTopHostEnvelope: true);
    final controller = LiveStreamingController(
      dio: Dio()..httpClientAdapter = adapter,
    );

    await controller.loadTopContributorList();

    expect(controller.topContributorList.single.fullName, 'Top Supporter');
  });
}

class _TopContributorAdapter implements HttpClientAdapter {
  _TopContributorAdapter({this.useTopHostEnvelope = false});

  final bool useTopHostEnvelope;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final key = useTopHostEnvelope ? 'top_hosts' : 'top_contributors';
    return ResponseBody.fromString(
      jsonEncode({
        key: [
          {
            'uid': 101,
            'level': {'level': 8},
            'vvip_or_vip_preference': <String, dynamic>{},
            'full_name': 'Top Supporter',
            'profile_image': null,
            'seconds': 7200,
            'is_agent': false,
            'is_reseller': false,
            'is_host': false,
            'is_moderator': false,
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
