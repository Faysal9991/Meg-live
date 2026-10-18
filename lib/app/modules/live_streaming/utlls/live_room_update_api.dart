import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

Map<String, String> _liveRoomHeaders(String? authToken) => {
  'accept': '*/*',
  'X-Api-Key': DRF_API_KEY,
  // DRF rejects a bare "Token " header, so only send a real login token.
  if (authToken != null && authToken.isNotEmpty)
    'Authorization': 'Token $authToken',
};

/// [authToken] is the caller's login token. The backend requires the current
/// host's token for `delete_live_room`.
Future<LiveRoomUpdateResult> sendLiveRoomUpdateRequest({
  required Dio dio,
  required LiveRoomUpdateRequest request,
  String? authToken,
}) async {
  final client = configureApiDio(dio);
  final response = await client.put(
    kLiveRoomUpdateUrl,
    options: Options(
      headers: _liveRoomHeaders(authToken),
      validateStatus: (status) => status != null && status < 500,
    ),
    data: request.toJson(),
  );
  return LiveRoomUpdateResult.fromResponse(
    statusCode: response.statusCode ?? 500,
    data: response.data,
  );
}

/// Hands the live over to [newHostId], who must already be connected to the
/// same LiveKit room. Only the current host's [authToken] is accepted.
Future<LiveRoomTransferResult> sendLiveRoomTransferHostRequest({
  required Dio dio,
  required int channelId,
  required int newHostId,
  required String authToken,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final client = configureApiDio(dio);
  try {
    final response = await client.post(
      kLiveRoomTransferHostUrl,
      options: Options(
        headers: {
          ..._liveRoomHeaders(authToken),
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      ),
      data: {'channel_id': channelId, 'new_host_id': newHostId},
    );
    return LiveRoomTransferResult.fromResponse(
      statusCode: response.statusCode ?? 500,
      data: response.data,
    );
  } on DioException catch (error) {
    final response = error.response;
    if (response != null) {
      return LiveRoomTransferResult.fromResponse(
        statusCode: response.statusCode ?? 500,
        data: response.data,
      );
    }
    // The request may have reached the server; callers must reconcile.
    return const LiveRoomTransferResult(
      status: LiveRoomTransferStatus.uncertain,
    );
  }
}
