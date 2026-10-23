import 'dart:io';
import 'dart:ui' as ui;

import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/auth/views/auth_view.dart';
import 'package:doyel_live/app/modules/auth/views/registration_view.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/widgets/custom_tab_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

const _items = [
  CustomTabItem(
    label: 'Home',
    activeIcon: Icons.home,
    inactiveIcon: Icons.home_outlined,
  ),
  CustomTabItem(
    label: 'Search',
    activeIcon: Icons.search,
    inactiveIcon: Icons.search,
  ),
  CustomTabItem(
    label: 'Live',
    activeIcon: Icons.videocam,
    inactiveIcon: Icons.videocam_outlined,
  ),
  CustomTabItem(
    label: 'Chat',
    activeIcon: Icons.chat,
    inactiveIcon: Icons.chat_outlined,
  ),
  CustomTabItem(
    label: 'Profile',
    activeIcon: Icons.person,
    inactiveIcon: Icons.person_outline,
  ),
];

Widget _shell(Widget body, int selected) => Scaffold(
  appBar: AppBar(
    title: const Text('DOT LIVE'),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: NeumorphicIconButton(
          icon: Icons.workspace_premium,
          tooltip: 'Top Hosts and Contributors',
          onPressed: () {},
        ),
      ),
    ],
  ),
  body: body,
  bottomNavigationBar: Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: AppCard(
      child: CustomTabBar(
        items: _items,
        selectedIndex: selected,
        onTap: (_) {},
      ),
    ),
  ),
);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    final auth = TestAuthController();
    auth.profile.value = buildTestProfile(fullName: 'Nadia Rahman', uid: 1024);
    Get.put<AuthController>(auth);
    Get.put(ProfileController());
    final live = Get.put(LiveStreamingController());
    live.topSlidingAgentRankingList.assignAll([
      {
        'agent_name': 'Nadia Agency',
        'user_id': 1024,
        'diamonds': 125000,
        'top': 1,
        'logo': '',
        'is_app_owner': true,
      },
    ]);
    live.topHostList.assignAll(const [
      TopHost(
        uid: 21,
        level: {},
        vvipOrVipPreference: {},
        fullName: 'Sadia',
        profileImage: null,
        seconds: 100,
        liveDurationSeconds: 100,
        giftDiamonds: 0,
        diamondsContributed: 0,
        isAgent: false,
        isReseller: false,
        isHost: true,
        isModerator: false,
      ),
      TopHost(
        uid: 22,
        level: {},
        vvipOrVipPreference: {},
        fullName: 'Arif',
        profileImage: null,
        seconds: 90,
        liveDurationSeconds: 90,
        giftDiamonds: 0,
        diamondsContributed: 0,
        isAgent: false,
        isReseller: false,
        isHost: true,
        isModerator: false,
      ),
    ]);
    live.listFilterLiveStreams.assignAll(
      List.generate(
        4,
        (index) => {
          'channel_id': 21 + index,
          'viewers_count': 24 + index * 17,
          'owner_profile': {
            'full_name': ['Sadia', 'Arif', 'Maya', 'Rafi'][index],
            'profile_image': null,
            'vvip_or_vip_gif': null,
          },
        },
      ),
    );
  });
  tearDown(Get.reset);

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('screens fit a $width wide phone at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final previousShadows = debugDisableShadows;
        try {
          final export = Platform.environment['THEME_PREVIEW_DIR'];
          final fontDirectory = Platform.environment['THEME_PREVIEW_FONTS'];
          if (export != null && fontDirectory != null) {
            debugDisableShadows = false;
            await tester.runAsync(() async {
              for (final family in ['Roboto', 'Ahem']) {
                final font = FontLoader(family)
                  ..addFont(
                    File('$fontDirectory/Roboto-Regular.ttf')
                        .readAsBytes()
                        .then((bytes) => ByteData.sublistView(bytes)),
                  );
                await font.load();
              }
              final icons = FontLoader('MaterialIcons')
                ..addFont(
                  File(
                    '$fontDirectory/MaterialIcons-Regular.otf',
                  ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
                );
              await icons.load();
              final mdi =
                  FontLoader(
                    'packages/material_design_icons_flutter/Material Design Icons',
                  )..addFont(
                    rootBundle.load(
                      'packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf',
                    ),
                  );
              await mdi.load();
            });
          }
          for (final screen in [
            'auth',
            'registration',
            'discovery',
            'profile',
          ]) {
            final boundary = GlobalKey();
            final Widget page = switch (screen) {
              'auth' => AuthView(),
              'registration' => const RegistrationView(),
              'discovery' => _shell(
                StreamingListView(onOpenLiveRoomOverride: (_) {}),
                0,
              ),
              _ => _shell(ProfileView(), 4),
            };
            await tester.pumpWidget(
              NeumorphicTheme(
                theme: AppTheme.neumorphicTheme,
                themeMode: ThemeMode.light,
                child: GetMaterialApp(
                  theme: AppTheme.lightTheme,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                  home: RepaintBoundary(key: boundary, child: page),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$screen at $width / $scale',
            );
            if (export != null && width == 390 && scale == 1) {
              await tester.runAsync(() async {
                final render =
                    boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary;
                final image = await render.toImage(pixelRatio: 2);
                final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final file = File('$export/$screen.png');
                await file.parent.create(recursive: true);
                await file.writeAsBytes(bytes!.buffer.asUint8List());
                image.dispose();
              });
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          }
        } finally {
          debugDisableShadows = previousShadows;
        }
      });
    }
  }
}
