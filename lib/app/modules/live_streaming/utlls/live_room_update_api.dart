import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

Future<LiveRoomUpdateResult> sendLiveRoomUpdateRequest({
  required Dio dio,
  required LiveRoomUpdateRequest request,
}) async {
  final body = request.toJson();
  ApiLogger.hit(method: 'PUT', url: kLiveRoomUpdateUrl, body: body);
  try {
    final response = await dio.put(
    
      kLiveRoomUpdateUrl,
      options: Options(
        headers: {'accept': '*/*', 'X-Api-Key': DRF_API_KEY},
        validateStatus: (status) => status != null && status < 500,
      ),
      data: body,
    );
    ApiLogger.response(
      method: 'PUT',
      url: kLiveRoomUpdateUrl,
      statusCode: response.statusCode,
      data: response.data,
    );

    return LiveRoomUpdateResult.fromResponse(
      statusCode: response.statusCode ?? 500,
      data: response.data,
    );
  } catch (error, stackTrace) {
    ApiLogger.error(
      method: 'PUT',
      url: kLiveRoomUpdateUrl,
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
 
  }
}
