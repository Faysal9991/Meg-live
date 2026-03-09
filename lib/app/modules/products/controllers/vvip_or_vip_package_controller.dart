import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/products/models/king_package_catalog_state.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

class VVIPorVipPackageController extends GetxController {
  VVIPorVipPackageController({Dio? dio}) : _dio = dio ?? Dio();

  final AuthController _authController = Get.find();
  final Dio _dio;

  final loadingAllVVIPPackageList = false.obs;
  final loadingAllVIPPackageList = false.obs;
  final loadingAllKingPackageList = false.obs;

  final List<dynamic> listAllVvipPackage = <dynamic>[].obs;
  final List<dynamic> listAllVipPackage = <dynamic>[].obs;
  final RxList<KingPackageItem> listAllKingPackage = <KingPackageItem>[].obs;

  final purchasedVVipPackage = {}.obs;
  final purchasedVipPackage = {}.obs;
  final vVipPackageOrderingInfo = {}.obs;
  final vipPackageOrderingInfo = {}.obs;
  final Rxn<PurchasedKingPackage> purchasedKingPackage =
      Rxn<PurchasedKingPackage>();
  final kingPackageOrderingInfo = <String, dynamic>{}.obs;

  void loadAllVVIPPackageList() async {
    loadingAllVVIPPackageList.value = true;

    try {
      final response = await _dio.get(
        kPurchasedVvIPPackageListUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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

  void loadAllVIPPackageList() async {
    loadingAllVIPPackageList.value = true;

    try {
      final response = await _dio.get(
        kPurchasedVIPPackageListUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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

  void loadAllKingPackageList() async {
    if (loadingAllKingPackageList.value) {
      return;
    }
    loadingAllKingPackageList.value = true;
    ApiLogger.hit(method: 'GET', url: kPurchasedKingPackageListUrl);

    try {
      final response = await _dio.get(
        kPurchasedKingPackageListUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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
}
