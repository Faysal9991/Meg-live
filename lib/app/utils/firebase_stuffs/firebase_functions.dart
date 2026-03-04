import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide FormData;

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
        'X-Api-Key': DRF_API_KEY,
        'Authorization': 'Token ${authController.token.value}',
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
        'X-Api-Key': DRF_API_KEY,
        'Authorization': 'Token ${authController.token.value}',
      }),
    );
  } catch (e) {
    //
  }
  // print("Bego(updateFCMDeviceToken) ${response.data}");
}
