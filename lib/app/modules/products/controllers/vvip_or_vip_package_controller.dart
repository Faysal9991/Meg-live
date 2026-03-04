import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

class VVIPorVipPackageController extends GetxController {
  final AuthController _authController = Get.find();

  final loadingAllVVIPPackageList = false.obs;
  final loadingAllVIPPackageList = false.obs;

  final List<dynamic> listAllVvipPackage = <dynamic>[].obs;
  final List<dynamic> listAllVipPackage = <dynamic>[].obs;

  final purchasedVVipPackage = {}.obs;
  final purchasedVipPackage = {}.obs;
  final vVipPackageOrderingInfo = {}.obs;
  final vipPackageOrderingInfo = {}.obs;

  void loadAllVVIPPackageList() async {
    loadingAllVVIPPackageList.value = true;
    var dio = Dio();

    try {
      final response = await dio.get(
        kPurchasedVvIPPackageListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${_authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
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
    var dio = Dio();

    try {
      final response = await dio.get(
        kPurchasedVIPPackageListUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${_authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
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
}
