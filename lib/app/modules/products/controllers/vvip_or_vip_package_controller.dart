import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/products/models/king_package_catalog_state.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:get/get.dart';

class VVIPorVipPackageController extends GetxController {
  VVIPorVipPackageController({Dio? dio}) : _dio = dio ?? Dio();

  final AuthController _authController = Get.find();
  final Dio _dio;

  final loadingAllVVIPPackageList = false.obs;
  final loadingAllVIPPackageList = false.obs;
  final loadingAllKingPackageList = false.obs;
  final loadingEntryEffectPackageList = false.obs;
  final purchasingVVIPPackage = false.obs;
  final purchasingVIPPackage = false.obs;
  final purchasingEntryEffectPackage = false.obs;
  final RxnInt purchasingVVIPPackageId = RxnInt();
  final RxnInt purchasingVIPPackageId = RxnInt();
  final RxnInt purchasingEntryEffectPackageId = RxnInt();
  final purchasingKingPackage = false.obs;
  final RxnInt purchasingKingPackageId = RxnInt();

  final List<dynamic> listAllVvipPackage = <dynamic>[].obs;
  final List<dynamic> listAllVipPackage = <dynamic>[].obs;
  final RxList<KingPackageItem> listAllKingPackage = <KingPackageItem>[].obs;
  final RxList<Map<String, dynamic>> entryEffectPackageList =
      <Map<String, dynamic>>[].obs;

  final purchasedVVipPackage = {}.obs;
  final purchasedVipPackage = {}.obs;
  final vVipPackageOrderingInfo = {}.obs;
  final vipPackageOrderingInfo = {}.obs;
  final Rxn<PurchasedKingPackage> purchasedKingPackage =
      Rxn<PurchasedKingPackage>();
  final kingPackageOrderingInfo = <String, dynamic>{}.obs;
  final purchasedEntryEffectPackage = <String, dynamic>{}.obs;
  bool _kingPackageCatalogLoadedOnce = false;

  Map<String, String> _authHeaders() {
    return {
      'accept': '*/*',
      'Authorization': 'Token ${_authController.token.value}',
      'X-Api-Key': DRF_API_KEY,
    };
  }

  int get currentDiamondBalance => _authController.profile.value.diamonds ?? 0;

  bool get hasActiveKingPackage {
    final purchasedPackage = purchasedKingPackage.value;
    if (purchasedPackage?.kingPackage == null) {
      return false;
    }

    final expiredDatetime = purchasedPackage?.expiredDatetime;
    if (expiredDatetime == null || expiredDatetime.isEmpty) {
      return true;
    }

    final expiry = DateTime.tryParse(expiredDatetime);
    if (expiry == null) {
      return true;
    }

    return expiry.toUtc().isAfter(DateTime.now().toUtc());
  }

  Future<void> ensureKingPackageCatalogLoaded() async {
    if (_kingPackageCatalogLoadedOnce || loadingAllKingPackageList.value) {
      return;
    }
    await loadAllKingPackageList();
  }

  int kingPackageDiamondCost(KingPackageItem packageItem) {
    final dynamic rawCost =
        packageItem.raw['diamonds'] ?? packageItem.raw['price'];
    if (rawCost is int) {
      return rawCost;
    }
    if (rawCost is double) {
      return rawCost.round();
    }
    return int.tryParse(rawCost?.toString() ?? '') ?? packageItem.price.round();
  }

  bool hasEnoughDiamondsForKingPackage(KingPackageItem packageItem) {
    return currentDiamondBalance >= kingPackageDiamondCost(packageItem);
  }

  Map<String, dynamic> _mergeProfileData(Map<String, dynamic> profileData) {
    final merged = Map<String, dynamic>.from(
      _authController.profile.value.toJson(),
    )..addAll(profileData);

    final currentUser = _authController.profile.value.toJson()['user'];
    final nextUser = profileData['user'];
    if (currentUser is Map<String, dynamic> ||
        nextUser is Map<String, dynamic>) {
      merged['user'] = {
        if (currentUser is Map<String, dynamic>) ...currentUser,
        if (nextUser is Map<String, dynamic>) ...nextUser,
      };
    }

    if (merged['vvip_or_vip_preference'] is! String) {
      merged['vvip_or_vip_preference'] = jsonEncode(
        merged['vvip_or_vip_preference'] ?? <String, dynamic>{},
      );
    }

    return merged;
  }

