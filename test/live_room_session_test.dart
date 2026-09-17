import 'package:doyel_live/app/modules/live_streaming/services/live_room_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Room extends StatefulWidget {
  const _Room({required this.session, required this.onDispose});
  final LiveRoomSession session;
  final VoidCallback onDispose;
  @override
  State<_Room> createState() => _RoomState();
}

class _RoomState extends State<_Room> {
  int count = 0;
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text('Room state $count'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
        TextButton(
          onPressed: widget.session.minimize,
          child: const Text('Minimize'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Leave'),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('minimize allows browsing and restores the same mounted room', (
    tester,
  ) async {
    final session = LiveRoomSession();
    var disposed = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) =>
            MinimizedLiveOverlay(session: session, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () => session.open(
                    context,
                    (_) => _Room(session: session, onDispose: () => disposed++),
                  ),
                  child: const Text('Open live'),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const Scaffold(body: Text('Profile page')),
                    ),
                  ),
                  child: const Text('Browse profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open live'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Increment'));
    await tester.pump();
    final roomState = tester.state(find.byType(_Room));
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text('Minimize'));
      await tester.pumpAndSettle();
      expect(disposed, 0);
      expect(session.isMinimized, isTrue);
      await tester.tap(find.text('Browse profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile page'), findsOneWidget);
      await tester.tap(find.text('Return to live'));
      await tester.pumpAndSettle();
      expect(session.isMinimized, isFalse);
      expect(tester.state(find.byType(_Room)), same(roomState));
      expect(find.text('Room state 1'), findsOneWidget);
    }
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(disposed, 1);
    expect(session.isActive, isFalse);
    expect(find.text('Return to live'), findsNothing);
  });

  testWidgets('removing a minimized room keeps the current browsing route', (
    tester,
  ) async {
    final session = LiveRoomSession();
    final navigator = GlobalKey<NavigatorState>();
    late Route<dynamic> roomRoute;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        builder: (_, child) =>
            MinimizedLiveOverlay(session: session, child: child!),
        home: const Scaffold(body: Text('Home')),
      ),
    );
    session.open(navigator.currentContext!, (context) {
      roomRoute = ModalRoute.of(context)!;
      return const Scaffold(body: Text('Live'));
    });
    await tester.pumpAndSettle();
    session.minimize();
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Details')),
      ),
    );
    await tester.pumpAndSettle();
    session.detach(roomRoute);
    navigator.currentState!.removeRoute(roomRoute);
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Return to live'), findsNothing);
    expect(session.isActive, isFalse);
  });
}
