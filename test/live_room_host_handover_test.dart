import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/live_room_update_api.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

const _hostA = 101;
const _hostB = 202;

Map<String, dynamic> _room({required int hostId}) => {
  'channel_id': _hostA,
  'current_host_id': hostId,
  'engine': 'engine_1',
  'created_datetime': '2026-10-16T10:00:00Z',
  'viewers_count': 1,
  'owner_profile': {'uid': hostId, 'full_name': 'Host $hostId', 'blocks': []},
};

void main() {
  group('liveRoomHostId', () {
    test('prefers current_host_id after a handover', () {
      expect(liveRoomHostId(_room(hostId: _hostB)), _hostB);
    });

    test('falls back to channel_id for older cached rooms', () {
      expect(liveRoomHostId({'channel_id': _hostA}), _hostA);
      expect(liveRoomHostId({'channel_id': '$_hostA'}), _hostA);
      expect(liveRoomHostId(null), isNull);
    });
  });

  group('LiveRoomTransferResult', () {
    test('maps documented status codes', () {
      final expected = {
        200: LiveRoomTransferStatus.success,
        400: LiveRoomTransferStatus.invalidRequest,
        401: LiveRoomTransferStatus.unauthorized,
        403: LiveRoomTransferStatus.notCurrentHost,
        404: LiveRoomTransferStatus.notFound,
        409: LiveRoomTransferStatus.conflict,
        418: LiveRoomTransferStatus.failed,
      };
      expected.forEach((code, status) {
        expect(
          LiveRoomTransferResult.fromResponse(statusCode: code).status,
          status,
        );
      });
    });

    test('exposes the room on success and detail on error', () {
      final ok = LiveRoomTransferResult.fromResponse(
        statusCode: 200,
        data: _room(hostId: _hostB),
      );
      expect(liveRoomHostId(ok.room), _hostB);

      final denied = LiveRoomTransferResult.fromResponse(
        statusCode: 403,
        data: {'detail': 'Only the current host can transfer this live.'},
      );
      expect(denied.room, isNull);
      expect(denied.detail, 'Only the current host can transfer this live.');
    });

    test('end-live 403 detail is surfaced', () {
      final result = LiveRoomUpdateResult.fromResponse(
        statusCode: 403,
        data: {'detail': 'Only the current host can end this live.'},
      );
      expect(result.isForbidden, isTrue);
      expect(result.error, 'Only the current host can end this live.');
    });
  });

  group('live room API', () {
    test('end live sends the login token and documented payload', () async {
      final adapter = _Adapter()..respond(kLiveRoomUpdateUrl, 200, '');
      final result = await sendLiveRoomUpdateRequest(
        dio: Dio()..httpClientAdapter = adapter,
        request: LiveRoomUpdateRequest.deleteLiveRoom(channelId: _hostA),
        authToken: 'login-token',
      );

      final request = adapter.requests.single;
      expect(result.isSuccess, isTrue);
      expect(request.method, 'PUT');
      expect(request.headers['Authorization'], 'Token login-token');
      expect(request.data, {
        'action': 'delete_live_room',
        'channel_id': _hostA,
      });
    });

    test('omits an empty Authorization header', () async {
      final adapter = _Adapter()..respond(kLiveRoomUpdateUrl, 200, '');
      await sendLiveRoomUpdateRequest(
        dio: Dio()..httpClientAdapter = adapter,
        request: LiveRoomUpdateRequest.heartbeat(channelId: _hostA),
        authToken: '',
      );
      expect(adapter.requests.single.headers, isNot(contains('Authorization')));
    });

    test('transfer posts channel and new host with the host token', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomTransferHostUrl, 200, _room(hostId: _hostB));
      final result = await sendLiveRoomTransferHostRequest(
        dio: Dio()..httpClientAdapter = adapter,
        channelId: _hostA,
        newHostId: _hostB,
        authToken: 'host-a-token',
      );

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, kLiveRoomTransferHostUrl);
      expect(request.headers['Authorization'], 'Token host-a-token');
      expect(request.data, {'channel_id': _hostA, 'new_host_id': _hostB});
      expect(result.isSuccess, isTrue);
      expect(liveRoomHostId(result.room), _hostB);
    });

    test('transfer reports 409 with detail', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomTransferHostUrl, 409, {
          'detail': 'Replacement is not connected.',
        });
      final result = await sendLiveRoomTransferHostRequest(
        dio: Dio()..httpClientAdapter = adapter,
        channelId: _hostA,
        newHostId: _hostB,
        authToken: 'host-a-token',
      );
      expect(result.status, LiveRoomTransferStatus.conflict);
      expect(result.detail, 'Replacement is not connected.');
    });

    test('a lost response is uncertain, not a failure', () async {
      final adapter = _Adapter()..failNetwork(kLiveRoomTransferHostUrl);
      final result = await sendLiveRoomTransferHostRequest(
        dio: Dio()..httpClientAdapter = adapter,
        channelId: _hostA,
        newHostId: _hostB,
        authToken: 'host-a-token',
      );
      expect(result.status, LiveRoomTransferStatus.uncertain);
    });
  });

  group('LiveStreamingController host handover', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
      final authController = TestAuthController();
      authController.profile.value = buildTestProfile(uid: _hostA);
      authController.token.value = 'host-a-token';
      Get.put<AuthController>(authController);
    });

    tearDown(Get.reset);

    LiveStreamingController hostController(_Adapter adapter) {
      final controller = LiveStreamingController(
        dio: Dio()..httpClientAdapter = adapter,
      );
      controller.setBroadcastStreamingStuffs(
        brdchannelName: '$_hostA',
        broadcasterName: 'Host A',
        brdImage: null,
        isBrdOwner: true,
        activeInCalls: [],
        brdViewers: [],
        brdFollowers: [],
        brdBlocks: [],
        brdDiamonds: 0,
        brdLoveReacts: 0,
        brdLevel: null,
      );
      return controller;
    }

    test('successful transfer makes the old host a participant', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomTransferHostUrl, 200, _room(hostId: _hostB));
      final controller = hostController(adapter);
      expect(controller.isCurrentHost, isTrue);

      final result = await controller.transferLiveHost(newHostId: _hostB);

      expect(result.isSuccess, isTrue);
      expect(controller.currentHostId.value, _hostB);
      expect(controller.isCurrentHost, isFalse);
      expect(controller.isBroadcaster.value, isFalse);
      expect(controller.channelName.value, '$_hostA');
      expect(controller.transferringHost.value, isFalse);
    });

    test('timeout is resolved from the room list before leaving', () async {
      final adapter = _Adapter()
        ..failNetwork(kLiveRoomTransferHostUrl)
        ..respond(kLiveRoomListUrl, 200, {
          'live_room_list': [_room(hostId: _hostB)],
        });
      final controller = hostController(adapter);

      final result = await controller.transferLiveHost(newHostId: _hostB);

      expect(result.isSuccess, isTrue);
      expect(controller.currentHostId.value, _hostB);
    });

    test('timeout with unchanged host keeps the caller as host', () async {
      final adapter = _Adapter()
        ..failNetwork(kLiveRoomTransferHostUrl)
        ..respond(kLiveRoomListUrl, 200, {
          'live_room_list': [_room(hostId: _hostA)],
        });
      final controller = hostController(adapter);

      final result = await controller.transferLiveHost(newHostId: _hostB);

      expect(result.isSuccess, isFalse);
      expect(controller.isCurrentHost, isTrue);
    });

    test('a failed transfer keeps the current host', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomTransferHostUrl, 409, {'detail': 'Not connected'});
      final controller = hostController(adapter);

      final result = await controller.transferLiveHost(newHostId: _hostB);

      expect(result.status, LiveRoomTransferStatus.conflict);
      expect(controller.currentHostId.value, _hostA);
      expect(controller.isCurrentHost, isTrue);
    });

    test('room list current_host_id updates the active room host', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomListUrl, 200, {
          'live_room_list': [_room(hostId: _hostB)],
        });
      final controller = hostController(adapter);

      await controller.tryToLoadLiveRoomList();

      expect(controller.currentHostId.value, _hostB);
      expect(controller.listLiveRoom, hasLength(1));
    });

    test('former host cannot start a live on a handed-over channel', () async {
      final adapter = _Adapter()
        ..respond(kLiveRoomListUrl, 200, {
          'live_room_list': [_room(hostId: _hostB)],
        });
      final controller = hostController(adapter);
      await controller.tryToLoadLiveRoomList();

      expect(controller.handedOverLiveRoom(_hostA), isNotNull);
      expect(controller.handedOverLiveRoom(_hostB), isNull);
    });
  });
}

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Map<String, (int, Object)> _responses = {};
  final Set<String> _networkFailures = {};

  void respond(String url, int statusCode, Object body) =>
      _responses[url] = (statusCode, body);

  void failNetwork(String url) => _networkFailures.add(url);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_networkFailures.contains(options.path)) {
      throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 15),
        requestOptions: options,
      );
    }
    final (statusCode, body) = _responses[options.path] ?? (404, '');
    return ResponseBody.fromString(
      body is String ? body : jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
