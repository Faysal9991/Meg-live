import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/modules/messenger/views/widgets/modified/message_compose_widget.dart';
import 'package:doyel_live/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

class _Messenger extends MessengerController {
  final sent = <Map<String, dynamic>>[];
  @override
  void tryToSendChatMessage({required dynamic data}) {
    sent.add(Map<String, dynamic>.from(data as Map));
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    final auth = TestAuthController();
    auth.profile.value = buildTestProfile(uid: 10);
    Get.put<AuthController>(auth);
  });
  tearDown(Get.reset);

  testWidgets(
    'composer retains send behavior across empty, loading, and ready states',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final messenger = _Messenger();
      messenger.loadingMessageList.value = false;
      Get.put<MessengerController>(messenger);
      Get.put(LiveStreamingController());
      Map<String, dynamic>? localMessage;
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MessagesCompose(
                chatId: '10_20',
                peerUserId: 20,
                peerUserFullName: 'Friend',
                peerUserProfileImage: null,
                onUpdateChatMessageWithWebSocketClient: (data) =>
                    localMessage = Map<String, dynamic>.from(data as Map),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final send = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Send message',
      );
      expect(tester.takeException(), isNull);
      expect(tester.widget<IconButton>(send).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '  Hello\nfriend  ');
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(send).onPressed, isNotNull);
      messenger.loadingMessageList.value = true;
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(send).onPressed, isNull);
      messenger.loadingMessageList.value = false;
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(messenger.sent.single['message'], 'Hello\nfriend');
      expect(localMessage?['chat_id'], '10_20');
      expect(localMessage?['receiver_id'], 20);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.widget<IconButton>(send).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
