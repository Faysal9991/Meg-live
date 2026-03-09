import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/balance/models/withdraw_models.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:get/get.dart';

class BalanceController extends GetxController {
  BalanceController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final AuthController _authController = Get.find();

  final loadingWithdrawRequests = false.obs;
  final loadingWithdrawOptions = false.obs;
  final creatingWithdrawRequest = false.obs;

  final RxList<WithdrawRequestItem> withdrawRequests =
      <WithdrawRequestItem>[].obs;
  final RxList<WithdrawPackageOption> withdrawPackages =
      <WithdrawPackageOption>[].obs;
  final RxList<PaymentMethodOption> paymentMethods =
      <PaymentMethodOption>[].obs;

  Map<String, String> _authHeaders() {
    return {
      'accept': '*/*',
      'Authorization': 'Token ${_authController.token.value}',
      'X-Api-Key': DRF_API_KEY,
    };
  }

  Future<void> loadWithdrawRequests() async {
    if (loadingWithdrawRequests.value) {
      return;
    }
    loadingWithdrawRequests.value = true;
    ApiLogger.hit(method: 'GET', url: kWithdrawRequestListUrl);
    try {
      final response = await _dio.get(
        kWithdrawRequestListUrl,
        options: Options(headers: _authHeaders()),
      );
      ApiLogger.response(
        method: 'GET',
        url: kWithdrawRequestListUrl,
        statusCode: response.statusCode,
        data: response.data,
      );
      loadingWithdrawRequests.value = false;
      if (response.statusCode == 200) {
        final data =
            response.data['withdraw_request_list'] as List? ?? const [];
        withdrawRequests.assignAll(
          data
              .map(
                (dynamic item) => WithdrawRequestItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      }
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'GET',
        url: kWithdrawRequestListUrl,
        error: error,
        stackTrace: stackTrace,
      );
      loadingWithdrawRequests.value = false;
    }
  }

  Future<void> loadWithdrawOptions() async {
    if (loadingWithdrawOptions.value) {
      return;
    }
    loadingWithdrawOptions.value = true;
    ApiLogger.hit(method: 'GET', url: kWithdrawPackageListUrl);
    ApiLogger.hit(method: 'GET', url: kPaymentMethodListUrl);
    try {
      final responses = await Future.wait([
        _dio.get(
          kWithdrawPackageListUrl,
          options: Options(headers: _authHeaders()),
        ),
        _dio.get(
          kPaymentMethodListUrl,
          options: Options(headers: _authHeaders()),
        ),
      ]);

      final packageResponse = responses[0];
      final paymentMethodResponse = responses[1];
      ApiLogger.response(
        method: 'GET',
        url: kWithdrawPackageListUrl,
        statusCode: packageResponse.statusCode,
        data: packageResponse.data,
      );
      ApiLogger.response(
        method: 'GET',
        url: kPaymentMethodListUrl,
        statusCode: paymentMethodResponse.statusCode,
        data: paymentMethodResponse.data,
      );

      if (packageResponse.statusCode == 200) {
        final data =
            packageResponse.data['withdraw_packages'] as List? ?? const [];
        withdrawPackages.assignAll(
          data
              .map(
                (dynamic item) => WithdrawPackageOption.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      }

      if (paymentMethodResponse.statusCode == 200) {
        final data =
            paymentMethodResponse.data['payment_methods'] as List? ?? const [];
        paymentMethods.assignAll(
          data
              .map(
                (dynamic item) => PaymentMethodOption.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      }
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'GET',
        url: '$kWithdrawPackageListUrl | $kPaymentMethodListUrl',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      loadingWithdrawOptions.value = false;
    }
  }

  Future<int> createWithdrawRequest({
    required WithdrawRequestCreateRequest request,
  }) async {
    if (creatingWithdrawRequest.value) {
      return -1;
    }
    creatingWithdrawRequest.value = true;
    final payload = request.toJson();
    ApiLogger.hit(
      method: 'POST',
      url: kWithdrawRequestCreateUrl,
      body: payload,
    );
    try {
      final response = await _dio.post(
        kWithdrawRequestCreateUrl,
        data: payload,
        options: Options(
          headers: _authHeaders(),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      ApiLogger.response(
        method: 'POST',
        url: kWithdrawRequestCreateUrl,
        statusCode: response.statusCode,
        data: response.data,
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode == 200 || statusCode == 201) {
        final profileData = response.data['profile'];
        if (profileData is Map<String, dynamic>) {
          _authController.profile.value = Profile();
          _authController.profile.value = Profile.fromJson(profileData);
          _authController.preferences.setString(
            'profile',
            jsonEncode(profileData),
          );
        }
        await loadWithdrawRequests();
      }
      return statusCode;
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'POST',
        url: kWithdrawRequestCreateUrl,
        error: error,
        stackTrace: stackTrace,
      );
      return 500;
    } finally {
      creatingWithdrawRequest.value = false;
    }
  }
}
