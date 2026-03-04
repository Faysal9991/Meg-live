import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
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
    var dio = Dio();
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
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already a Moderator",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already Agent / Host / Reseller",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Moderator",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingModeratorRequest.value = false;
    }
  }

  void tryToRemoveModeratorRequest() async {
    loadingModeratorRequest.value = true;
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingModeratorRequest.value = false;
    }
  }

  void loadResellerRequest() async {
    loadingResellerRequest.value = true;
    var dio = Dio();
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
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already an Reseller",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already a Host / Agent / Moderator",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Reseller",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRequest.value = false;
    }
  }

  void tryToRemoveResellerRequest() async {
    loadingResellerRequest.value = true;
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRequest.value = false;
    }
  }

  void loadResellerRechargeHistoryList() async {
    loadingResellerRechargeHistoryList.value = true;
    var dio = Dio();
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

  void tryToRechargeResellerToClient(
      {required int customerId, required int diamonds}) async {
    if (diamonds > authController.profile.value.diamonds!) {
      Get.snackbar(
        'Failed',
        "You haven't sufficient diamonds to recharge the client",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      return;
    }
    loadingResellerRecharge.value = true;
    dynamic data = {
      'customer_id': customerId,
      'diamonds': diamonds,
    };
    var dio = Dio();
    try {
      final response = await dio.post(
        kResellerRechargeCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'X-Api-Key': DRF_API_KEY,
          'Authorization': 'Token ${authController.token.value}',
        }),
        data: data,
      );
      int? statusCode = response.statusCode;
      loadingResellerRecharge.value = false;
      if (statusCode == 201) {
        resellerRechargeHistoryList.insert(
            0, response.data['reseller_history']);
        Get.snackbar(
          'Success',
          "You have recharged $diamonds daimonds",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        final ProfileController profileController = Get.find();
        dynamic profile = profileController.searchedProfile.value;
        profile['diamonds'] += diamonds;
        profileController.searchedProfile.value = profile;
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingResellerRecharge.value = false;
    }
  }

  void tryToDeleteResellerRechargeHistory({required int historyId}) async {
    dynamic data = {'history_id': historyId};

    loadingResellerRechargeHistoryList.value = true;
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
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
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "You are already a Host",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "You are already an Agent / Moderator / Reseller",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 208) {
        Get.snackbar(
          'Failed',
          "You already requested for Host",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Your selected Agent is incorrect",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostRequest.value = false;
    }
  }

  void loadHostRequest() async {
    loadingHostRequest.value = true;
    var dio = Dio();
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
    var dio = Dio();
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
    var dio = Dio();
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
    var dio = Dio();
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
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 226) {
        Get.snackbar(
          'Failed',
          "Candidate is already a Host",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 207) {
        Get.snackbar(
          'Failed',
          "candidate is already an Agent / Moderator / Reseller",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
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
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Incorrect data",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostList.value = false;
    }
  }

  void tryToRemoveHostRequest() async {
    loadingHostRequest.value = true;
    var dio = Dio();
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (statusCode == 204) {
        Get.snackbar(
          'Failed',
          "Something is wrong",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      loadingHostRequest.value = false;
    }
  }

  Future<dynamic> fetchAgentForHost() async {
    var dio = Dio();
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
    var dio = Dio();
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
    var dio = Dio();
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
    var dio = Dio();
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
