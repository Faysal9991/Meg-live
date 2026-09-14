import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';

class DevicesController extends GetxController {
  final AuthController authController = Get.find();
  final loadingUserDeviceInfo = false.obs;
  final loadingBlockedDevicesHistories = false.obs;
  final userDevicesInfoList = [].obs;
  final userBlockedDevicesList = [].obs;

  void tryToSearchUserDevicesInfoForUserId({required int userId}) async {
    loadingUserDeviceInfo.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kSearchUserDeviceInfoListUrl(userId: userId),
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingUserDeviceInfo.value = false;
      if (statusCode == 200) {
        userDevicesInfoList.clear();
        userDevicesInfoList.addAll(response.data['user_devices_info']);
      }
    } catch (e) {
      loadingUserDeviceInfo.value = false;
    }
  }

  void loadModeratorBlockedUserDevices() async {
    loadingBlockedDevicesHistories.value = true;

    final dio = createApiDio();
    try {
      final response = await dio.get(
        kUserDeviceBlockedHistoryListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingBlockedDevicesHistories.value = false;
      if (statusCode == 200) {
        userBlockedDevicesList.clear();
        userBlockedDevicesList.addAll(response.data['user_blocked_devices']);
      }
    } catch (e) {
      loadingBlockedDevicesHistories.value = false;
    }
  }

  void tryToModeratorBlockUserDevice({
    required int userId,
    required String deviceId,
  }) async {
    loadingUserDeviceInfo.value = true;

    final dio = createApiDio();
    dynamic data = {
      'user_id': userId,
      'device_id': deviceId,
    };
    try {
      final response = await dio.post(
        kUserDeviceBlockCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingUserDeviceInfo.value = false;
      if (statusCode == 203) {
        Get.snackbar(
          'No Access',
          'You are not allowed to perform action.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          'Something is wrong. Please try again.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 201) {
        Get.snackbar(
          'Success',
          'Device has been blocked.',
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
        userDevicesInfoList
            .removeWhere((element) => element['device_id'] == deviceId);
      }
    } catch (e) {
      loadingUserDeviceInfo.value = false;
    }
  }
}
