import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/balance/controllers/balance_controller.dart';
import 'package:doyel_live/app/modules/balance/models/withdraw_models.dart';
import 'package:doyel_live/app/modules/balance/views/withdraw_requests_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('account type field only appears when method requires it', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);

    final balanceController = TestBalanceController();
    balanceController.withdrawPackages.assignAll([
      const WithdrawPackageOption(id: 1, label: 'Weekly', raw: {'id': 1}),
    ]);
    balanceController.paymentMethods.assignAll([
      const PaymentMethodOption(
        id: 1,
        name: 'Bank',
        requiresAccountType: true,
        raw: {'id': 1},
      ),
      const PaymentMethodOption(
        id: 2,
        name: 'Bkash',
        requiresAccountType: false,
        raw: {'id': 2},
      ),
    ]);
    Get.put<BalanceController>(balanceController);

    await tester.pumpWidget(GetMaterialApp(home: const WithdrawRequestsView()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Account Type'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank').last);
    await tester.pumpAndSettle();

    expect(find.text('Account Type'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bkash').last);
    await tester.pumpAndSettle();

    expect(find.text('Account Type'), findsNothing);
  });

  testWidgets('successful submit on HTTP 200 returns to requests tab', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);

    final balanceController = TestBalanceController();
    balanceController.withdrawPackages.assignAll([
      const WithdrawPackageOption(id: 1, label: 'Weekly', raw: {'id': 1}),
    ]);
    balanceController.paymentMethods.assignAll([
      const PaymentMethodOption(
        id: 2,
        name: 'Bkash',
        requiresAccountType: false,
        raw: {'id': 2},
      ),
    ]);
    balanceController.withdrawRequests.assignAll(const <WithdrawRequestItem>[]);
    balanceController.createStatusCode = 200;
    Get.put<BalanceController>(balanceController);

    await tester.pumpWidget(GetMaterialApp(home: const WithdrawRequestsView()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bkash').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Receiver Number'),
      '01700000000',
    );
    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(find.text('No withdraw requests yet.'), findsOneWidget);
  });
}
