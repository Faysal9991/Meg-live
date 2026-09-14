import 'dart:io';

import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'test_helpers.dart';

class _LiveController extends LiveStreamingController {
  @override
  Future<dynamic> createLiveKitToken({required String channelName}) async =>
      null;

  @override
  void fetchGiftList() {}

  @override
  void loadContributionRankingList({required int userId}) {}
}

class _PackageController extends VVIPorVipPackageController {
  @override
  Future<void> ensureKingPackageCatalogLoaded() async {}
}

class _Participant extends Fake implements RemoteParticipant {
  @override
  bool get isSpeaking => false;
  @override
  String get name => 'Connected host';
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    final auth = TestAuthController()..profile.value = buildTestProfile();
    Get.put<AuthController>(auth);
    Get.put<LiveStreamingController>(
      _LiveController()..channelName.value = '100',
    );
    Get.put<VVIPorVipPackageController>(_PackageController());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => call.method == 'requestPermissions'
              ? {for (final permission in call.arguments as List) permission: 1}
              : 1,
        );
  });
  tearDown(() async {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });

  testWidgets('sent SVGA gifts finish fully and replay while headlines update', (
    tester,
  ) async {
    final cache = Directory.systemTemp.createTempSync('doyel-sent-gift-test-');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    messenger.setMockMethodCallHandler(pathChannel, (_) async => cache.path);
    final wasCacheEnabled = SVGACache.shared.isEnabled;
    SVGACache.shared.setEnabled(true);
    addTearDown(() {
      messenger.setMockMethodCallHandler(pathChannel, null);
      SVGACache.shared.setEnabled(wasCacheEnabled);
      cache.deleteSync(recursive: true);
    });
    const url = 'https://example.com/five-second-sent-gift.svga';
    final movie = MovieEntity(
      params: MovieParams(
        viewBoxWidth: 40,
        viewBoxHeight: 40,
        frames: 100,
        fps: 20,
      ),
    );
    await tester.runAsync(
      () => SVGACache.shared.putRawBytes(
        url,
        Uint8List.fromList(zlib.encode(movie.writeToBuffer())),
      ),
    );
    movie.dispose();

    await tester.pumpWidget(
      NeumorphicTheme(
        theme: AppTheme.neumorphicTheme,
        child: GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const LiveStreamingView(
            channelName: '100',
            isBroadcaster: false,
            followers: [],
            blocks: [],
            level: null,
            vVipOrVipPreference: {},
            fullName: 'Host',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final controller = Get.find<LiveStreamingController>();
    controller.listAnimatedGiftSend.addAll([
      {'gift_type': 'animation', 'gift_id': 1, 'svga': url},
      {'gift_type': 'animation', 'gift_id': 1, 'svga': url},
    ]);
    controller.showNextAnimatedGift();

    Future<void> waitForMovie() async {
      for (var attempt = 0; attempt < 50; attempt++) {
        await tester.pump();
        if (find.byType(SVGAImage).evaluate().isNotEmpty) return;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
      }
      fail('The cached SVGA did not load');
    }

    await waitForMovie();
    final firstPlayer = tester.widget<AnimatedMediaWidget>(
      find.byType(AnimatedMediaWidget),
    );
    expect(firstPlayer.loop, isFalse);
    expect(firstPlayer.enableSvgaAudio, isTrue);
    controller.listLiveHeadlines.add('A room announcement');
    controller.setMarqueeText();
    await tester.pump(const Duration(seconds: 3));
    expect(controller.showGiftSendAnimation.value, isTrue);
    expect(controller.listAnimatedGiftSend, hasLength(2));
    expect(find.byType(SVGAImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2016));
    await tester.pump();
    expect(controller.listAnimatedGiftSend, hasLength(1));
    await waitForMovie();
    final secondPlayer = tester.widget<AnimatedMediaWidget>(
      find.byType(AnimatedMediaWidget),
    );
    expect(secondPlayer.key, isNot(firstPlayer.key));
    // A delayed callback from the old player must not remove the new gift.
    firstPlayer.onCompleted!();
    await tester.pump(const Duration(seconds: 3));
    expect(controller.listAnimatedGiftSend, hasLength(1));
    expect(find.byType(SVGAImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2016));
    await tester.pump();
    expect(controller.listAnimatedGiftSend, isEmpty);
    expect(find.byType(AnimatedMediaWidget), findsNothing);

    // Directly leaving the route must also clear a gift that is still loading.
    controller.listAnimatedGiftSend.add({
      'gift_type': 'animation',
      'svga': url,
    });
    controller.showNextAnimatedGift();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(controller.listAnimatedGiftSend, isEmpty);
    expect(controller.showGiftSendAnimation.value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a participant present on the first frame needs no late screen dimensions',
    (tester) async {
      Get.find<LiveStreamingController>().listRenderView.add(
        ParticipantTrack(
          participant: _Participant(),
          videoTrack: null,
          isScreenShare: false,
        ),
      );
      await tester.pumpWidget(
        NeumorphicTheme(
          theme: AppTheme.neumorphicTheme,
          child: GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const LiveStreamingView(
              channelName: '100',
              isBroadcaster: false,
              followers: [],
              blocks: [],
              level: null,
              vVipOrVipPreference: {'vvip_or_vip_preference': null},
              fullName: 'Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Connected host'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'comment composer reports a disconnected room and keeps the draft',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        NeumorphicTheme(
          theme: AppTheme.neumorphicTheme,
          child: GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const LiveStreamingView(
              channelName: '100',
              isBroadcaster: false,
              followers: [],
              blocks: [],
              level: null,
              vVipOrVipPreference: {},
              fullName: 'Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final commentField = find.byType(TextField);
      final sendButton = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Send comment',
      );
      await tester.enterText(commentField, '  Hello from the live room  ');
      await tester.tap(sendButton);
      await tester.pump();

      expect(
        find.text('Comment connection is not ready. Please try again.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(commentField).controller!.text,
        '  Hello from the live room  ',
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('live room remains usable when opening and dismissing controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      NeumorphicTheme(
        theme: AppTheme.neumorphicTheme,
        child: GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Text('Room list')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Get.to(
      () => const LiveStreamingView(
        channelName: '100',
        isBroadcaster: false,
        followers: [],
        blocks: [],
        level: {'level': 1},
        vVipOrVipPreference: {},
        fullName: 'Host',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Do you wanna close?'), findsOneWidget);
    Navigator.of(tester.element(find.text('Do you wanna close?'))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(LiveStreamingView), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.eye));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('VIEWS'), findsOneWidget);
    await tester.tap(find.text('WAITING'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('WAITING'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.gift));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('SEND GIFTS'), findsOneWidget);
    Navigator.of(tester.element(find.text('SEND GIFTS'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
    final confirm = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'OK'))
        .onPressed!;
    confirm();
    confirm(); // A second close event must not pop the room list.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Room list'), findsOneWidget);
    expect(find.byType(LiveStreamingView), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
