import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logos/dot_live.png', width: 100, height: 100),
              const SizedBox(height: 16),
              const Text(
                'DOT LIVE',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const SpinKitThreeInOut(color: AppColors.pinkLight, size: 48),
              const SizedBox(height: 20),
              Obx(() {
                final version = controller.appVersionLabel.value;
                if (version.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Text(
                  'Version $version',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
