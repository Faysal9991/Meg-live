import 'dart:io';

import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/fcm_notifications.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/notification_message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/routes/app_pages.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
Future<void> messageHandler(RemoteMessage message) async {
  NotificationMessage notificationMessage = NotificationMessage.fromJson(
    message.data,
  );
  messageNotification(
    notificationMessage.data!.title,
    notificationMessage.data!.message,
    notificationMessage,
  );
}

Future<void> _secureScreen() async {
  if (Platform.isAndroid) {
    await FlutterWindowManagerPlus.addFlags(
      FlutterWindowManagerPlus.FLAG_KEEP_SCREEN_ON,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(
    serverClientId:
        'firebase-adminsdk-mbp7w@doyel-live.iam.gserviceaccount.com',
  );

  await notificationInitialization();
  // FCM Background
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  // FCM Foreground
  firebaseMessagingListener();

  Get.put(AuthController());
  Get.put(MessengerController());
  Get.put(LiveStreamingController());
  // Disable screenshot and screen recording
  _secureScreen();
  // Override the ssl certificate requirements
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    GetMaterialApp(
      title: "Doyel Live",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF007C00),
        ),
        primaryColor: const Color(0xFF007C00),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
      ),
    ),
  );
}
