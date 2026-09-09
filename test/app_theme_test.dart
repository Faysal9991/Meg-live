import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/widgets/custom_tab_bar.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget themed(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(24), child: child),
  ),
);

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
}

void main() {
  test(
    'text, actions, and status colors remain readable on their surfaces',
    () {
      for (final color in [
        AppColors.textPrimary,
        AppColors.textSecondary,
        AppColors.textHint,
        AppColors.primary,
        AppColors.accent,
        AppColors.error,
        AppColors.success,
        AppColors.warning,
      ]) {
        expect(contrast(color, AppColors.surface), greaterThanOrEqualTo(4.5));
      }
      for (final color in [
        AppColors.primary,
        AppColors.accent,
        AppColors.error,
        AppColors.success,
        AppColors.warning,
      ]) {
        expect(
          contrast(AppColors.textOnPrimary, color),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(AppColors.textHint, AppColors.surfaceInset),
        greaterThanOrEqualTo(4.5),
      );
    },
  );

  testWidgets('neumorphic password fields preserve obscuring and editing', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    String? value;
    await tester.pumpWidget(
      themed(
        rPrimaryTextField(
          controller: controller,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          borderColor: AppColors.border,
          labelText: 'Password',
          focusNode: focus,
          onChanged: (text) => value = text,
          maxLength: 32,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'private-password');
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(field.enableSuggestions, isFalse);
    expect(field.autocorrect, isFalse);
    expect(field.maxLength, 32);
    expect(field.decoration?.labelText, 'Password');
    expect(value, 'private-password');
    expect(focus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiline and read-only field contracts survive inset styling', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'First\nSecond');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      themed(
        rPrimaryTextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          borderColor: AppColors.border,
          maxLines: 4,
          readOnly: true,
          prefixText: 'Note: ',
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
    expect(field.readOnly, isTrue);
    expect(field.decoration?.prefixText, 'Note: ');
    expect(controller.text, 'First\nSecond');
  });

  testWidgets(
    'primary actions support keyboard activation and disabled state',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        themed(
          Column(
            children: [
              PrimaryButton(label: 'Continue', onPressed: () => calls++),
              const SizedBox(height: 16),
              const PrimaryButton(label: 'Unavailable', onPressed: null),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.tap(find.text('Unavailable'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Continue')).height,
        greaterThanOrEqualTo(48),
      );
    },
  );

  testWidgets('soft cards retain their child tap actions', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      themed(
        AppCard(
          child: ListTile(
            title: const Text('Open profile'),
            onTap: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets(
    'navigation follows app state and works without a tab controller',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        themed(
          StatefulBuilder(
            builder: (context, setState) => CustomTabBar(
              items: const [
                CustomTabItem(
                  label: 'Discover',
                  activeIcon: Icons.home,
                  inactiveIcon: Icons.home_outlined,
                ),
                CustomTabItem(
                  label: 'Profile',
                  activeIcon: Icons.person,
                  inactiveIcon: Icons.person_outline,
                ),
              ],
              selectedIndex: selected,
              onTap: (index) => setState(() => selected = index),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
