import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:doyel_live/app/modules/messenger/views/messages/message_view.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/notification_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:get/get.dart';

Future<void> notificationInitialization() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectForgroundNotification,
    onDidReceiveBackgroundNotificationResponse: selectBackgroundNotification,
  );
}

Future selectForgroundNotification(NotificationResponse details) async {
  //Handle notification tapped logic here
  final payload = jsonDecode(details.payload!);
  String title = payload['data']['title'];
  String eventType = payload['data']['event_type'];
  String channel = payload['data']['channel'];
  // int peerUserId = payload['data']['peered_uid'];
  int peerUserId = int.parse(payload['data']['peered_uid'].toString());

  String peerUsername = payload['data']['peered_name'];
  String? imageUrl = payload['data']['image'];

  if (eventType == NOTIFY_CHAT) {
    // Chat Notification
    dynamic profile = {
      'profile_image': imageUrl,
      'full_name': peerUsername,
      'user': {'uid': peerUserId},
    };
    Get.to(
      () =>
          MessagesView(profile: profile, chatId: channel, isShowInLive: false),
    );
  } else if (eventType == NOTIFY_STREAM_FOLLOWER) {
    // Live Stream notification for followers
    HelperFunctions().showLiveStreaming(
      channelId: channel,
      title: title,
      image: imageUrl,
    );
  } else if (eventType == NOTIFY_GROUP_CHAT) {
    // Group Chat
    // Get.to(() => GroupChatView(
    //       groupId: channel,
    //       adminId: peerUserId,
    //       groupName: title,
    //     ));
  }
}

Future selectBackgroundNotification(NotificationResponse details) async {
  //Handle notification tapped logic here
  final payload = jsonDecode(details.payload!);
  String title = payload['data']['title'];
  String eventType = payload['data']['event_type'];
  String channel = payload['data']['channel'];
  // int peerUserId = payload['data']['peered_uid'];
  int peerUserId = int.parse(payload['data']['peered_uid'].toString());

  String peerUsername = payload['data']['peered_name'];
  String? imageUrl = payload['data']['image'];

  if (eventType == NOTIFY_CHAT) {
    // Chat Notification
    dynamic profile = {
      'profile_image': imageUrl,
      'full_name': peerUsername,
      'user': {'uid': peerUserId},
    };
    Get.to(
      () =>
          MessagesView(profile: profile, chatId: channel, isShowInLive: false),
    );
  } else if (eventType == NOTIFY_STREAM_FOLLOWER) {
    // Live Stream notification for followers
    HelperFunctions().showLiveStreaming(
      channelId: channel,
      title: title,
      image: imageUrl,
    );
  } else if (eventType == NOTIFY_GROUP_CHAT) {
    // Group Chat
    // Get.to(() => GroupChatView(
    //       groupId: channel,
    //       adminId: peerUserId,
    //       groupName: title,
    //     ));
  }
}

// @pragma('vm:entry-point')
// Future<void> messageHandler(RemoteMessage message) async {
//   NotificationMessage notificationMessage = NotificationMessage.fromJson(
//     message.data,
//   );
//   messageNotification(
//     notificationMessage.data!.title,
//     notificationMessage.data!.message,
//     notificationMessage,
//   );
// }

void firebaseMessagingListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationMessage notificationMessage = NotificationMessage.fromJson(
      message.data,
    );

    messageNotification(
      notificationMessage.data!.title,
      notificationMessage.data!.message,
      notificationMessage,
    );
  });
}

Future<void> messageNotification(
  title,
  body,
  NotificationMessage notificationMessageObj,
) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
        "message notification",
        "Messages Notifications",
        channelDescription: "Show message to user",
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        autoCancel: true,
      );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    Random().nextInt(1000000000),
    title,
    body,
    platformChannelSpecifics,
    payload: jsonEncode(notificationMessageObj.toJson()),
  );
}
