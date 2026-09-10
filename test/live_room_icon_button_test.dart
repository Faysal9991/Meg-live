import 'package:doyel_live/app/modules/live_streaming/views/broadcast/widgets/live_room_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('live room actions stay compact and accessible', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveRoomIconButton(
            icon: LucideIcons.mic,
            label: 'Mute microphone',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LiveRoomIconButton)), const Size(40, 40));
    expect(find.bySemanticsLabel('Mute microphone'), findsOneWidget);

    await tester.tap(find.byType(LiveRoomIconButton));
    expect(pressed, isTrue);
  });
}
