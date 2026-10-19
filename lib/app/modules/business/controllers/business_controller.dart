import 'dart:convert';

import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

class BusinessController extends GetxController {
  final AuthController authController = Get.find();

  final loadingModeratorRequest = false.obs;

  final loadingAgentList = false.obs;
  final loadingAgentSearch = false.obs;
  final loadingAgentRequest = false.obs;

  final loadingResellerRequest = false.obs;
  final loadingResellerRecharge = false.obs;
  final loadingResellerRechargeHistoryList = false.obs;

  final loadingHostList = false.obs;
  final loadingHostRequestList = false.obs;
  final loadingHostRequest = false.obs;
  final loadingHostRequestSearch = false.obs;
  final loadingHostRequestConfirmation = false.obs;
  final loadingCoinsConvertion = false.obs;
  final loadingAgentRechargeHistoryList = false.obs;
  final loadingAgentRecharge = false.obs;

  final moderatorRequestedData = {}.obs;
  final agentRequestedData = {}.obs;
  final resellerRequestedData = {}.obs;
  final hostRequestedData = {}.obs;
  final searchedAgentData = {}.obs;
  final searchedHostRequestedData = {}.obs;
  final agentList = [].obs;
  final agentListForHost = [].obs;
  final hostList = [].obs;
  final allowHostRemove = false.obs;
  final hostRequestList = [].obs;
  final hostsGiftCoins = 0.obs;
  final hostsAudioGiftCoins = 0.obs;
  final hostsVideoGiftCoins = 0.obs;
  final hostsCount = 0.obs;
  final resellerRechargeHistoryList = [].obs;
  final agentRechargeHistoryList = [].obs;

