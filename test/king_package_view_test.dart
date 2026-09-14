import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/modules/products/models/king_package_catalog_state.dart';
import 'package:doyel_live/app/modules/products/views/king_package_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('king package view renders package list without purchased item', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);

    final controller = Get.put(VVIPorVipPackageController());
    controller.listAllKingPackage.assignAll([
      const KingPackageItem(
        id: 1,
        price: 999,
        days: 30,
        gif: 'https://example.com/king.gif',
        raw: {
          'id': 1,
          'price': 999,
          'days': 30,
          'gif': 'https://example.com/king.gif',
        },
      ),
    ]);
    controller.kingPackageOrderingInfo.value = {'context': 'Contact us'};

    await tester.pumpWidget(GetMaterialApp(home: const KingPackageView()));
    await tester.pumpAndSettle();

    expect(find.text('Purchase King Package:'), findsOneWidget);
    expect(find.text('999 Diamonds'), findsOneWidget);
  });
}
