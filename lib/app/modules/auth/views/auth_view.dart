import 'package:doyel_live/app/modules/auth/views/registration_view.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/logos/doyel_live.jpeg',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Doyel Live',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Obx(() {
              if (!_authController.authLoading.value) {
                return Container();
              }
              return const SpinKitFadingCircle(
                color: Colors.orange,
                size: 48.0,
              );
            }),
            const SizedBox(height: 32),
            rPrimaryElevatedIconButton(
              buttonText: 'Google Login',
              onPressed: () {
                if (_authController.authLoading.value) {
                  return;
                }

                _authController.tryToSignInWithGoogle();
              },
              primaryColor: Theme.of(context).primaryColor,
              fontSize: 18,
              iconData: MdiIcons.google,
              borderRadius: 8.0,
            ),
            const SizedBox(height: 16),
            rPrimaryElevatedIconButton(
              buttonText: 'Phone Login',
              onPressed: () {
                if (_authController.authLoading.value) {
                  return;
                }

                Get.to(() => const RegistrationView());
              },
              primaryColor: Theme.of(context).primaryColor,
              fontSize: 18,
              iconData: MdiIcons.phone,
              borderRadius: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
