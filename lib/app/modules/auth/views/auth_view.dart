import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_spacing.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/modules/auth/views/registration_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 48).clamp(0, double.infinity),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: AppCard(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        child: Transform.scale(
                          scale: 1.8,
                          child: Image.asset(
                            'assets/logos/dot_live.png',
                            width: 104,
                            height: 104,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'DOT LIVE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your people. Your moments.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome to your community',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to discover live rooms, connect, and share a little of your world.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => PrimaryButton(
                              label: 'Google Login',
                              icon: MdiIcons.google,
                              onPressed: _authController.authLoading.value
                                  ? null
                                  : () =>
                                        _authController.tryToSignInWithGoogle(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => PrimaryButton(
                              label: 'Phone Login',
                              icon: Icons.phone_outlined,
                              backgroundColor: AppColors.surfaceHigh,
                              foregroundColor: AppColors.textPrimary,
                              onPressed: _authController.authLoading.value
                                  ? null
                                  : () =>
                                        Get.to(() => const RegistrationView()),
                            ),
                          ),
                          Obx(
                            () => _authController.authLoading.value
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        semanticsLabel: 'Signing in',
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Go live. Feel connected.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
