import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ChangePasswordView extends StatelessWidget {
  ChangePasswordView({super.key});
  final AuthController _authController = Get.find();
  final TextEditingController _editingControllerOldPassword =
      TextEditingController();
  final TextEditingController _editingControllerNewPassword =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading: _authController.loadingChangePassword.value,
          // opacity: 0.8,
          progressIndicator: const SpinKitHourGlass(
            color: AppColors.error,
            size: 50.0,
          ),
          child: Scaffold(
            // backgroundColor: Theme.of(context).primaryColor,
            appBar: AppBar(title: const Text('Change Password')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: rPrimaryTextField(
                    controller: _editingControllerOldPassword,
                    keyboardType: TextInputType.visiblePassword,
                    borderColor: AppColors.textPrimary,
                    obscureText: true,
                    hintText: 'Old password',
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: rPrimaryTextField(
                    controller: _editingControllerNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    borderColor: AppColors.textPrimary,
                    obscureText: true,
                    hintText: 'New password (minimum 8 characters)',
                  ),
                ),
                const SizedBox(height: 32),
                rPrimaryElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    String oldPassword = _editingControllerOldPassword.text
                        .trim();
                    String newPassword = _editingControllerNewPassword.text
                        .trim();

                    if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
                      if (newPassword.length < 8) {
                        Get.snackbar(
                          'Failed',
                          "New password length must be 8 charecters long.",
                          backgroundColor: AppColors.error,
                          colorText: AppColors.surface,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      bool result = await _authController.tryToChangePassword(
                        oldPassword: oldPassword,
                        newPassword: newPassword,
                      );
                      if (result) {
                        Navigator.pop(context);
                      }
                    } else {
                      Get.snackbar(
                        'Failed',
                        "All fields are required.",
                        backgroundColor: AppColors.error,
                        colorText: AppColors.surface,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  primaryColor: Theme.of(context).primaryColor,
                  buttonText: 'Submit',
                  buttonTextColor: AppColors.surface,
                  fontSize: 16.0,
                  fixedSize: Size(MediaQuery.of(context).size.width - 32, 46),
                  borderRadius: AppRadius.button,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
