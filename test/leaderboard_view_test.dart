import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/leaderboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  late _LeaderboardController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    final auth = TestAuthController();
    auth.profile.value = buildTestProfile(uid: 104);
    Get.put<AuthController>(auth);
    controller = _LeaderboardController();
  });

  tearDown(Get.reset);

  Future<void> showLeaderboard(WidgetTester tester, {double scale = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: LeaderboardView(controller: controller, currentUserId: 104),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('server ranks place second, first and third on the podium', (
    tester,
  ) async {
    controller.topHostList.assignAll([
      _profile(3),
      _profile(4),
      _profile(1),
      _profile(2),
    ]);
    await showLeaderboard(tester);

    expect(controller.fallbackChecks, 1);
    expect(find.text('Top Ranking'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    final second = tester.getCenter(find.byKey(const ValueKey('podium-2')));
    final first = tester.getCenter(find.byKey(const ValueKey('podium-1')));
    final third = tester.getCenter(find.byKey(const ValueKey('podium-3')));
    expect(second.dx, lessThan(first.dx));
    expect(first.dx, lessThan(third.dx));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('podium-1'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('podium-2'))).dy),
    );
    final yourRow = find.byKey(const ValueKey('ranking-4'));
    expect(
      find.descendant(of: yourRow, matching: find.text('You')),
      findsOneWidget,
    );
    final row = tester.widget<Container>(yourRow);
    expect((row.decoration! as BoxDecoration).gradient, isNotNull);
    expect(find.text('1000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs show their own scores and react to new rankings', (
    tester,
  ) async {
    controller.topHostList.add(_profile(1));
    controller.topContributorList.add(_profile(1, contributor: true));
    await showLeaderboard(tester);

    expect(find.text('Host 1'), findsOneWidget);
    await tester.tap(find.text('Top Contributors'));
    await tester.pumpAndSettle();
    expect(find.text('Contributor 1'), findsOneWidget);
    expect(find.text('Host 1'), findsNothing);
    expect(find.text('7000'), findsOneWidget);

    controller.topContributorList.assignAll([_profile(2, contributor: true)]);
    await tester.pumpAndSettle();
    expect(find.text('Contributor 2'), findsOneWidget);
    expect(find.text('Contributor 1'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(controller.fallbackChecks, 2);

    await tester.tap(find.text('Top Hosts'));
    await tester.pumpAndSettle();
    expect(find.text('Host 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REST entries without server ranks use their list positions', (
    tester,
  ) async {
    controller.topHostList.assignAll([
      for (var index = 1; index <= 4; index++)
        _profile(index, includeRank: false),
    ]);
    await showLeaderboard(tester);

    expect(find.byKey(const ValueKey('podium-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('podium-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('podium-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('ranking-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty rankings allow refresh and loading shows a spinner', (
    tester,
  ) async {
    controller.loadingTopHostList.value = true;
    await tester.pumpWidget(
      MaterialApp(home: LeaderboardView(controller: controller)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.loadingTopHostList.value = false;
    await tester.pumpAndSettle();
    expect(find.text('No rankings yet'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(controller.fallbackChecks, 2);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('rankings fit a $width phone at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        controller.topHostList.assignAll([
          for (var rank = 1; rank <= 10; rank++)
            _profile(rank, longContent: true),
        ]);
        await showLeaderboard(tester, scale: scale);
        expect(tester.takeException(), isNull);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('ranking-10')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('reconnecting preserves the rankings already on screen', (
    tester,
  ) async {
    controller.topHostList.add(_profile(1));
    await showLeaderboard(tester);
    controller.webSocketConnectionState.value = 'reconnecting';
    await tester.pumpAndSettle();
    expect(find.text('Reconnecting…'), findsOneWidget);
    expect(find.text('Host 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

TopHost _profile(
  int rank, {
  bool contributor = false,
  bool includeRank = true,
  bool longContent = false,
}) => TopHost.fromJson({
  'uid': 100 + rank,
  'level': longContent ? {'level': 99} : null,
  if (includeRank) 'rank': rank,
  'full_name': longContent
      ? 'A very long leaderboard display name $rank'
      : '${contributor ? 'Contributor' : 'Host'} $rank',
  'gift_diamonds': longContent ? 123456789012 : 1000 * rank,
  'diamonds_contributed': longContent ? 987654321012 : 7000 * rank,
});

class _LeaderboardController extends LiveStreamingController {
  int fallbackChecks = 0;

  @override
  Future<void> loadMissingRankings() async {
    fallbackChecks++;
  }
}
