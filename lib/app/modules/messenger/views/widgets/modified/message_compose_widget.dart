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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width - 65,
            child: Card(
              color: Theme.of(context).primaryColor,
              margin: const EdgeInsets.only(left: 5, right: 5, bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  controller: _textController,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      //   FireBaseHelper().updateUserStatus(
                      //     userStatus: "typing....",
                      //     uid: _authController.profile.value.user!.uid!,
                      //   );
                      setState(() {
                        sendChatButton = true;
                      });
                    } else {
                      //   FireBaseHelper().updateUserStatus(
                      //     userStatus: "Active",
                      //     uid: _authController.profile.value.user!.uid!,
                      //   );
                      setState(() {
                        sendChatButton = false;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type your message",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 2),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
                onPressed: () async {
                  if (_messengerController.isChatBlocked.value) {
                    Get.snackbar(
                      "Can't send message",
                      "Chat is blocked by ${_messengerController.chatBlockedBy.value == _authController.profile.value.user!.uid! ? "you" : widget.peerUserFullName}",
                      backgroundColor: Colors.red,
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
                      "sender_image":
                          _authController.profile.value.profile_image,
                      "receiver_image": widget.peerUserProfileImage,
                      "sender_full_name":
                          _authController.profile.value.full_name,
                      "receiver_full_name": widget.peerUserFullName,
                    };

                    //              {
                    //     "_id": "2-3-2",
                    //     "chat_id": "2-3",
                    //     "datetime": "2024-06-08T08:45:50.143Z",
                    //     "full_name": "Than Aung Kyow",
                    //     "key": "2-3-2024-06-08T14:45:48.525542",
                    //     "message": "tttt",
                    //     "profile_image": "https://lh3.googleusercontent.com/a/AAcHTtedUejF-3mKlCXdgOinxLaaPE48tI5jMpRWcuV6SZKP7A=s96-c",
                    //     "receiver_id": 2,
                    //     "sender_id": 2,
                    //     "type": "text",
                    //     "user_id": 2
                    // };

                    Map<String, dynamic> globalData = {};
                    globalData.assignAll(data);

                    globalData['type'] = 'chat_text_message';

                    // _messengerController.listChatMessage.add(data);
                    widget.onUpdateChatMessageWithWebSocketClient(data);
                    _livekitStreamingController
                        .onUpdateLiveStreamStatus(globalData);

                    _messengerController.tryToSendChatMessage(data: data);

                    _textController.clear();
                    setState(() {
                      sendChatButton = false;
                    });
                    // FireBaseHelper().updateUserStatus(
                    //   userStatus: "Active",
                    //   uid: _authController.profile.value.user!.uid!,
                    // );
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                )),
          ),
        ),
      ],
    );
  }
}
