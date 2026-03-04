import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../controllers/splash_controller.dart';

void _checkServerLockedVersion() {
  final AuthController authController = Get.find();
  if (authController.token.value.isEmpty) {
    Get.offNamed(Routes.AUTH);
  } else {
    Get.offNamed(Routes.NAV);
  }
  // authController.tryToGetAppLockedBuildNumber().then((serverBuildNumber) async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String buildNumber = packageInfo.buildNumber;
  //   if (serverBuildNumber.toString() == buildNumber) {
  //     // Get.off(() => const MaintenanceIssueView());
  //     // authController.tryToLoginWithDummyAccount();
  //   } else {
  //     AuthController authController;
  //     try {
  //       authController = Get.find();
  //     } catch (e) {
  //       authController = Get.put(AuthController());
  //     }

  //     if (authController.token.value.isEmpty) {
  //       Get.offNamed(Routes.AUTH);
  //     } else {
  //       Get.offNamed(Routes.NAV);
  //     }
  //   }
  // });
}

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      // _advancedStatusCheck(context: context);
      _checkServerLockedVersion();
    });
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logos/doyel_live.jpeg',
            width: 100,
            height: 100,
          ),
          const SizedBox(
            height: 16,
          ),
          const Center(
            child: Text(
              'Doyel Live',
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const SpinKitThreeInOut(
            color: Colors.deepPurple,
            size: 48.0,
          ),
        ],
      ),
    );
  }
}
