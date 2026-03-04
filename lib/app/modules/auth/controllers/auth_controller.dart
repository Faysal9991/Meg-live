import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/firebase_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AuthController extends GetxController {
  final showingOverlay = false.obs;
  final authLoading = false.obs;
  final loadingChangePassword = false.obs;
  final profile = Profile().obs;
  final token = ''.obs;
  final country = CountryPickerUtils.getCountryByPhoneCode('880').obs;

  late StreamingSharedPreferences preferences;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize() async {
    preferences = await StreamingSharedPreferences.instance;
    preferences.getString('token', defaultValue: '').listen((value) {
      token.value = value;
    });
    preferences.getString('profile', defaultValue: '').listen((value) {
      if (value.isNotEmpty) {
        profile.value = Profile.fromJson(jsonDecode(value));
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void setCountryPicked(Country pickedCountry) {
    country.value = pickedCountry;
    // print(
    //     "Yess: ${country.phoneCode} ${country.name} ${country.isoCode} ${country.iso3Code}");
  }

  void setShowingOverlay({required bool overlay}) {
    showingOverlay.value = overlay;
  }

  Future<int> tryToGetAppLockedBuildNumber() async {
    var dio = Dio();
    try {
      final response = await dio.get(
        kAppLockRetrieveUrl,
        options: Options(headers: {'accept': '*/*', 'X-Api-Key': DRF_API_KEY}),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        return response.data['build_number'];
      }
    } catch (e) {
      return -1;
    }
    return -1;
  }

  void tryToSignInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    googleSignIn
        .authenticate()
        .then((userData) async {
          googleSignIn
              .signOut()
              .then((value) {
                Get.back();
              })
              .catchError((_) {});

          authLoading.value = true;

          String? fullName = userData.displayName;
          String email = userData.email;
          String uid = userData.id;
          String? photoUrl = userData.photoUrl;
          // String? serverAuthCode = userData.serverAuthCode;
          String? serverAuthCode = userData.authentication.idToken;

          // Testing
          // dynamic data = {
          //   'login_type': 'google_login',
          //   'full_name': 'Tester Four',
          //   'email': 'testersuperfour@gmail.com',
          //   'uid': 'uid',
          //   'photo_url':
          //       'https://lh3.googleusercontent.com/a/ACg8ocKHaVpNXViHM5QT6XEmhIDWZTtRULssYvfOZ5f2lkimm2dZuA=s288-c-mo-no',
          //   'server_auth_code': 'serverAuthCode',
          // };
          dynamic data = {
            'login_type': 'google_login',
            'full_name': fullName,
            'email': email,
            'uid': uid,
            'photo_url': photoUrl,
            'server_auth_code': serverAuthCode,
          };
          // SignUp Api Call
          var dio = Dio();
          try {
            final response = await dio.post(
              kLoginUsingFirebaseUrl,
              data: data,
              options: Options(
                headers: {'accept': '*/*', 'X-Api-Key': DRF_API_KEY},
              ),
              queryParameters: {'device_id': await getUniqueDeviceId()},
            );
            int? statusCode = response.statusCode;
            authLoading.value = false;
            if (statusCode == 201) {
              token.value = response.data['token'];
              profile.value = Profile.fromJson(response.data['profile']);
              preferences.setString('token', response.data['token']);
              preferences.setString(
                'profile',
                jsonEncode(response.data['profile']),
              );

              // Get.snackbar(
              //   'Success',
              //   "Welcome to Doyel Live.",
              //   backgroundColor: Colors.green,
              //   colorText: Colors.white,
              //   snackPosition: SnackPosition.BOTTOM,
              //   duration: const Duration(
              //     seconds: 1,
              //   ),
              // );
              getFCMDeviceToken().then(
                (fcmDeviceToken) =>
                    registerFCMDevice(fcmDeviceToken: fcmDeviceToken!),
              );

              Get.offAllNamed(Routes.NAV);
            } else if (statusCode == 208) {
              Get.snackbar(
                'Forbidden',
                "Your device has been blocked.",
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            authLoading.value = false;
            Get.snackbar(
              'Failed',
              "Something is wrong. Please try again.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        })
        .catchError((_) {
          // print('Error.......$e');
          Get.snackbar(
            'Failed',
            "Something is wrong. Please try again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  void tryToSingInWithPassword({
    required String fullName,
    required String phoneCode,
    required String mobileNumber,
    required String password,
  }) async {
    authLoading.value = true;
    dynamic data = {
      'login_type': 'password_login',
      'full_name': fullName,
      'phone_code': phoneCode,
      'mobile_number': mobileNumber,
      'password': password,
    };

    var dio = Dio();
    try {
      final response = await dio.post(
        kLoginUsingFirebaseUrl,
        data: data,
        options: Options(headers: {'accept': '*/*', 'X-Api-Key': DRF_API_KEY}),
        queryParameters: {'device_id': await getUniqueDeviceId()},
      );
      int? statusCode = response.statusCode;
      authLoading.value = false;
      if (statusCode == 201) {
        token.value = response.data['token'];
        profile.value = Profile.fromJson(response.data['profile']);
        preferences.setString('token', response.data['token']);
        preferences.setString('profile', jsonEncode(response.data['profile']));

        // Get.snackbar(
        //   'Success',
        //   "Welcome to Doyel Live.",
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: const Duration(seconds: 2),
        // );

        getFCMDeviceToken().then(
          (fcmDeviceToken) =>
              registerFCMDevice(fcmDeviceToken: fcmDeviceToken!),
        );

        Get.offAllNamed(Routes.NAV);
      } else if (statusCode == 208) {
        Get.snackbar(
          'Forbidden',
          "Your device has been blocked.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 203) {
        String message = response.data['message'];
        Get.snackbar(
          'Failed',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      authLoading.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void tryToSignOut() async {
    authLoading.value = true;

    var dio = Dio();
    try {
      final response = await dio.post(
        kLogoutUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'X-Api-Key': DRF_API_KEY,
            'Authorization': 'Token ${token.value}',
          },
        ),
      );
      int? statusCode = response.statusCode;
      authLoading.value = false;

      if (statusCode == 201) {
        preferences.clear();
        Get.offAllNamed(Routes.AUTH);
        token.value = '';
        // profile.value = Profile();
      } else {
        Get.snackbar(
          'Failed',
          "Something is wrong. Please check your internet connection.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      authLoading.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please check your internet connection.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      preferences.clear();
      Get.offAllNamed(Routes.AUTH);
      token.value = '';
      // profile.value = Profile();
    }
  }

  Future<bool> tryToChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    loadingChangePassword.value = true;
    final AuthController authController = Get.find();
    var dio = Dio();
    var data = {'old_password': oldPassword, 'new_password': newPassword};
    try {
      final response = await dio.put(
        kChangePasswordUpdateUrl,
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'X-Api-Key': DRF_API_KEY,
            'Authorization': 'Token ${authController.token.value}',
          },
        ),
      );
      int? statusCode = response.statusCode;
      loadingChangePassword.value = false;
      if (statusCode == 200) {
        Get.snackbar(
          'Success',
          "Your password has been changed.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else if (statusCode == 203) {
        Get.snackbar(
          'Failed',
          "Your credential is mismatch.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Failed',
          "Something is wrong. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingChangePassword.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return false;
  }

  Future<String> getUniqueDeviceId() async {
    String uniqueDeviceId = '';
    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();

      final String? androidId = await androidIdPlugin.getId();
      uniqueDeviceId = androidId!;
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      uniqueDeviceId = iosDeviceInfo.identifierForVendor!;
    }
    return uniqueDeviceId;
  }
}
