import 'dart:convert';

class NotificationMessage {
  Data? data;

  NotificationMessage({this.data});

  NotificationMessage.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null ? Data.fromJson(jsonDecode(json['data'])) : null;
  }

  Map<String, dynamic> toJson() => {
        'data': data!.toJson(),
      };
}

class Data {
  String? title;
  String? message;
  String? image;
  int? peeredUid;
  String? peeredName;
  String? callType;
  String? eventType;
  String? channel;

  Data({
    this.image,
    this.title,
    this.message,
    this.peeredUid,
    this.peeredName,
    this.callType,
    this.eventType,
    this.channel,
  });

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
    image = json['image'];
    peeredUid = json['peered_uid'] is int
        ? json['peered_uid']
        : int.parse(json['peered_uid'].toString());
    peeredName = json['peered_name'];
    callType = json['call_type'];
    eventType = json['event_type'];
    channel = json['channel'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'message': message,
        'image': image,
        'peered_uid': peeredUid,
        'peered_name': peeredName,
        'call_type': callType,
        'event_type': eventType,
        'channel': channel,
      };
}
