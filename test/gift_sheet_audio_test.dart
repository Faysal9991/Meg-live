import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/user_interact_bottom_sheet_funtion.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/widgets/gifts_widget.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

class _Live extends LiveStreamingController {
  @override
  void fetchGiftList() {}
}

void main() {
  setUp(() {
    SVGACache.shared.setEnabled(false);
    Get.testMode = true;
    Get.put<AuthController>(
      TestAuthController()..profile.value = buildTestProfile(),
    );
    final live = Get.put<LiveStreamingController>(_Live());
    live.listAnimatedGift.addAll([
      {
        'id': 1,
        'diamonds': 10,
        'vat': 0,
        'svga': 'https://example.test/a.svga',
      },
      {
        'id': 2,
        'diamonds': 20,
        'vat': 0,
        'svga': 'https://example.test/b.svga',
      },
    ]);
    live.listNormalGift.add({
      'id': 1,
      'diamonds': 5,
      'vat': 0,
      'gift_image': 'https://example.test/gift.png',
    });
  });
  tearDown(() {
    SVGACache.shared.setEnabled(true);
    Get.reset();
  });

  testWidgets(
    'only the selected gift has audio and dismissal mutes before the exit animation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Thumbnails can still be loading or looping while controls are usable.
      Future<void> advanceUi() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showUserInteractBottomSheet(
                  context: context,
                  // The host can preview gifts before choosing a recipient.
                  data: {'uid': 999, 'full_name': 'Host'},
                  onUpdateAction: (_) {},
                ),
                child: const Text('Open gifts'),
              ),
            ),
          ),
        ),
      );
      Iterable<AnimatedMediaWidget> audible() => tester
          .widgetList<AnimatedMediaWidget>(find.byType(AnimatedMediaWidget))
          .where(
            (widget) =>
                widget.enableSvgaAudio &&
                widget.source.type == AnimatedMediaType.svga,
          );
      await tester.tap(find.text('Open gifts'));
      await advanceUi();
      expect(audible(), isEmpty);

      await tester.tap(find.byType(giftItem).at(0));
      await advanceUi();
      expect(audible().single.source.url, endsWith('a.svga'));
      await tester.tap(find.byType(giftItem).at(1));
      await advanceUi();
      expect(audible().single.source.url, endsWith('b.svga'));
      await tester.tap(find.byType(giftItem).at(2));
      await advanceUi();
      expect(audible(), isEmpty);

      await tester.tap(find.byType(giftItem).at(0));
      await advanceUi();
      Navigator.of(tester.element(find.text('SEND GIFTS'))).pop();
      await tester.pump();
      expect(audible(), isEmpty);
      await tester.pumpAndSettle();
      expect(find.byType(giftItem), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
