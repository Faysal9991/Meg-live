import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/edit_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'test_helpers.dart';

class _ProfileController extends ProfileController {
  String? savedName;
  @override
  void tryToUpdateProfile({required String fullName}) {
    savedName = fullName;
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);
  testWidgets('profile saves 50 characters including Unicode names', (
    tester,
  ) async {
    Get.put<AuthController>(
      TestAuthController()..profile.value = buildTestProfile(),
    );
    final controller =
        Get.put<ProfileController>(_ProfileController()) as _ProfileController;
    await tester.pumpWidget(const GetMaterialApp(home: EditProfileView()));
    for (final name in ['A' * 50, '😀' * 50]) {
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pumpAndSettle();
      expect(controller.savedName, name);
    }
    await tester.enterText(find.byType(TextField), 'B' * 51);
    expect(
      tester
          .widget<TextField>(find.byType(TextField))
          .controller!
          .text
          .characters
          .length,
      50,
    );
  });
}
