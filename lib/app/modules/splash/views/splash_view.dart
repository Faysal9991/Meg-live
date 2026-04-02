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
              Image.asset(
                'assets/logos/doyel_live.jpeg',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Doyel Live',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const SpinKitThreeInOut(color: Colors.deepPurple, size: 48),
              const SizedBox(height: 20),
              Obx(() {
                final version = controller.appVersionLabel.value;
                if (version.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Text(
                  'Version $version',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
