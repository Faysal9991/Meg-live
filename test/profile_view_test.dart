import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('profile view shows membership and withdraw entries', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);
    Get.put(ProfileController());

    await tester.pumpWidget(GetMaterialApp(home: ProfileView()));
    await tester.pumpAndSettle();

    expect(find.text('VIP Package'), findsOneWidget);
    expect(find.text('VVIP Package'), findsOneWidget);
    expect(find.text('Entry Effect'), findsOneWidget);
    expect(find.text('Withdraw Requests'), findsOneWidget);
  });

  testWidgets('logout option requires confirmation before signing out', (
    tester,
  ) async {
    final authController = _TestSignOutAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);
    Get.put(ProfileController());

    await tester.pumpWidget(GetMaterialApp(home: ProfileView()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byIcon(LucideIcons.logOut),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(LucideIcons.logOut));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to log out of your account?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(authController.signOutCalls, 0);

    await tester.tap(find.byIcon(LucideIcons.logOut));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
    await tester.pumpAndSettle();

    expect(authController.signOutCalls, 1);
  });

  test('selects local VIP and VVIP frames from membership rank', () {
    expect(vipFrameAssetForPreference({'rank': 1}), 'assets/logos/vip.png');
    expect(
      vipFrameAssetForPreference({'rank': '90000'}),
      'assets/logos/vvip.png',
    );
    expect(vipFrameAssetForPreference({'rank': 0}), isNull);
    expect(vipFrameAssetForPreference(null), isNull);
  });

  testWidgets('profile image displays the VVIP frame above the avatar', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile()
      ..vvip_or_vip_preference = {'rank': 90000};
    Get.put<AuthController>(authController);
    Get.put(ProfileController());

    await tester.pumpWidget(GetMaterialApp(home: ProfileView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('assets/logos/vvip.png')), findsOneWidget);
    expect(find.byKey(const ValueKey('assets/logos/vip.png')), findsNothing);
  });
}

class _TestSignOutAuthController extends TestAuthController {
  int signOutCalls = 0;

  @override
  void tryToSignOut() {
    signOutCalls++;
  }
}
