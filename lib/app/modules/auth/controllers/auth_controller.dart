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
import 'package:doyel_live/app/utils/api_logger.dart';
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

Future<void> tryToSignInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  _googleLog(
    '══════════════════════════════════════════════════════════',
    color: _magenta,
  );
  _googleLog(
    '🚀 GOOGLE LOGIN STARTED',
    color: _magenta,
  );
  _googleLog(
    '══════════════════════════════════════════════════════════',
    color: _magenta,
  );

  try {
    // ============================================================
    // STEP 1: GOOGLE AUTHENTICATION
    // ============================================================

    _googleLog(
      'STEP 1 → Calling GoogleSignIn.authenticate()...',
      color: _blue,
    );

    final userData = await googleSignIn.authenticate();

    _googleLog(
      '✅ STEP 1 SUCCESS → Google authentication successful',
      color: _green,
    );

    // ============================================================
    // STEP 2: GOOGLE USER DATA
    // ============================================================

    final String? fullName = userData.displayName;
    final String email = userData.email;
    final String uid = userData.id;
    final String? photoUrl = userData.photoUrl;

    _googleLog(
      'STEP 2 → Google user information received',
      color: _blue,
    );

    _googleLog(
      '👤 Name      : $fullName',
      color: _green,
    );

    _googleLog(
      '📧 Email     : $email',
      color: _green,
    );

    _googleLog(
      '🆔 Google UID: $uid',
      color: _green,
    );

    _googleLog(
      '🖼 Photo URL : ${photoUrl ?? "NULL"}',
      color: _green,
    );

    // ============================================================
    // STEP 3: GOOGLE ID TOKEN
    // ============================================================

    _googleLog(
      'STEP 3 → Getting Google ID Token...',
      color: _blue,
    );

    final String? idToken = userData.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      _googleLog(
        '❌ GOOGLE ID TOKEN IS NULL / EMPTY',
        color: _red,
      );

      _googleLog(
        'Possible issue → OAuth client / serverClientId / '
        'google-services.json configuration',
        color: _yellow,
      );
    } else {
      _googleLog(
        '✅ Google ID Token received',
        color: _green,
      );

      _googleLog(
        '🔑 Token length: ${idToken.length}',
        color: _green,
      );

      // Do NOT print full token.
      final previewLength = idToken.length > 15 ? 15 : idToken.length;

      _googleLog(
        '🔑 Token preview: ${idToken.substring(0, previewLength)}...',
        color: _yellow,
      );
    }

    // আপনার backend field-এর নাম server_auth_code,
    // কিন্তু এখানে actually Google ID Token পাঠানো হচ্ছে।
    final String? serverAuthCode = idToken;

    // ============================================================
    // STEP 4: BUILD BACKEND PAYLOAD
    // ============================================================

    final dynamic data = {
      'login_type': 'google_login',
      'full_name': fullName,
      'email': email,
      'uid': uid,
      'photo_url': photoUrl,
      'server_auth_code': serverAuthCode,
    };

    _googleLog(
      'STEP 4 → Backend payload created',
      color: _blue,
    );

    _googleLog(
      '''
Payload:
{
  login_type: google_login,
  full_name: $fullName,
  email: $email,
  uid: $uid,
  photo_url: $photoUrl,
  server_auth_code: ${serverAuthCode == null ? "NULL" : "AVAILABLE (${serverAuthCode.length} chars)"}
}
''',
      color: _cyan,
    );

    // ============================================================
    // STEP 5: SIGN OUT
    // ============================================================

    _googleLog(
      'STEP 5 → Existing code is calling googleSignIn.signOut()...',
      color: _yellow,
    );

    try {
      await googleSignIn.signOut();

      _googleLog(
        '⚠️ Google signOut() completed immediately after authenticate()',
        color: _yellow,
      );

      try {
        Get.back();

        _googleLog(
          'Get.back() executed',
          color: _yellow,
        );
      } catch (e) {
        _googleLog(
          '⚠️ Get.back() error: $e',
          color: _yellow,
        );
      }
    } catch (e, stackTrace) {
      _googleLog(
        '❌ Google signOut() failed',
        color: _red,
      );

      _googleLog(
        'Error: $e',
        color: _red,
      );

      _googleLog(
        'StackTrace:\n$stackTrace',
        color: _red,
      );
    }

    authLoading.value = true;

    // ============================================================
    // STEP 6: GET DEVICE ID
    // ============================================================

    _googleLog(
      'STEP 6 → Getting device ID...',
      color: _blue,
    );

    String deviceId;

    try {
      deviceId = await getUniqueDeviceId();

      _googleLog(
        '✅ Device ID received: $deviceId',
        color: _green,
      );
    } catch (e, stackTrace) {
      _googleLog(
        '❌ FAILED TO GET DEVICE ID',
        color: _red,
      );

      _googleLog(
        'Error Type: ${e.runtimeType}',
        color: _red,
      );

      _googleLog(
        'Error: $e',
        color: _red,
      );

      _googleLog(
        'StackTrace:\n$stackTrace',
        color: _red,
      );

      rethrow;
    }

    // ============================================================
    // STEP 7: BACKEND LOGIN REQUEST
    // ============================================================

    final Dio dio = Dio();

    final headers = <String, dynamic>{
      'accept': '*/*',
      'X-Api-Key': DRF_API_KEY,
    };

    final query = <String, dynamic>{
      'device_id': deviceId,
    };

    _googleLog(
      'STEP 7 → Sending Google login request to backend...',
      color: _blue,
    );

    _googleLog(
      '🌐 URL: $kLoginUsingFirebaseUrl',
      color: _cyan,
    );

    _googleLog(
      '📲 Device ID: $deviceId',
      color: _cyan,
    );

    _googleLog(
      '📧 Email: $email',
      color: _cyan,
    );

    _googleLog(
      '🆔 UID: $uid',
      color: _cyan,
    );

    // Do NOT print DRF_API_KEY / full ID token.

    ApiLogger.hit(
      method: 'POST',
      url: kLoginUsingFirebaseUrl,
      body: {
        'login_type': data['login_type'],
        'full_name': data['full_name'],
        'email': data['email'],
        'uid': data['uid'],
        'photo_url': data['photo_url'],
        'server_auth_code':
            serverAuthCode == null ? null : '[GOOGLE_ID_TOKEN_AVAILABLE]',
      },
      query: query,
      headers: {
        'accept': '*/*',
        'X-Api-Key': '[REDACTED]',
      },
    );

    try {
      final response = await dio.post(
        kLoginUsingFirebaseUrl,
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            // Allow us to log all backend response codes.
            return status != null && status < 600;
          },
        ),
        queryParameters: query,
      );

      // ============================================================
      // STEP 8: BACKEND RESPONSE
      // ============================================================

      _googleLog(
        'STEP 8 → Backend responded',
        color: _blue,
      );

      _googleLog(
        '📡 HTTP STATUS: ${response.statusCode}',
        color: response.statusCode == 201 ? _green : _yellow,
      );

      _googleLog(
        '📦 RESPONSE DATA: ${response.data}',
        color: response.statusCode == 201 ? _green : _yellow,
      );

      ApiLogger.response(
        method: 'POST',
        url: kLoginUsingFirebaseUrl,
        statusCode: response.statusCode,
        data: response.data,
      );

      final int? statusCode = response.statusCode;

      authLoading.value = false;

      // ============================================================
      // LOGIN SUCCESS
      // ============================================================

      if (statusCode == 201) {
        _googleLog(
          '══════════════════════════════════════════════════════════',
          color: _green,
        );

        _googleLog(
          '🎉 GOOGLE LOGIN SUCCESS',
          color: _green,
        );

        _googleLog(
          '══════════════════════════════════════════════════════════',
          color: _green,
        );

        token.value = response.data['token'];

        profile.value = Profile.fromJson(
          response.data['profile'],
        );

        preferences.setString(
          'token',
          response.data['token'],
        );

        preferences.setString(
          'profile',
          jsonEncode(response.data['profile']),
        );

        _googleLog(
          '✅ Backend token saved',
          color: _green,
        );

        _googleLog(
          '✅ Profile saved',
          color: _green,
        );

        // ============================================================
        // FCM
        // ============================================================

        try {
          _googleLog(
            'Getting FCM token...',
            color: _blue,
          );

          final fcmDeviceToken = await getFCMDeviceToken();

          if (fcmDeviceToken == null) {
            _googleLog(
              '⚠️ FCM token is NULL',
              color: _yellow,
            );
          } else {
            _googleLog(
              '✅ FCM token received',
              color: _green,
            );

            registerFCMDevice(
              fcmDeviceToken: fcmDeviceToken,
            );

            _googleLog(
              '✅ FCM device registered',
              color: _green,
            );
          }
        } catch (e, stackTrace) {
          _googleLog(
            '⚠️ FCM registration failed AFTER login',
            color: _yellow,
          );

          _googleLog(
            'FCM Error: $e',
            color: _yellow,
          );

          _googleLog(
            'FCM StackTrace:\n$stackTrace',
            color: _yellow,
          );
        }

        _googleLog(
          '🏠 Navigating to Routes.NAV',
          color: _green,
        );

        Get.offAllNamed(Routes.NAV);

        return;
      }

      // ============================================================
      // DEVICE BLOCKED
      // ============================================================

      if (statusCode == 208) {
        _googleLog(
          '⛔ LOGIN FAILED → DEVICE BLOCKED (HTTP 208)',
          color: _red,
        );

        Get.snackbar(
          'Forbidden',
          'Your device has been blocked.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      // ============================================================
      // OTHER BACKEND ERROR
      // ============================================================

      _googleLog(
        '❌ BACKEND REJECTED GOOGLE LOGIN',
        color: _red,
      );

      _googleLog(
        'HTTP STATUS: $statusCode',
        color: _red,
      );

      _googleLog(
        'RESPONSE: ${response.data}',
        color: _red,
      );

      Get.snackbar(
        'Google Login Failed',
        'Backend returned HTTP $statusCode',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // ============================================================
    // DIO / NETWORK ERROR
    // ============================================================
    on DioException catch (e, stackTrace) {
      authLoading.value = false;

      _googleLog(
        '══════════════════════════════════════════════════════════',
        color: _red,
      );

      _googleLog(
        '❌ BACKEND / NETWORK ERROR',
        color: _red,
      );

      _googleLog(
        '══════════════════════════════════════════════════════════',
        color: _red,
      );

      _googleLog(
        'DioException Type: ${e.type}',
        color: _red,
      );

      _googleLog(
        'Message: ${e.message}',
        color: _red,
      );

      _googleLog(
        'URL: ${e.requestOptions.uri}',
        color: _red,
      );

      _googleLog(
        'Method: ${e.requestOptions.method}',
        color: _red,
      );

      _googleLog(
        'HTTP Status: ${e.response?.statusCode}',
        color: _red,
      );

      _googleLog(
        'Backend Response: ${e.response?.data}',
        color: _red,
      );

      _googleLog(
        'Error Object: ${e.error}',
        color: _red,
      );

      _googleLog(
        'StackTrace:\n$stackTrace',
        color: _red,
      );

      ApiLogger.error(
        method: 'POST',
        url: kLoginUsingFirebaseUrl,
        error: e,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Google Login Failed',
        'Backend/network error. Check debug console.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==============================================================
  // GOOGLE SIGN-IN SPECIFIC ERROR
  // ==============================================================

  on GoogleSignInException catch (e, stackTrace) {
    authLoading.value = false;

    _googleLog(
      '══════════════════════════════════════════════════════════',
      color: _red,
    );

    _googleLog(
      '❌ GOOGLE SIGN-IN EXCEPTION',
      color: _red,
    );

    _googleLog(
      '══════════════════════════════════════════════════════════',
      color: _red,
    );

    _googleLog(
      'Error Code       : ${e.code}',
      color: _red,
    );

    _googleLog(
      'Description      : ${e.description}',
      color: _red,
    );

    _googleLog(
      'Details          : ${e.details}',
      color: _red,
    );

    _googleLog(
      'Runtime Type     : ${e.runtimeType}',
      color: _red,
    );

    _googleLog(
      'Possible Reason  : ${_googleErrorHint(e.code)}',
      color: _yellow,
    );

    _googleLog(
      'StackTrace:\n$stackTrace',
      color: _red,
    );

    Get.snackbar(
      'Google Login Failed',
      '${e.code}: ${e.description ?? "Unknown Google authentication error"}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  // ==============================================================
  // UNKNOWN ERROR
  // ==============================================================

  catch (e, stackTrace) {
    authLoading.value = false;

    _googleLog(
      '══════════════════════════════════════════════════════════',
      color: _red,
    );

    _googleLog(
      '💥 UNKNOWN GOOGLE LOGIN ERROR',
      color: _red,
    );

    _googleLog(
      '══════════════════════════════════════════════════════════',
      color: _red,
    );

    _googleLog(
      'Runtime Type: ${e.runtimeType}',
      color: _red,
    );

    _googleLog(
      'Error: $e',
      color: _red,
    );

    _googleLog(
      'StackTrace:\n$stackTrace',
      color: _red,
    );

    Get.snackbar(
      'Google Login Failed',
      '$e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }
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
    final headers = <String, dynamic>{
      'accept': '*/*',
      'X-Api-Key': DRF_API_KEY,
    };
    try {
      final deviceId = await getUniqueDeviceId();
      final query = <String, dynamic>{'device_id': deviceId};

      ApiLogger.hit(
        method: 'POST',
        url: kLoginUsingFirebaseUrl,
        body: data,
        query: query,
        headers: headers,
      );

      final response = await dio.post(
        kLoginUsingFirebaseUrl,
        data: data,
        options: Options(headers: headers),
        queryParameters: query,
      );

      ApiLogger.response(
        method: 'POST',
        url: kLoginUsingFirebaseUrl,
        statusCode: response.statusCode,
        data: response.data,
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
    } catch (e, stackTrace) {
      final dioException = e is DioException ? e : null;
      ApiLogger.error(
        method: 'POST',
        url: kLoginUsingFirebaseUrl,
        error: e,
        statusCode: dioException?.response?.statusCode,
        data: dioException?.response?.data,
        stackTrace: stackTrace,
      );

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



// ================= GOOGLE LOGIN DEBUG LOGGER =================

static const String _reset = '\x1B[0m';
static const String _red = '\x1B[31m';
static const String _green = '\x1B[32m';
static const String _yellow = '\x1B[33m';
static const String _blue = '\x1B[34m';
static const String _magenta = '\x1B[35m';
static const String _cyan = '\x1B[36m';

void _googleLog(
  String message, {
  String color = _cyan,
}) {
  debugPrint('$color[GOOGLE-AUTH] $message$_reset');
}

String _googleErrorHint(GoogleSignInExceptionCode code) {
  switch (code) {
    case GoogleSignInExceptionCode.canceled:
      return 'User cancelled OR Android OAuth/SHA configuration may be wrong.';

    case GoogleSignInExceptionCode.interrupted:
      return 'Google Sign-In flow was interrupted.';

    case GoogleSignInExceptionCode.clientConfigurationError:
      return 'CLIENT CONFIG ERROR → Check SHA-1, SHA-256, package name, '
          'google-services.json and serverClientId.';

    case GoogleSignInExceptionCode.providerConfigurationError:
      return 'Google authentication provider/SDK configuration problem.';

    case GoogleSignInExceptionCode.uiUnavailable:
      return 'Google Sign-In UI could not be displayed.';

    case GoogleSignInExceptionCode.userMismatch:
      return 'Selected Google account does not match current authenticated user.';

    default:
      return 'Unknown Google Sign-In error.';
  }
}
}


