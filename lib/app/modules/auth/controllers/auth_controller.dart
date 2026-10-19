import 'package:doyel_live/app/theme/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/services/google_auth_service.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/firebase_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AuthController extends GetxController {
  AuthController({GoogleAuthService? googleAuth, Dio? googleLoginDio})
    : _googleAuth = googleAuth ?? GoogleAuthService.instance,
      _googleLoginDio = googleLoginDio == null
          ? createApiDio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
              ),
            )
          : configureApiDio(googleLoginDio);

  final GoogleAuthService _googleAuth;
  final Dio _googleLoginDio;

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
    final dio = createApiDio();
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
    if (authLoading.value) return;
    authLoading.value = true;
    var stage = 'google';
    try {
      ApiLogger.info('Starting Google sign-in', tag: 'GOOGLE-AUTH');
      final identity = await _googleAuth.authenticate();
      final idToken = identity.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        throw const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
          description:
              'No Google ID token. Check the web OAuth client configuration.',
        );
      }
      final audience = _googleTokenAudience(idToken);
      debugPrint(
        '[GOOGLE-AUTH] Google returned an ID token'
        '${audience == null ? '' : ' for audience $audience'}',
      );
      stage = 'device';
      final deviceId = await getUniqueDeviceId();
      final data = {
        'login_type': 'google_login',
        'full_name': identity.displayName,
        'email': identity.email,
        'uid': identity.id,
        'photo_url': identity.photoUrl,
        // The backend expects an ID token under this legacy field name.
        'server_auth_code': idToken,
      };
      final headers = <String, dynamic>{
        'accept': '*/*',
        'X-Api-Key': DRF_API_KEY,
      };
      final query = <String, dynamic>{'device_id': deviceId};
      stage = 'backend';
      final response = await _googleLoginDio.post(
        kLoginUsingFirebaseUrl,
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 600,
        ),
        queryParameters: query,
      );
      if (response.statusCode == 201) {
        stage = 'session';
        final nextToken = response.data['token'];
        final nextProfile = Profile.fromJson(response.data['profile']);
        if (nextToken is! String ||
            nextToken.isEmpty ||
            nextProfile.user?.uid == null) {
          throw const FormatException('Incomplete login session');
        }
        preferences = await StreamingSharedPreferences.instance;
        await preferences.setString('token', nextToken);
        await preferences.setString(
          'profile',
          jsonEncode(response.data['profile']),
        );
        token.value = nextToken;
        profile.value = nextProfile;
        // Google owns its account picker. Keep our route until login succeeds.
        Get.offAllNamed(Routes.NAV);
        unawaited(_registerGoogleLoginNotifications());
      } else if (response.statusCode == 208) {
        _showGoogleLoginError(
          'Your device has been blocked.',
          title: 'Forbidden',
        );
      } else {
        debugPrint(
          '[GOOGLE-AUTH] Backend rejected login: HTTP ${response.statusCode}',
        );
        _showGoogleLoginError(
          'Unable to complete Google login. Please try again.',
        );
      }
    } on GoogleSignInException catch (error) {
      debugPrint(
        '[GOOGLE-AUTH] ${error.code.name}: '
        '${error.description ?? _googleErrorHint(error.code)} '
        '(details: ${error.details ?? 'none'})',
      );
      if (error.code != GoogleSignInExceptionCode.canceled) {
        final configurationError =
            error.code == GoogleSignInExceptionCode.clientConfigurationError ||
            error.code == GoogleSignInExceptionCode.providerConfigurationError;
        _showGoogleLoginError(
          configurationError
              ? 'Google sign-in is unavailable in this version. Please use phone login and contact support.'
              : 'Google sign-in was interrupted. Please try again.',
        );
      }
    } catch (error) {
      debugPrint('[GOOGLE-AUTH] Login failed at $stage (${error.runtimeType})');
      _showGoogleLoginError(
        error is DioException
            ? 'Unable to connect. Check your internet connection and try again.'
            : 'Unable to complete Google login. Please try again.',
      );
    } finally {
      authLoading.value = false;
    }
  }

  // This is diagnostic metadata only. The backend still verifies the ID token.
  // Never log the token itself or the other account claims.
  String? _googleTokenAudience(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final audience = payload is Map ? payload['aud'] : null;
      return audience is String &&
              RegExp(
                r'^[A-Za-z0-9-]+\.apps\.googleusercontent\.com$',
              ).hasMatch(audience)
          ? audience
          : null;
    } catch (_) {
      return null;
    }
  }

  void _showGoogleLoginError(String message, {String title = 'Google login'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.onLight,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _registerGoogleLoginNotifications() async {
    try {
      final fcmDeviceToken = await getFCMDeviceToken();
      if (fcmDeviceToken != null) {
        registerFCMDevice(fcmDeviceToken: fcmDeviceToken);
      }
    } catch (_) {
      ApiLogger.warning(
        'Notification registration failed after login',
        tag: 'GOOGLE-AUTH',
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

    final dio = createApiDio();
    final headers = <String, dynamic>{
      'accept': '*/*',
      'X-Api-Key': DRF_API_KEY,
    };
    try {
      final deviceId = await getUniqueDeviceId();
      final query = <String, dynamic>{'device_id': deviceId};

      final response = await dio.post(
        kLoginUsingFirebaseUrl,
        data: data,
        options: Options(headers: headers),
        queryParameters: query,
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
          backgroundColor: AppColors.error,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 203) {
        String message = response.data['message'];
        Get.snackbar(
          'Failed',
          message,
          backgroundColor: AppColors.error,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      authLoading.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please try again.",
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void tryToSignOut() async {
    authLoading.value = true;

    final dio = createApiDio();
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
          backgroundColor: AppColors.error,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      authLoading.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please check your internet connection.",
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
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
    final dio = createApiDio();
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
          backgroundColor: AppColors.success,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else if (statusCode == 203) {
        Get.snackbar(
          'Failed',
          "Your credential is mismatch.",
          backgroundColor: AppColors.error,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Failed',
          "Something is wrong. Please try again.",
          backgroundColor: AppColors.error,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingChangePassword.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please try again.",
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
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
