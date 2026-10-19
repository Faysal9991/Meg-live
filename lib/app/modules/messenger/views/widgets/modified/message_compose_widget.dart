import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';

class MessagesCompose extends StatefulWidget {
  const MessagesCompose({
    Key? key,
    required this.chatId,
    required this.peerUserId,
    required this.peerUserFullName,
    required this.peerUserProfileImage,
    required this.onUpdateChatMessageWithWebSocketClient,
  }) : super(key: key);
  final String? chatId, peerUserFullName, peerUserProfileImage;
  final int peerUserId;
  final Function onUpdateChatMessageWithWebSocketClient;

  @override
  State<MessagesCompose> createState() => _MessagesComposeState();
}

class _MessagesComposeState extends State<MessagesCompose>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final AuthController _authController = Get.find();
  final MessengerController _messengerController = Get.find();
  final LiveStreamingController _livekitStreamingController = Get.find();
  bool sendChatButton = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppInsetSurface(
              child: TextField(
                controller: _textController,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                minLines: 1,
                onChanged: (value) =>
                    setState(() => sendChatButton = value.trim().isNotEmpty),
                decoration: const InputDecoration(
                  fillColor: AppColors.transparent,
                  hintText: 'Type your message',
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final loading = _messengerController.loadingMessageList.value;
            return AppIconButton(
              icon: Icons.send_rounded,
              tooltip: 'Send message',
              backgroundColor: AppColors.primary,
              iconColor: AppColors.textOnPrimary,
              onPressed: sendChatButton && !loading ? _sendMessage : null,
            );
          }),
        ],
      ),
    ),
  );

  Future<void> _sendMessage() async {
    if (_messengerController.isChatBlocked.value) {
      Get.snackbar(
        "Can't send message",
        "Chat is blocked by ${_messengerController.chatBlockedBy.value == _authController.profile.value.user!.uid! ? "you" : widget.peerUserFullName}",
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
        animationDuration: Duration.zero,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    if (_messengerController.loadingMessageList.value) {
      return;
    }
    String textMessage = _textController.text.trim();
    if (sendChatButton && textMessage.isNotEmpty) {
      String datetimeStr = DateTime.now().toIso8601String();
      dynamic data = {
        "key": "${widget.chatId}-$datetimeStr",
        "chat_id": widget.chatId,
        "sender_id": _authController.profile.value.user!.uid!,
        "receiver_id": widget.peerUserId,
        "type": "text",
        "message": textMessage,
        "sender_image": _authController.profile.value.profile_image,
        "receiver_image": widget.peerUserProfileImage,
        "sender_full_name": _authController.profile.value.full_name,
        "receiver_full_name": widget.peerUserFullName,
      };

      Map<String, dynamic> globalData = {};
      globalData.assignAll(data);

      globalData['type'] = 'chat_text_message';

      widget.onUpdateChatMessageWithWebSocketClient(data);
      _livekitStreamingController.onUpdateLiveStreamStatus(globalData);

      _messengerController.tryToSendChatMessage(data: data);

      _textController.clear();
      setState(() {
        sendChatButton = false;
      });
    }
  }
}
