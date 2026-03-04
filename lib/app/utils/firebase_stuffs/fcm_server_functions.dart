import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

// Future<String> getAgoraServerToken(
//     {required String channelName, required int uid}) async {
//   // Reference:
//   // https://github.com/AgoraIO-Community/Agora-Node-TokenServer#readme
//   // url: https://right-tune-agora-token.herokuapp.com/rte/test/publisher/ljfds/dfjlsd/
//   /*
//   url: /rte/:channelName/:role/:tokentype/:uid/?expiry=
//   response:
//   {
//     "rtcToken":" ",
//     "rtmToken":" "
//   }
//   */
//   // tokentype = 'userAccount' or 'uid'
//   /*
//   String tokenType = 'uid';
//   // String url =
//   //     'https://right-tune-agora-token.herokuapp.com/rte/$channelName/publisher/$tokenType/$uid/';
//   String url =
//       'https://right-tune-agora-token.herokuapp.com/rtc/$channelName/publisher/$tokenType/$uid/';
//   */
//   // channel_name = data_obj.get('channel_name',None)
//   // uid = data_obj.get('uid',0)
//   // role = data_obj.get('role',2)
//   // # role
//   // # Role_Publisher = 1: A broadcaster (host) in a live-broadcast profile.
//   // # Role_Subscriber = 2: (Default) A audience in a live-broadcast profile.
//   var dio = Dio();
//   try {
//     // Response response = await dio.get(url);
//     Response response = await dio.get(
//         kAgoraRtcTokenRetrieveUrl(channelName: channelName, uid: uid, role: 1));
//     return response.data['rtcToken'];
//   } catch (e) {
//     return '';
//   }
// }

void registerFCMDevice({required String fcmDeviceToken}) async {
  final AuthController authController = Get.find();

  var dio = Dio();
  var formData = FormData.fromMap({
    'token': fcmDeviceToken,
  });
  try {
    await dio.post(
      kFCMDeviceCreateUrl,
      data: formData,
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token ${authController.token.value}',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
  } catch (e) {
    //
  }
  // print("Bego(registerDevice) ${response.data}");
}

Future<String?> getFCMDeviceToken() async {
  return await FirebaseMessaging.instance.getToken();
}

void onFCMDeviceTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmDeviceToken) {
    updateFCMDeviceToken(fcmDeviceToken: fcmDeviceToken);
  }).onError((err) {});
}

void updateFCMDeviceToken({required String fcmDeviceToken}) async {
  final AuthController authController = Get.find();

  var dio = Dio();
  var formData = FormData.fromMap({
    'token': fcmDeviceToken,
  });
  try {
    await dio.put(
      kFCMUserTokenUpdateUrl,
      data: formData,
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token ${authController.token.value}',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
  } catch (e) {
    //
  }
  // print("Bego(updateFCMDeviceToken) ${response.data}");
}

void notifyUser({
  required String title,
  required String body,
  required int receiverUid,
  String? eventType,
  String? channel,
}) async {
  final AuthController authController = Get.find();

  var dio = Dio();
  var formData = FormData.fromMap({
    'title': title,
    'message': body,
    'image': authController.profile.value.profile_image,
    'receiver_uid': receiverUid,
    'event_type': eventType ?? '',
    'channel': channel ?? '',
  });
  try {
    await dio.post(
      kFCMSinglePushCreate,
      data: formData,
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token ${authController.token.value}',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
  } catch (e) {
    //
  }
  // print("Bego(notifyUser) ${response.data}");
}
