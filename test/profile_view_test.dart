import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('profile view shows king package and withdraw entries', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);
    Get.put(ProfileController());

    await tester.pumpWidget(GetMaterialApp(home: ProfileView()));
    await tester.pumpAndSettle();

    expect(find.text('King Package'), findsOneWidget);
    expect(find.text('Entry Effect'), findsOneWidget);
    expect(find.text('Withdraw Requests'), findsOneWidget);
  });
}
