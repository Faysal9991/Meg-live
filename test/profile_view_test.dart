import 'dart:io';
import 'dart:ui' as ui;
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/widgets/app_bottom_nav.dart';
import 'package:doyel_live/app/widgets/diamond_icon.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
    expect(find.text('Withdraw'), findsOneWidget);
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

  TestAuthController registerProfile() {
    final auth = TestAuthController();
    auth.profile.value = buildTestProfile(uid: 8839)
      ..email = 'tanvir@example.com'
      ..diamonds = 9999
      ..gift_diamonds = 8173
      ..followers = [101]
      ..friends_count = 0
      ..following_count = 0;
    Get.put<AuthController>(auth);
    Get.put(ProfileController());
    return auth;
  }

  Widget shell({double scale = 1, Key? previewKey}) => GetMaterialApp(
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg),
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: RepaintBoundary(
      key: previewKey,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/logos/dot_live.png'),
          ),
          title: const Text('DOT LIVE'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(LucideIcons.crown, color: AppColors.gold),
            ),
          ],
        ),
        body: ProfileView(),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBottomNav(selectedIndex: PROFILE, onTap: (_) {}),
        ),
      ),
    ),
  );

  testWidgets('profile identity, wallet and server level update reactively', (
    tester,
  ) async {
    final auth = registerProfile();
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    expect(find.text('DOT LIVE'), findsOneWidget);
    expect(find.text('tanvir@example.com'), findsOneWidget);
    expect(find.text('ID: 8839'), findsOneWidget);
    expect(find.text('8173'), findsOneWidget);
    expect(find.text('9999'), findsNothing);
    expect(find.byTooltip('Gift earnings: 8173'), findsNothing);
    expect(find.byType(DiamondIcon), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    final hero = tester.getRect(
      find.byKey(const ValueKey('profile-identity-card')),
    );
    final stats = tester.getRect(
      find.byKey(const ValueKey('profile-stats-card')),
    );
    expect(stats.top, lessThan(hero.bottom));

    auth.profile.value = Profile.fromJson(
      auth.profile.value.mergedJson({
        'diamonds': 333,
        'gift_diamonds': 700,
        'level': null,
        'full_name': 'Updated Name',
        'is_reseller': true,
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('700'), findsOneWidget);
    expect(find.text('L.V. —'), findsOneWidget);
    expect(find.text('Updated Name'), findsOneWidget);
    expect(find.text('Reseller Recharge'), findsOneWidget);
    expect(find.text('Host Request'), findsNothing);
  });

  testWidgets('copy ID uses the backend account ID', (tester) async {
    registerProfile();
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = call.arguments['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Copy user ID'));
    await tester.pumpAndSettle();
    expect(copied, '8839');
    expect(find.text('User ID copied'), findsOneWidget);
  });

  testWidgets('wallet opens with the shared server balances', (tester) async {
    final auth = registerProfile();
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Diamonds'), findsOneWidget);
    expect(find.text('Available diamonds'), findsNothing);
    expect(find.text('Gift earnings'), findsNothing);
    expect(find.text('9999'), findsNothing);
    auth.profile.value = Profile.fromJson(
      auth.profile.value.mergedJson({'diamonds': 333, 'gift_diamonds': 420}),
    );
    await tester.pumpAndSettle();
    expect(find.text('420'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('profile fits $width at text scale $scale', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = registerProfile();
        auth.profile.value.full_name = 'A very long profile display name';
        auth.profile.value.email = 'a.very.long.email.address@example.com';
        auth.profile.value.gift_diamonds = 1234567890123;
        await tester.pumpWidget(shell(scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.byIcon(LucideIcons.logOut),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  final previewPath = Platform.environment['PROFILE_PREVIEW_PATH'];
  final fontsPath = Platform.environment['PROFILE_PREVIEW_FONTS'];
  if (previewPath != null && fontsPath != null) {
    testWidgets('export profile preview', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        for (final family in ['Roboto', 'Ahem']) {
          await (FontLoader(family)..addFont(
                File(
                  '$fontsPath/Roboto-Regular.ttf',
                ).readAsBytes().then(ByteData.sublistView),
              ))
              .load();
        }
        await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
              rootBundle.load(
                'packages/lucide_icons_flutter/assets/lucide.ttf',
              ),
            ))
            .load();
      });
      final auth = registerProfile();
      auth.profile.value.full_name = 'Tanvir Hasan';
      final boundary = GlobalKey();
      await tester.pumpWidget(shell(previewKey: boundary));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(previewPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    });
  }
}

class _TestSignOutAuthController extends TestAuthController {
  int signOutCalls = 0;

  @override
  void tryToSignOut() {
    signOutCalls++;
  }
}
