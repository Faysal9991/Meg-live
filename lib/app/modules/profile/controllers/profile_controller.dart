import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

class ProfileController extends GetxController {
  final listLoading = false.obs;
  final loadingProfile = false.obs;
  final loadingProfileSearch = false.obs;
  final loadingPerformFollow = 0.obs;
  final loadingPerformBlock = 0.obs;
  final loadingProfileForUserInfo = false.obs;
  final loadingProfileForHost = false.obs;
  final loadingCoverImageDeletion = false.obs;
  final loadingHostBroadcastingHistories = false.obs;

  final selectedBirthDate = DateTime.now().obs;
  final selectedProfileImageFile = File('').obs;
  final selectedCoverImageFile = File('').obs;
  final accountFollowers = <dynamic>[].obs;
  final hostAccountFollowers = <dynamic>[].obs;
  final listHostBroadcastingHistory = <dynamic>[].obs;

  final listBlockWithProfile = <dynamic>[].obs;
  final searchedProfile = {}.obs;
  dynamic profileForUserInfo;

  final profileForHost = {}.obs;

  String? _selectedProfileImageExtension;
  String? _selectedCoverImageExtension;

  void setAccountFollowers(List<dynamic> followers) {
    accountFollowers.clear();
    accountFollowers.addAll(followers);
  }

  void setHostAccountFollowers(List<dynamic> followers) {
    hostAccountFollowers.clear();
    hostAccountFollowers.addAll(followers);
  }

  void clearUploadedFiles() {
    selectedProfileImageFile.value = File('');
    selectedCoverImageFile.value = File('');
  }

  void clearSearchField() {
    searchedProfile.value = {};
  }

  void putPageProfileImage({required File file, required String extension}) {
    selectedProfileImageFile.value = file;
    _selectedProfileImageExtension = extension;
  }

  void putPageCoverImage({required File file, required String extension}) {
    selectedCoverImageFile.value = file;
    _selectedCoverImageExtension = extension;
  }

