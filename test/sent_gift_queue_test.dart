import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

Map<String, dynamic> _gift(int id) => {
  'gift_type': 'animation',
  'gift_id': id,
  'svga': 'https://example.com/gift-$id.svga',
};

void main() {
  late LiveStreamingController controller;

  setUp(() {
    Get.testMode = true;
    Get.put<AuthController>(TestAuthController());
    controller = Get.put(LiveStreamingController());
  });
  tearDown(() {
    controller.setClearAnimationStuffs();
    Get.reset();
  });

  testWidgets('loading deadline skips a stuck gift but never cuts playback', (
    tester,
  ) async {
    controller.listAnimatedGiftSend.addAll([_gift(1), _gift(2)]);
    controller.showNextAnimatedGift();
    final failedId = controller.animatedGiftPlaybackId.value;
    await tester.pump(const Duration(seconds: 29));
    expect(controller.listAnimatedGiftSend, hasLength(2));
    await tester.pump(const Duration(seconds: 1));
    expect(controller.listAnimatedGiftSend, hasLength(1));
    final playingId = controller.animatedGiftPlaybackId.value;
    expect(playingId, isNot(failedId));
    controller.onAnimatedGiftPlaybackStarted(playingId);
    await tester.pump(const Duration(minutes: 1));
    expect(controller.showGiftSendAnimation.value, isTrue);
    expect(controller.listAnimatedGiftSend.single['gift_id'], 2);
    await controller.finishAnimatedGift(playingId);
    expect(controller.showGiftSendAnimation.value, isFalse);
    expect(controller.listAnimatedGiftSend, isEmpty);
  });

  testWidgets('duplicate or late completion cannot skip the next gift', (
    tester,
  ) async {
    controller.listAnimatedGiftSend.add(_gift(1));
    controller.showNextAnimatedGift();
    final firstId = controller.animatedGiftPlaybackId.value;
    controller.onAnimatedGiftPlaybackStarted(firstId);
    controller.listAnimatedGiftSend.addAll([_gift(1), _gift(2)]);
    controller.showNextAnimatedGift();
    expect(controller.animatedGiftPlaybackId.value, firstId);

    final completion = controller.finishAnimatedGift(firstId);
    final duplicate = controller.finishAnimatedGift(firstId);
    await Future.wait([completion, duplicate]);
    expect(controller.listAnimatedGiftSend, hasLength(2));
    final secondId = controller.animatedGiftPlaybackId.value;
    expect(secondId, isNot(firstId));
    await controller.finishAnimatedGift(firstId);
    controller.onAnimatedGiftPlaybackStarted(firstId);
    expect(controller.animatedGiftPlaybackId.value, secondId);
    expect(controller.listAnimatedGiftSend, hasLength(2));
    controller.onAnimatedGiftPlaybackStarted(secondId);
    await tester.pump(const Duration(seconds: 6));
    expect(controller.showGiftSendAnimation.value, isTrue);
  });

  testWidgets('room reset invalidates pending completion and loading timers', (
    tester,
  ) async {
    controller.listAnimatedGiftSend.add(_gift(1));
    controller.showNextAnimatedGift();
    final oldId = controller.animatedGiftPlaybackId.value;
    final pendingCompletion = controller.finishAnimatedGift(oldId);
    controller.setClearAnimationStuffs();
    controller.listAnimatedGiftSend.add(_gift(2));
    controller.showNextAnimatedGift();
    final newId = controller.animatedGiftPlaybackId.value;
    controller.onAnimatedGiftPlaybackStarted(newId);
    await pendingCompletion;
    await controller.finishAnimatedGift(oldId);
    await tester.pump(const Duration(minutes: 1));
    expect(controller.animatedGiftPlaybackId.value, newId);
    expect(controller.showGiftSendAnimation.value, isTrue);
    expect(controller.listAnimatedGiftSend.single['gift_id'], 2);
    controller.setClearAnimationStuffs();
    await tester.pump(const Duration(minutes: 1));
    expect(controller.showGiftSendAnimation.value, isFalse);
    expect(controller.listAnimatedGiftSend, isEmpty);
  });
}
