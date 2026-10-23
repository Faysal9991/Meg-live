import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashController extends GetxController {
  final appVersionLabel = ''.obs;

  bool _started = false;

  @override
  void onReady() {
    super.onReady();
    if (_started) {
      return;
    }
    _started = true;
    _startApp();
  }

  Future<void> _startApp() async {
    await _loadInstalledVersion();
    await Future.delayed(const Duration(seconds: 1));

    final updateBlockedNavigation = await _checkForPlayStoreUpdate();
    if (updateBlockedNavigation) {
      return;
    }

    _goToNextRoute();
  }

  Future<void> _loadInstalledVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersionLabel.value =
          '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (_) {
      appVersionLabel.value = '';
    }
  }

  Future<bool> _checkForPlayStoreUpdate() async {
    if (!GetPlatform.isAndroid) {
      return false;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }

      if (updateInfo.immediateUpdateAllowed) {
        try {
          final result = await InAppUpdate.performImmediateUpdate();
          if (result == AppUpdateResult.success) {
            return true;
          }
        } catch (_) {
          // Fall back to the Play Store listing if in-app update fails.
        }
      }

      await _showForceUpdateDialog();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showForceUpdateDialog() async {
    if (Get.isDialogOpen ?? false) {
      return;
    }

    final installedVersion = appVersionLabel.value;
    final content = installedVersion.isEmpty
        ? 'A new version is available on Play Store. Please update to continue using DOT LIVE.'
        : 'Installed version $installedVersion. A newer version is available on Play Store. Please update to continue using DOT LIVE.';

    await Get.dialog<void>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Text(content),
          actions: [
            FilledButton(
              onPressed: _openPlayStoreListing,
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _openPlayStoreListing() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    final openedMarket = await launchUrl(
      marketUri,
      mode: LaunchMode.externalApplication,
    );
    if (!openedMarket) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _goToNextRoute() {
    final authController = Get.find<AuthController>();
    if (authController.token.value.isEmpty) {
      Get.offAllNamed(Routes.AUTH);
      return;
    }

    Get.offAllNamed(Routes.NAV);
  }
}