  void loadModeratorRequest() async {
    loadingModeratorRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kModeratorRequestRetrieveUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingModeratorRequest.value = false;
      if (statusCode == 200) {
        moderatorRequestedData.value = response.data['moderator_request'];
      }
    } catch (e) {
      loadingModeratorRequest.value = false;
    }
  }

  void tryToSendModeratorRequest() async {
    loadingModeratorRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.post(
        kModeratorRequestCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingModeratorRequest.value = false;
      if (statusCode == 201) {
        moderatorRequestedData.value = response.data['moderator_request'];
        Get.snackbar(
          'Success',
          "Your request is pending now",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already a Moderator",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already Agent / Host / Reseller",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Moderator",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingModeratorRequest.value = false;
    }
  }

  void tryToRemoveModeratorRequest() async {
    loadingModeratorRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.delete(
        kModeratorRequestDeleteUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingModeratorRequest.value = false;
      if (statusCode == 200) {
        moderatorRequestedData.value = {};
        Get.snackbar(
          'Success',
          "Your request has been removed",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingModeratorRequest.value = false;
    }
  }

  void loadResellerRequest() async {
    loadingResellerRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kResellerRequestRetrieveUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingResellerRequest.value = false;
      if (statusCode == 200) {
        resellerRequestedData.value = response.data['reseller_request'];
      }
    } catch (e) {
      loadingResellerRequest.value = false;
    }
  }

  void tryToSendResellerRequest() async {
    loadingResellerRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.post(
        kResellerRequestCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingResellerRequest.value = false;
      if (statusCode == 201) {
        resellerRequestedData.value = response.data['reseller_request'];
        Get.snackbar(
          'Success',
          "Your request is pending now",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already an Reseller",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already a Host / Agent / Moderator",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Reseller",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRequest.value = false;
    }
  }

  void tryToRemoveResellerRequest() async {
    loadingResellerRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.delete(
        kResellerRequestDeleteUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingResellerRequest.value = false;
      if (statusCode == 200) {
        resellerRequestedData.value = {};
        Get.snackbar(
          'Success',
          "Your request has been removed",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRequest.value = false;
    }
  }

  void loadResellerRechargeHistoryList() async {
    loadingResellerRechargeHistoryList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kResellerRechargeHistoryListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
      );
      int? statusCode = response.statusCode;
      loadingResellerRechargeHistoryList.value = false;
      if (statusCode == 200) {
        resellerRechargeHistoryList.clear();
        resellerRechargeHistoryList.addAll(response.data['reseller_histories']);
      }
    } catch (e) {
      loadingResellerRechargeHistoryList.value = false;
    }
  }

  void tryToRechargeResellerToClient({
    required int customerId,
    required int diamonds,
  }) async {
    // No idempotency key on this endpoint: never allow a second submission
    // while one is in flight.
    if (loadingResellerRecharge.value) return;
    if (diamonds > authController.profile.value.diamonds!) {
      Get.snackbar(
        'Failed',
        "You haven't sufficient diamonds to recharge the client",
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      return;
    }
    loadingResellerRecharge.value = true;
    dynamic data = {'customer_id': customerId, 'diamonds': diamonds};
    final dio = createApiDio();
    try {
      final response = await dio.post(
        kResellerRechargeCreateUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'X-Api-Key': DRF_API_KEY,
            'Authorization': 'Token ${authController.token.value}',
          },
        ),
        data: data,
      );
      int? statusCode = response.statusCode;
      if (statusCode == 201) {
        final body = response.data is Map ? response.data as Map : const {};
        if (body['reseller_history'] != null) {
          resellerRechargeHistoryList.insert(0, body['reseller_history']);
        }
        _applyRechargeProfiles(
          body: body,
          customerId: customerId,
          diamonds: diamonds,
        );
        Get.snackbar(
          'Success',
          "You have recharged $diamonds daimonds",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        // Not completed: insufficient funds, unavailable customer, self-sale
        // or ineligible seller. Nothing was transferred.
        Get.snackbar(
          'Failed',
          'Recharge was not completed. Check your balance and the user ID.',
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 400) {
        Get.snackbar(
          'Failed',
          _validationMessage(e.response?.data),
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 401) {
        Get.snackbar(
          'Failed',
          'Your session has expired. Please log in again.',
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // The transfer may have committed; establish the result from the
        // server instead of assuming success or failure.
        Get.snackbar(
          'Please check',
          'Could not confirm the recharge. Refreshing balances before you try again.',
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
        await _refreshAfterUncertainRecharge(customerId: customerId);
      }
    } catch (_) {
      await _refreshAfterUncertainRecharge(customerId: customerId);
    } finally {
      loadingResellerRecharge.value = false;
    }
  }

  /// Applies the 201 profiles to the right users: `reseller_profile` to the
  /// logged-in reseller, `customer_profile` only to the searched customer.
  void _applyRechargeProfiles({
    required Map body,
    required int customerId,
    required int diamonds,
  }) {
    final resellerProfile = body['reseller_profile'];
    if (resellerProfile is Map &&
        _uidOf(resellerProfile) == authController.profile.value.user?.uid) {
      _applyOwnProfile(Map<String, dynamic>.from(resellerProfile));
    }

    final ProfileController profileController = Get.find();
    final searched = Map<String, dynamic>.from(
      profileController.searchedProfile,
    );
    if (_uidOf(searched) != customerId) return;
    final customerProfile = body['customer_profile'];
    if (customerProfile is Map && _uidOf(customerProfile) == customerId) {
      searched.addAll(Map<String, dynamic>.from(customerProfile));
    } else {
      // Backend without customer_profile: keep the previous local display.
      searched['diamonds'] = (searched['diamonds'] ?? 0) + diamonds;
    }
    profileController.searchedProfile.value = searched;
  }

  Future<void> _refreshAfterUncertainRecharge({required int customerId}) async {
    final ProfileController profileController = Get.find();
    loadResellerRechargeHistoryList();
    final ownUid = authController.profile.value.user?.uid;
    final results = await Future.wait([
      if (ownUid != null) profileController.fetchProfile(userId: ownUid),
      profileController.fetchProfile(userId: customerId),
    ]);
    if (ownUid != null &&
        results.first is Map &&
        _uidOf(results.first) == ownUid) {
      _applyOwnProfile(Map<String, dynamic>.from(results.first));
    }
    final customer = results.last;
    if (customer is Map &&
        _uidOf(customer) == customerId &&
        _uidOf(profileController.searchedProfile) == customerId) {
      profileController.searchedProfile.value = Map<String, dynamic>.from(
        customer,
      );
    }
  }

  void _applyOwnProfile(Map<String, dynamic> profileData) {
    // Partial payloads must not erase fields the response did not include.
    final merged = authController.profile.value.mergedJson(profileData);
    authController.profile.value = Profile();
    authController.profile.value = Profile.fromJson(merged);
    authController.preferences.setString('profile', jsonEncode(merged));
  }

  static int? _uidOf(dynamic profile) {
    final user = profile is Map ? profile['user'] : null;
    return user is Map ? int.tryParse('${user['uid']}') : null;
  }

  static String _validationMessage(dynamic data) {
    if (data is Map && data.isNotEmpty) {
      return data.values
          .map((value) => value is List ? value.join(' ') : '$value')
          .join('\n');
    }
    if (data is String && data.isNotEmpty) return data;
    return 'Invalid recharge request.';
  }

  void tryToDeleteResellerRechargeHistory({required int historyId}) async {
    dynamic data = {'history_id': historyId};

    loadingResellerRechargeHistoryList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.delete(
        kResellerRechargeHistoryDeletetUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingResellerRechargeHistoryList.value = false;

      if (statusCode == 200) {
        resellerRechargeHistoryList
            .removeWhere((element) => element['id'] == historyId);
        Get.snackbar(
          'Success',
          "History removed successfully",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRechargeHistoryList.value = false;
    }
  }

  void tryToSendHostRequest(
      {required int agentId, String liveType = 'video'}) async {
    dynamic data = {
      'agent_id': agentId,
      'live_type': liveType,
    };
    loadingHostRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.post(
        kHostRequestCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingHostRequest.value = false;
      if (statusCode == 201) {
        hostRequestedData.value = response.data['host_request'];
        Get.snackbar(
          'Success',
          "Your request is pending now",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already a Host",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already an Agent / Moderator / Reseller",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Host",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Your selected Agent is incorrect",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostRequest.value = false;
    }
  }

  void loadHostRequest() async {
    loadingHostRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kHostRequestRetrieveUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingHostRequest.value = false;
      if (statusCode == 200) {
        hostRequestedData.value = response.data['host_request'];
      }
    } catch (e) {
      loadingHostRequest.value = false;
    }
  }

  void tryToSearchHostRequest({
    required int userId,
    int? agentUserId,
  }) async {
    loadingHostRequestSearch.value = true;
    final AuthController authController = Get.find();
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kSearchHostRequestRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        queryParameters: {'agent_uid': agentUserId ?? 0},
      );
      int? statusCode = response.statusCode;
      loadingHostRequestSearch.value = false;
      if (statusCode == 200) {
        searchedHostRequestedData.value = response.data['host_request'] ?? {};
      }
    } catch (e) {
      loadingHostRequestSearch.value = false;
    }
  }

  void loadHostRequestList({
    int? agentUserId,
  }) async {
    loadingHostRequestList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kHostRequestListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        queryParameters: {
          'agent_uid': agentUserId ?? 0,
        },
      );
      int? statusCode = response.statusCode;
      loadingHostRequestList.value = false;
      if (statusCode == 200) {
        hostRequestList.clear();
        hostRequestList.addAll(response.data['host_request_list']);
      }
    } catch (e) {
      loadingHostRequestList.value = false;
    }
  }

  void loadHostList({
    int? agentUserId,
  }) async {
    hostsGiftCoins.value = 0;
    hostsAudioGiftCoins.value = 0;
    hostsVideoGiftCoins.value = 0;
    hostsCount.value = 0;

    loadingHostList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kHostListeUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        queryParameters: {'agent_uid': agentUserId ?? 0},
      );
      int? statusCode = response.statusCode;
      loadingHostList.value = false;
      if (statusCode == 200) {
        dynamic responseData = response.data;
        hostList.clear();
        hostList.addAll(responseData['hosts']);
        hostsGiftCoins.value = responseData['hosts_diamonds'];
        hostsAudioGiftCoins.value = responseData['hosts_audio_diamonds'];
        hostsVideoGiftCoins.value = responseData['hosts_video_diamonds'];
        hostsCount.value = responseData['hosts_count'];
        allowHostRemove.value = responseData['allow_remove'];
      }
    } catch (e) {
      loadingHostList.value = false;
    }
  }

  void tryToConfirmHostRequest({
    required int userId,
    int? agentUserId,
  }) async {
    dynamic data = {
      'host_uid': userId,
      'agent_uid': agentUserId ?? 0,
    };

    loadingHostRequestConfirmation.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.post(
        kConfirmHostRequestCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingHostRequestConfirmation.value = false;
      hostRequestList.removeWhere(
          (element) => element['profile']['user']['uid'] == userId);
      if (statusCode == 201) {
        Get.snackbar(
          'Success',
          "Host request has been confirmed",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "Candidate is already a Host",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "candidate is already an Agent / Moderator / Reseller",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostRequestConfirmation.value = false;
    }
  }

  void tryToRemoveHost(
      {required int userId,
      int? agentUserId,
      required dynamic profileData}) async {
    dynamic data = {
      'host_uid': userId,
      'agent_uid': agentUserId ?? 0,
    };

    loadingHostList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.delete(
        kHostRemoveUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingHostList.value = false;

      if (statusCode == 200) {
        hostList.removeWhere(
            (element) => element['profile']['user']['uid'] == userId);
        hostsCount.value -= 1;
        hostsGiftCoins.value -= profileData['diamonds'] as int;
        if (profileData['is_allow_video_live']) {
          hostsVideoGiftCoins.value -= profileData['diamonds'] as int;
        } else {
          hostsAudioGiftCoins.value -= profileData['diamonds'] as int;
        }
        Get.snackbar(
          'Success',
          "Host removed successfully",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostList.value = false;
    }
  }

  void tryToRemoveHostRequest() async {
    loadingHostRequest.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.delete(
        kHostRequestDeleteUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingHostRequest.value = false;
      if (statusCode == 200) {
        hostRequestedData.value = {};
        Get.snackbar(
          'Success',
          "Your request has been removed",
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostRequest.value = false;
    }
  }

  Future<dynamic> fetchAgentForHost() async {
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kAgentForHostRetrieveUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        return response.data['agent'];
      }
    } catch (e) {
      return null;
    }
  }

  void loadAgentList() async {
    loadingAgentList.value = true;
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kManualAgentListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingAgentList.value = false;
      if (statusCode == 200) {
        agentList.clear();
        agentList.addAll(response.data['manual_agent_list']);
      }
    } catch (e) {
      loadingAgentList.value = false;
    }
  }

  void loadAgentListForHostRequest() async {
    loadingAgentList.value = true;
    hostRequestedData.value = {};
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kAgentListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingAgentList.value = false;
      if (statusCode == 200) {
        agentListForHost.clear();
        agentListForHost.addAll(response.data['manual_agent_list']);
        hostRequestedData.value = response.data['host_request'];
      }
    } catch (e) {
      loadingAgentList.value = false;
    }
  }

  void tryToSearchAgent({required int userId}) async {
    loadingAgentSearch.value = true;
    final AuthController authController = Get.find();
    final dio = createApiDio();
    try {
      final response = await dio.get(
        kSearchAgentRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingAgentSearch.value = false;
      if (statusCode == 200) {
        searchedAgentData.value = response.data['agent'] ?? {};
      }
    } catch (e) {
      loadingAgentSearch.value = false;
    }
  }
}
