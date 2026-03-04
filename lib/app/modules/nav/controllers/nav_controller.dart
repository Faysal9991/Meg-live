import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavController extends GetxController {
  final pageIndex = 0.obs;

  void tryUserDeviceInfoUpdate() async {
    AuthController authController = Get.find();
    String? uniqueDeviceId = '', deviceName = '';
    uniqueDeviceId = await authController.getUniqueDeviceId();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      // const androidIdPlugin = AndroidId();

      // final String? androidId = await androidIdPlugin.getId();
      // uniqueDeviceId = androidId!;

      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model; // e.g. "Moto G (4)"
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      // uniqueDeviceId = iosDeviceInfo.identifierForVendor!;
      deviceName = iosDeviceInfo.utsname.machine; // e.g. "iPod7,1"
    }

    var data = {
      'device_name': deviceName,
      'device_id': uniqueDeviceId,
    };
    var dio = Dio();
    try {
      final response = await dio.put(
        kUserDeviceInfoUpdateUrl,
        data: data,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          // 'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        bool deviceBlocked = response.data['device_blocked'];
        if (deviceBlocked) {
          Get.snackbar(
            'Blocked',
            "Your device has been blocked.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          authController.setShowingOverlay(overlay: false);
          // authController.preferences.setString('token', '');
          // authController.preferences.setString('profile', '');
          // authController.preferences.setString('game_profile', '');
          // authController.preferences.setString('camera_filter', '');
          authController.preferences.clear();
          Get.offAllNamed(Routes.AUTH);
          authController.token.value = '';
          authController.tryToSignOut();
        }
      }
    } catch (e) {
      //
    }
  }

  void setPageIndex({required int index}) {
    pageIndex.value = index;
  }
}
