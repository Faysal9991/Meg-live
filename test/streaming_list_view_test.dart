import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/home_banner.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/others/slides_top_agents_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/widgets/home_banner_carousel.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
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

  testWidgets(
    'home shows both banners followed by live rooms without top hosts',
    (tester) async {
      final authController = TestAuthController();
      authController.profile.value = buildTestProfile(uid: 55);
      Get.put<AuthController>(authController);

      final controller = Get.put(LiveStreamingController());
      controller.bannerList.assignAll(const [
        HomeBanner(image: 'https://example.com/banner.png'),
      ]);
      controller.topSlidingAgentRankingList.assignAll([
        {
          'agent_name': 'Featured Agent',
          'user_id': 456,
          'diamonds': 25000,
          'top': 1,
          'logo': '',
          'is_app_owner': true,
        },
      ]);
      controller.topHostList.assignAll([
        const TopHost(
          uid: 123,
          level: {'level': 7},
          vvipOrVipPreference: {},
          fullName: 'Host One',
          profileImage: null,
          seconds: 1234,
          liveDurationSeconds: 1234,
          giftDiamonds: 0,
          diamondsContributed: 0,
          isAgent: true,
          isReseller: false,
          isHost: true,
          isModerator: false,
        ),
      ]);
      controller.listFilterLiveStreams.assignAll([
        {
          'channel_id': 123,
          'viewers_count': 10,
          'reacts': 0,
          'allow_send': true,
          'owner_profile': {
            'full_name': 'Host One',
            'profile_image': null,
            'blocks': <dynamic>[],
            'diamonds': 20,
            'vvip_rank': 0,
            'vvip_or_vip_gif': null,
          },
        },
      ]);

      await tester.pumpWidget(
        GetMaterialApp(home: StreamingListView(onOpenLiveRoomOverride: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeBannerCarousel), findsOneWidget);
      expect(find.byType(SlidesTopAgentsView), findsOneWidget);
      expect(find.text('Featured Agent'), findsOneWidget);
      expect(find.text('Top Hosts'), findsNothing);
      expect(find.text('Host One'), findsWidgets);
      expect(find.text('Top Contributors'), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('LIVE'), findsOneWidget);
    },
  );

  testWidgets('live room card opens the selected room', (tester) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile(uid: 55);
    Get.put<AuthController>(authController);

    final controller = Get.put(LiveStreamingController());
    controller.topHostList.assignAll([
      const TopHost(
        uid: 321,
        level: {'level': 5},
        vvipOrVipPreference: {},
        fullName: 'Live Host',
        profileImage: null,
        seconds: 456,
        liveDurationSeconds: 456,
        giftDiamonds: 0,
        diamondsContributed: 0,
        isAgent: false,
        isReseller: false,
        isHost: true,
        isModerator: false,
      ),
    ]);
    controller.listFilterLiveStreams.assignAll([
      {
        'channel_id': 321,
        'viewers_count': 5,
        'reacts': 0,
        'allow_send': true,
        'owner_profile': {
          'full_name': 'Live Host',
          'profile_image': null,
          'blocks': <dynamic>[],
          'diamonds': 20,
          'vvip_rank': 0,
          'vvip_or_vip_gif': null,
        },
      },
    ]);

    Map<String, dynamic>? openedLiveRoom;

    await tester.pumpWidget(
      GetMaterialApp(
        home: StreamingListView(
          onOpenLiveRoomOverride: (data) => openedLiveRoom = data,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Live Host').first);
    await tester.pumpAndSettle();

    expect(openedLiveRoom?['channel_id'], 321);
  });

  testWidgets('offline top hosts are absent from the empty home feed', (
    tester,
  ) async {
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile(uid: 55);
    Get.put<AuthController>(authController);

    final controller = Get.put(LiveStreamingController());
    controller.topHostList.assignAll([
      const TopHost(
        uid: 999,
        level: {'level': 5},
        vvipOrVipPreference: {},
        fullName: 'Offline Host',
        profileImage: null,
        seconds: 456,
        liveDurationSeconds: 456,
        giftDiamonds: 0,
        diamondsContributed: 0,
        isAgent: false,
        isReseller: false,
        isHost: true,
        isModerator: false,
      ),
    ]);

    await tester.pumpWidget(GetMaterialApp(home: StreamingListView()));
    await tester.pumpAndSettle();

    expect(find.text('Offline Host'), findsNothing);
    expect(find.text('Top Hosts'), findsNothing);
    expect(find.text('No live rooms yet'), findsOneWidget);
  });
}
