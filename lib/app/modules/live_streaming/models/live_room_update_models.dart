import 'package:doyel_live/app/utils/model_parsers.dart';

class LiveRoomUpdateRequest {
  LiveRoomUpdateRequest._(this._payload);

  final Map<String, dynamic> _payload;

  factory LiveRoomUpdateRequest.fromMap(Map<String, dynamic> payload) {
    return LiveRoomUpdateRequest._(Map<String, dynamic>.from(payload));
  }

  factory LiveRoomUpdateRequest.addLiveRoom(Map<String, dynamic> liveData) {
    final payload = Map<String, dynamic>.from(liveData);
    payload['action'] = 'add_live_room';
    return LiveRoomUpdateRequest._(payload);
  }

  factory LiveRoomUpdateRequest.heartbeat({required int channelId}) {
    return LiveRoomUpdateRequest._({
      'action': 'heartbeat',
      'channel_id': channelId,
    });
  }

  factory LiveRoomUpdateRequest.updateViewersCount({
    required int channelId,
    required int viewersCount,
  }) {
    return LiveRoomUpdateRequest._({
      'action': 'update_viewers_count',
      'channel_id': channelId,
      'viewers_count': viewersCount,
    });
  }

  factory LiveRoomUpdateRequest.deleteLiveRoom({required int channelId}) {
    return LiveRoomUpdateRequest._({
      'action': 'delete_live_room',
      'channel_id': channelId,
    });
  }

  factory LiveRoomUpdateRequest.removeUserFromCallingGroup({
    required int channelId,
    required int uid,
  }) {
    return LiveRoomUpdateRequest._({
      'action': 'remove_user_from_calling_group',
      'channel_id': channelId,
      'uid': uid,
    });
  }

  factory LiveRoomUpdateRequest.addUserToCallingGroup({
    required int channelId,
    required int uid,
  }) {
    return LiveRoomUpdateRequest._({
      'action': 'add_user_to_calling_group',
      'channel_id': channelId,
      'uid': uid,
    });
  }

  String get action => (_payload['action'] ?? '').toString();

  int get channelId => intFromDynamic(_payload['channel_id']);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_payload);
}

class LiveRoomUpdateResult {
  const LiveRoomUpdateResult({required this.statusCode, this.error});

  final int statusCode;
  final String? error;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isNotFound => statusCode == 404;

  factory LiveRoomUpdateResult.fromResponse({
    required int statusCode,
    dynamic data,
  }) {
    final map = mapFromDynamic(data);
    return LiveRoomUpdateResult(
      statusCode: statusCode,
      error: nullableStringFromDynamic(map['error'] ?? map['message']),
    );
  }
}