  void tryToSearchProfile({required int userId}) async {
    loadingProfileSearch.value = true;
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kProfileRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingProfileSearch.value = false;
      if (statusCode == 200) {
        searchedProfile.value = response.data['profile'] ?? {};
      }
    } catch (e) {
      loadingProfileSearch.value = false;
    }
  }

  Future<dynamic> fetchProfile({required int userId}) async {
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kProfileRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        return response.data['profile'];
      }
    } catch (e) {
      //
    }
    return null;
  }

  void fetchProfileForUserInfo({required int userId}) async {
    if (loadingProfileForUserInfo.value) {
      return;
    }
    loadingProfileForUserInfo.value = true;
    profileForUserInfo = null;
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kProfileForUserInfoRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingProfileForUserInfo.value = false;
      if (statusCode == 200) {
        setAccountFollowers(response.data['profile']['followers']);

        profileForUserInfo = response.data['profile'];
      }
    } catch (e) {
      loadingProfileForUserInfo.value = false;
    }
  }

  void fetchProfileForHost({required int userId}) async {
    if (loadingProfileForHost.value) {
      return;
    }
    loadingProfileForHost.value = true;
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kProfileForUserInfoRetrieveUrl(userId),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingProfileForHost.value = false;
      if (statusCode == 200) {
        setHostAccountFollowers(response.data['profile']['followers']);

        profileForHost.value = response.data['profile'];
      }
    } catch (e) {
      loadingProfileForHost.value = false;
    }
  }

  void tryToUpdateProfile({
    required String fullName,
  }) async {
    loadingProfile.value = true;
    final AuthController authController = Get.find();
    var dio = Dio();
    FormData formData = FormData.fromMap({
      'full_name': fullName,
      'profile_image': selectedProfileImageFile.value.path != ''
          ? await MultipartFile.fromFile(selectedProfileImageFile.value.path,
              filename: _selectedProfileImageExtension)
          : null,
    });
    try {
      final response = await dio.put(
        kProfileUpdateUrl,
        data: formData,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
          'Content-Type': 'multipart/form-data'
        }),
      );
      int? statusCode = response.statusCode;
      loadingProfile.value = false;
      if (statusCode == 200) {
        authController.profile.value = Profile();
        authController.profile.value =
            Profile.fromJson(response.data['profile']);
        authController.preferences
            .setString('profile', jsonEncode(response.data['profile']));

        Get.snackbar(
          'Success',
          "Your profile has been updated.",
          backgroundColor: Colors.green,
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
      loadingProfile.value = false;
      Get.snackbar(
        'Failed',
        "Something is wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<List<dynamic>> performFollow({required int uid}) async {
    loadingPerformFollow.value = uid;
    final AuthController authController = Get.find();

    var dio = Dio();
    final response = await dio.post(
      kFollowerCreateUrl(uid),
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token ${authController.token.value}',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
    int? statusCode = response.statusCode;
    loadingPerformFollow.value = 0;
    if (statusCode == 201) {
      // List<int> followers = response.data['followers'] == null
      //     ? []
      //     : (response.data['followers'] as List)
      //         .map((x) => int.parse(x.toString()))
      //         .toList();
      // return followers;
      return response.data['followers'];
    }

    return [];
  }

  Future<List<dynamic>> performBlock({required int uid}) async {
    loadingPerformBlock.value = uid;
    final AuthController authController = Get.find();

    var dio = Dio();
    final response = await dio.post(
      kBlockCreateUrl(uid),
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token ${authController.token.value}',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
    int? statusCode = response.statusCode;
    loadingPerformBlock.value = 0;
    if (statusCode == 201) {
      // List<int> blocks = response.data['blocks'] == null
      //     ? []
      //     : (response.data['blocks'] as List)
      //         .map((x) => int.parse(x.toString()))
      //         .toList();
      // return blocks;
      return response.data['blocks'];
    }

    return [];
  }

  Future<List<dynamic>> fecthFollowerList() async {
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kFollowerListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        return response.data['list_user_with_profile'];
      }
    } catch (e) {
      //
    }
    return [];
  }

  void fecthBlockList() async {
    listLoading.value = true;
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kBlockListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      listLoading.value = false;
      if (statusCode == 200) {
        listBlockWithProfile.clear();
        listBlockWithProfile.addAll(response.data['list_user_with_profile']);
      }
    } catch (e) {
      listLoading.value = false;
    }
  }

  void setRemoveFromBlockList({required int uid}) {
    listBlockWithProfile.removeWhere((element) => element['id'] == uid);
    final AuthController authController = Get.find();
    Profile profile = authController.profile.value;
    profile.blocks = listBlockWithProfile;
    authController.profile.value = Profile();
    authController.profile.value = profile;
    authController.preferences
        .setString('profile', jsonEncode(profile.toJson()));
  }

  Future<List<dynamic>> fecthBroadcastingHistories() async {
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      final response = await dio.get(
        kBroadcastingHistoryListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        return response.data['broadcaster_histories'];
      }
    } catch (e) {
      //
    }
    return [];
  }

  void tryToSearchHostBroadcastingHistories({
    required int uid,
    int? agentUserId,
  }) async {
    final AuthController authController = Get.find();
    var dio = Dio();
    try {
      loadingHostBroadcastingHistories.value = true;
      listHostBroadcastingHistory.clear();
      final response = await dio.get(
        kBroadcastingHistoryAgentViewListUrl(userId: uid),
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${authController.token.value}',
          // 'X-Api-Key': DRF_API_KEY,
        }),
        queryParameters: {
          'is_agent_search': true,
          'agent_uid': agentUserId ?? 0,
        },
      );
      int? statusCode = response.statusCode;
      loadingHostBroadcastingHistories.value = false;
      if (statusCode == 200) {
        listHostBroadcastingHistory
            .addAll(response.data['broadcaster_histories']);
      }
    } catch (e) {
      loadingHostBroadcastingHistories.value = false;
    }
  }
}