  void _updateProfileFromResponse(Map<String, dynamic> profileData) {
    final mergedProfileData = _mergeProfileData(profileData);
    _authController.profile.value = Profile.fromJson(mergedProfileData);
    _authController.preferences.setString(
      'profile',
      jsonEncode(mergedProfileData),
    );
  }

  void _deductDiamondsLocally(int diamonds) {
    final profile = _authController.profile.value;
    final updatedBalance = currentDiamondBalance - diamonds;
    profile.diamonds = updatedBalance > 0 ? updatedBalance : 0;
    _authController.profile.refresh();
    _authController.preferences.setString('profile', jsonEncode(profile));
  }

  Future<void> loadAllVVIPPackageList() async {
    loadingAllVVIPPackageList.value = true;

    try {
      final response = await _dio.get(
        kPurchasedVvIPPackageListUrl,
        options: Options(headers: _authHeaders()),
      );
      int? statusCode = response.statusCode;
      loadingAllVVIPPackageList.value = false;
      if (statusCode == 200) {
        listAllVvipPackage.clear();
        listAllVvipPackage.addAll(response.data['vvip_package_list']);
        purchasedVVipPackage.value =
            response.data['purchased_vvip_package'] ?? {};
        vVipPackageOrderingInfo.value =
            response.data['vvip_package_ordering_info'] ?? {};
      }
    } catch (e) {
      loadingAllVVIPPackageList.value = false;
    }
  }

  Future<void> loadAllVIPPackageList() async {
    loadingAllVIPPackageList.value = true;

    try {
      final response = await _dio.get(
        kPurchasedVIPPackageListUrl,
        options: Options(headers: _authHeaders()),
      );
      int? statusCode = response.statusCode;
      loadingAllVIPPackageList.value = false;
      if (statusCode == 200) {
        listAllVipPackage.clear();
        listAllVipPackage.addAll(response.data['vip_package_list']);
        purchasedVipPackage.value =
            response.data['purchased_vip_package'] ?? {};
        vipPackageOrderingInfo.value =
            response.data['vip_package_ordering_info'] ?? {};
      }
    } catch (e) {
      loadingAllVIPPackageList.value = false;
    }
  }

  Future<int> purchaseVVIPPackage({required int packageId}) async {
    if (purchasingVVIPPackage.value) {
      return -1;
    }

    purchasingVVIPPackage.value = true;
    purchasingVVIPPackageId.value = packageId;
    try {
      final statusCode = await _purchasePackage(
        url: kVvipPackagePurchaseUrl,
        payload: {'vvip_package_id': packageId},
      );
      if (statusCode == 200 || statusCode == 201) {
        await loadAllVVIPPackageList();
      }
      return statusCode;
    } finally {
      purchasingVVIPPackage.value = false;
      purchasingVVIPPackageId.value = null;
    }
  }

  Future<int> purchaseVIPPackage({required int packageId}) async {
    if (purchasingVIPPackage.value) {
      return -1;
    }

    purchasingVIPPackage.value = true;
    purchasingVIPPackageId.value = packageId;
    try {
      final statusCode = await _purchasePackage(
        url: kVipPackagePurchaseUrl,
        payload: {'vip_package_id': packageId},
      );
      if (statusCode == 200 || statusCode == 201) {
        await loadAllVIPPackageList();
      }
      return statusCode;
    } finally {
      purchasingVIPPackage.value = false;
      purchasingVIPPackageId.value = null;
    }
  }

