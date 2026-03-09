import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('heartbeat request serializes correctly', () {
    final request = LiveRoomUpdateRequest.heartbeat(channelId: 565);

    expect(request.toJson(), {'action': 'heartbeat', 'channel_id': 565});
  });

  test('not found response is exposed through result model', () {
    final result = LiveRoomUpdateResult.fromResponse(
      statusCode: 404,
      data: {'error': 'No live room found'},
    );

    expect(result.isNotFound, isTrue);
    expect(result.error, 'No live room found');
  });
}