  Future<int> _purchasePackage({
    required String url,
    required Map<String, dynamic> payload,
  }) async {
    ApiLogger.hit(method: 'POST', url: url, body: payload);

    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: _authHeaders(),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      ApiLogger.response(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        data: response.data,
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode == 200 || statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map && responseData['profile'] is Map) {
          _updateProfileFromResponse(
            Map<String, dynamic>.from(responseData['profile'] as Map),
          );
        }
      }
      return statusCode;
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'POST',
        url: url,
        error: error,
        stackTrace: stackTrace,
        statusCode: error is DioException ? error.response?.statusCode : null,
        data: error is DioException ? error.response?.data : null,
      );
      return 500;
    }
  }

  Future<void> loadEntryEffectPackageList() async {
    if (loadingEntryEffectPackageList.value) {
      return;
    }

    loadingEntryEffectPackageList.value = true;
    ApiLogger.hit(method: 'GET', url: kPurchasedEntryEffectPackageListUrl);
    try {
      final response = await _dio.get(
        kPurchasedEntryEffectPackageListUrl,
        options: Options(headers: _authHeaders()),
      );
      ApiLogger.response(
        method: 'GET',
        url: kPurchasedEntryEffectPackageListUrl,
        statusCode: response.statusCode,
        data: response.data,
      );

      if (response.statusCode != 200 || response.data is! Map) {
        return;
      }
      final responseData = response.data as Map;
      final packages = responseData['entry_effect_package_list'];
      entryEffectPackageList.assignAll(
        packages is List
            ? packages.whereType<Map>().map(
                (item) => Map<String, dynamic>.from(item),
              )
            : const <Map<String, dynamic>>[],
      );

      final purchased = responseData['purchased_entry_effect_package'];
      purchasedEntryEffectPackage.assignAll(
        purchased is Map
            ? Map<String, dynamic>.from(purchased)
            : const <String, dynamic>{},
      );
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'GET',
        url: kPurchasedEntryEffectPackageListUrl,
        error: error,
        stackTrace: stackTrace,
        statusCode: error is DioException ? error.response?.statusCode : null,
        data: error is DioException ? error.response?.data : null,
      );
    } finally {
      loadingEntryEffectPackageList.value = false;
    }
  }

  int entryEffectDiamondCost(Map<String, dynamic> package) {
    final value = package['price'];
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<int> purchaseEntryEffectPackage({required int packageId}) async {
    if (purchasingEntryEffectPackage.value) {
      return -1;
    }

    purchasingEntryEffectPackage.value = true;
    purchasingEntryEffectPackageId.value = packageId;
    try {
      final statusCode = await _purchasePackage(
        url: kPurchasedEntryEffectPackageUrl,
        payload: {'entry_effect_package_id': packageId},
      );
      if (statusCode == 200 || statusCode == 201) {
        await loadEntryEffectPackageList();
      }
      return statusCode;
    } finally {
      purchasingEntryEffectPackage.value = false;
      purchasingEntryEffectPackageId.value = null;
    }
  }

  Future<void> loadAllKingPackageList() async {
    if (loadingAllKingPackageList.value) {
      return;
    }
    loadingAllKingPackageList.value = true;
    ApiLogger.hit(method: 'GET', url: kPurchasedKingPackageListUrl);

    try {
      final response = await _dio.get(
        kPurchasedKingPackageListUrl,
        options: Options(headers: _authHeaders()),
      );
      ApiLogger.response(
        method: 'GET',
        url: kPurchasedKingPackageListUrl,
        statusCode: response.statusCode,
        data: response.data,
      );
      loadingAllKingPackageList.value = false;
      if (response.statusCode == 200) {
        final state = KingPackageCatalogState.fromJson(response.data);
        listAllKingPackage.assignAll(state.kingPackageList);
        purchasedKingPackage.value = state.purchasedKingPackage;
        kingPackageOrderingInfo.value = state.kingPackageOrderingInfo;
        _kingPackageCatalogLoadedOnce = true;
      }
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'GET',
        url: kPurchasedKingPackageListUrl,
        error: error,
        stackTrace: stackTrace,
      );
      loadingAllKingPackageList.value = false;
    }
  }

  Future<int> purchaseKingPackage({
    required KingPackageItem packageItem,
  }) async {
    if (purchasingKingPackage.value) {
      return -1;
    }

    purchasingKingPackage.value = true;
    purchasingKingPackageId.value = packageItem.id;
    final payload = {'product_type': 'king', 'product_id': packageItem.id};
    ApiLogger.hit(method: 'POST', url: kPurchasedKingPackageUrl, body: payload);

    try {
      final response = await _dio.post(
        kPurchasedKingPackageUrl,
        data: payload,
        options: Options(
          headers: _authHeaders(),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      ApiLogger.response(
        method: 'POST',
        url: kPurchasedKingPackageUrl,
        statusCode: response.statusCode,
        data: response.data,
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode == 200 || statusCode == 201) {
        final profileData = response.data['profile'];
        if (profileData is Map<String, dynamic>) {
          _updateProfileFromResponse(profileData);
        } else {
          _deductDiamondsLocally(kingPackageDiamondCost(packageItem));
        }
        await loadAllKingPackageList();
      }
      return statusCode;
    } catch (error, stackTrace) {
      ApiLogger.error(
        method: 'POST',
        url: kPurchasedKingPackageUrl,
        error: error,
        stackTrace: stackTrace,
      );
      return 500;
    } finally {
      purchasingKingPackage.value = false;
      purchasingKingPackageId.value = null;
    }
  }
}
