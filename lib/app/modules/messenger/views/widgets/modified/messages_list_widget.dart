import 'dart:convert';
import 'dart:io';

import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/modules/messenger/views/widgets/modified/message_compose_widget.dart';
import 'package:doyel_live/app/modules/messenger/views/widgets/modified/receiver_message_card_widget.dart';
import 'package:doyel_live/app/modules/messenger/views/widgets/modified/sender_message_card_widget.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:web_socket_client/web_socket_client.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({
    Key? key,
    required this.chatId,
    required this.profile,
  }) : super(key: key);
  final String chatId;
  final dynamic profile;

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final AuthController _authController = Get.find();
  final MessengerController _messengerController = Get.find();
  WebSocket? webSocketClientForActions;
  String _webSocketConnectionState = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    initWebSocketClientForActions();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (webSocketClientForActions != null) {
      webSocketClientForActions!.close(1000, 'CLOSE_NORMAL');
    }
    super.dispose();
  }

  initWebSocketClientForActions() async {
    if (webSocketClientForActions != null &&
        _webSocketConnectionState != 'disconnecting' &&
        _webSocketConnectionState != 'disconnected') {
      // _socket!.connection.state != Disconnecting() &&
      // _socket!.connection.state != Disconnected()) {
      // print('Returned............................................');
      return;
    }

    // Create a WebSocket client.
    final uri = Uri.parse(
      kWebSocketChatRoomUrl(
        roomName: refineDeviceName(deviceName: widget.chatId),
      ),
    );
    // const backoff = ConstantBackoff(Duration(seconds: 1));
    final backoff = LinearBackoff(
      initial: const Duration(seconds: 0),
      increment: const Duration(seconds: 1),
      maximum: const Duration(seconds: 5),
    );
    webSocketClientForActions = WebSocket(uri, backoff: backoff);

    // Listen for changes in the connection state.
    webSocketClientForActions!.connection.listen((state) {
      // do nothing if already disposed
      if (_isDisposed) {
        return;
      }
      if (state == const Connecting()) {
        // print('connecting: the connection has not yet been established.');
        _webSocketConnectionState = 'connecting';
      } else if (state == const Connected()) {
        // print(
        //     ' connected: the connection is established and communication is possible.');
        _webSocketConnectionState = 'connected';
      } else if (state == const Reconnecting()) {
        // print(
        //     ' reconnecting: the connection was lost and is in the process of being re-established.');
        _webSocketConnectionState = 'reconnecting';
      } else if (state == const Reconnected()) {
        // print(
        //     'reconnected: the connection was lost and has been re-established.');
        _webSocketConnectionState = 'reconnected';
      } else if (state == const Disconnecting()) {
        // print(
        //     ' disconnecting: the connection is going through the closing handshake or the close method has been invoked.');
        try {
          _webSocketConnectionState = 'disconnecting';
        } catch (e) {
          //
        }
      } else if (state == const Disconnected()) {
        // print(
        //     ' disconnected: the WebSocket connection has been closed or could not be established.');
        try {
          _webSocketConnectionState = 'disconnected';
        } catch (e) {
          //
        }
      }
    });

    // Listen for incoming messages.
    webSocketClientForActions!.messages.listen((message) {
      dynamic data = jsonDecode(message)['message'];
      if (data['gzip'] != null) {
        List<int> gzipDecodedBytes = gzip.decode(data['gzip'].cast<int>());
        Map<String, dynamic> gzipData =
            jsonDecode(utf8.decode(gzipDecodedBytes));
        data['gzip'] = null;
        data = {...data, ...gzipData};
      }
      if (data['action'] != null && data['action'] == 'update_chat_block') {
        _messengerController.isChatBlocked.value = data['is_blocked'];
        _messengerController.chatBlockedBy.value = data['blocked_by'];
      } else {
        _messengerController.listChatMessage.insert(0, data);
      }
    });
  }

  void onUpdateChatMessageWithWebSocketClient(dynamic data) {
    // web_socket_client
    if (webSocketClientForActions != null) {
      final jsonEncodedData = jsonEncode(data);

      // print(
      //     'jsonEncodedData Action Socket: ${jsonEncodedData.length}.................................');
      final gzipEncodedData = gzip.encode(utf8.encode(jsonEncodedData));
      // print(
      //     'gzipEncodedData Action Socket: ${gzipEncodedData.length}.................................');

      dynamic sendableData;

      if (jsonEncodedData.length > gzipEncodedData.length) {
        sendableData = jsonEncode({
          'message': {
            'gzip': gzipEncodedData,
          },
        });
      } else {
        sendableData = jsonEncode({
          'message': data,
        });
      }

      // print('anchoringPkId: $anchoringPkId ..........................');

      try {
        webSocketClientForActions!.send(sendableData);
      } catch (e) {
        //
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _messengerController.loadingMessageList.value
              ? Expanded(
                  child: Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 50.0,
                    ),
                  ),
                )
              : Container(),
          _messengerController.listChatMessage.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text('No Message'),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    reverse: true,
                    itemCount: _messengerController.listChatMessage.length,
                    itemBuilder: (context, index) {
                      final listTemp =
                          _messengerController.listChatMessage.toList();
                      final chatDoc = listTemp[index];
                      if (_authController.profile.value.user!.uid! ==
                          chatDoc['sender_id']) {
                        return InkWell(
                          onLongPress: () async {
                            if (_messengerController.isChatBlocked.value) {
                              Get.snackbar(
                                "Can't delete message",
                                "Chat is blocked",
                                backgroundColor: Colors.black,
                              );
                              return;
                            }
                            // bool isBlocked =
                            //     await FireBaseHelper().blockChecker(
                            //   peerUserId: widget.profile['user']['uid'],
                            //   peerUserFullName: widget.profile['full_name'],
                            // );
                            // if (isBlocked) {
                            //   return;
                            // }
                            // Deleting message with Storage reference
                            Get.defaultDialog(
                                content: const Text('Will remove for both'),
                                title: 'Delete',
                                textConfirm: 'Confirm',
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () async {
                                  // await FirebaseFirestore.instance
                                  //     .runTransaction(
                                  //         (Transaction myTransaction) async {
                                  //   myTransaction.delete(chatDoc.reference);
                                  //   Get.back();
                                  // });
                                  await _messengerController
                                      .tryToDeleteChatMessage(data: {
                                    'action': 'one_message',
                                    'chat_id': widget.chatId,
                                    '_id': chatDoc['_id'],
                                    'key': chatDoc['key'],
                                  }).then((value) => Get.back());
                                });
                          },
                          onTap: () async {
                            // bool isBlocked =
                            //     await FireBaseHelper().blockChecker(
                            //   peerUserId: widget.profile['user']['uid'],
                            //   peerUserFullName: widget.profile['full_name'],
                            // );
                            // if (isBlocked) {
                            //   return;
                            // }
                          },
                          child: SenderMessageCard(
                            '',
                            chatDoc['type'].toString(),
                            chatDoc['message'].toString(),
                            chatDoc['datetime'] == null
                                ? DateFormat('dd-MM-yyyy hh:mm a')
                                    .format(DateTime.now())
                                : DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(chatDoc['datetime'])),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () async {
                            // bool isBlocked =
                            //     await FireBaseHelper().blockChecker(
                            //   peerUserId: widget.profile['user']['uid'],
                            //   peerUserFullName: widget.profile['full_name'],
                            // );
                            // if (isBlocked) {
                            //   return;
                            // }
                          },
                          child: ReceiverMessageCard(
                            '',
                            chatDoc['type'].toString(),
                            chatDoc['message'].toString(),
                            chatDoc['datetime'] == null
                                ? DateFormat('dd-MM-yyyy hh:mm a')
                                    .format(DateTime.now())
                                : DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(
                                      chatDoc['datetime'],
                                    ),
                                  ),
                          ),
                        );
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                  ),
                ),
          MessagesCompose(
            chatId: widget.chatId,
            peerUserId: widget.profile['user']['uid'],
            peerUserFullName: widget.profile['full_name'],
            peerUserProfileImage: widget.profile['profile_image'],
            onUpdateChatMessageWithWebSocketClient:
                onUpdateChatMessageWithWebSocketClient,
          ),
        ],
      );
    });
    // return Column(
    //   children: [
    //     Expanded(
    //       child: StreamBuilder(
    //         stream:
    //             FireBaseHelper().getMessages(context, chatId: widget.chatId),
    //         builder:
    //             (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //           if (snapshot.hasError) {
    //             return const Text('Something went wrong try again');
    //           }
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return const Center(
    //               child: CircularProgressIndicator(),
    //             );
    //           }

    //           return snapshot.data!.size == 0
    //               ? const Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Center(child: Text('No messages')),
    //                   ],
    //                 )
    //               : ListView.builder(
    //                   reverse: true,
    //                   shrinkWrap: true,
    //                   itemCount: snapshot.data!.docs.length,
    //                   itemBuilder: (context, index) {
    //                     final chatDoc = snapshot.data!.docs[index];
    //                     if (_authController.profile.value.user!.uid! ==
    //                         chatDoc['senderId']) {
    //                       return InkWell(
    //                         onLongPress: () async {
    //                           bool isBlocked =
    //                               await FireBaseHelper().blockChecker(
    //                             peerUserId: widget.profile['user']['uid'],
    //                             peerUserFullName: widget.profile['full_name'],
    //                           );
    //                           if (isBlocked) {
    //                             return;
    //                           }
    //                           // Deleting message with Storage reference
    //                           Get.defaultDialog(
    //                               content: const Text('Will remove for both'),
    //                               title: 'Delete',
    //                               textConfirm: 'Confirm',
    //                               confirmTextColor: Colors.white,
    //                               buttonColor: Colors.red,
    //                               onConfirm: () async {
    //                                 await FirebaseFirestore.instance
    //                                     .runTransaction(
    //                                         (Transaction myTransaction) async {
    //                                   myTransaction.delete(chatDoc.reference);
    //                                   Get.back();
    //                                 });
    //                               });
    //                         },
    //                         onTap: () async {
    //                           bool isBlocked =
    //                               await FireBaseHelper().blockChecker(
    //                             peerUserId: widget.profile['user']['uid'],
    //                             peerUserFullName: widget.profile['full_name'],
    //                           );
    //                           if (isBlocked) {
    //                             return;
    //                           }
    //                         },
    //                         child: SenderMessageCard(
    //                             chatDoc['fileName'].toString(),
    //                             chatDoc['msgType'].toString(),
    //                             chatDoc['message'].toString(),
    //                             chatDoc['msgTime'] == null
    //                                 ? DateFormat('dd-MM-yyyy hh:mm a').format(
    //                                     DateTime.parse(Timestamp.now()
    //                                         .toDate()
    //                                         .toString()))
    //                                 : DateFormat('dd-MM-yyyy hh:mm a').format(
    //                                     DateTime.parse(snapshot
    //                                         .data!.docs[index]['msgTime']
    //                                         .toDate()
    //                                         .toString()))),
    //                       );
    //                     } else {
    //                       return InkWell(
    //                         onTap: () async {
    //                           bool isBlocked =
    //                               await FireBaseHelper().blockChecker(
    //                             peerUserId: widget.profile['user']['uid'],
    //                             peerUserFullName: widget.profile['full_name'],
    //                           );
    //                           if (isBlocked) {
    //                             return;
    //                           }
    //                         },
    //                         child: ReceiverMessageCard(
    //                           chatDoc['fileName'].toString(),
    //                           chatDoc['msgType'].toString(),
    //                           chatDoc['message'].toString(),
    //                           chatDoc['msgTime'] == null
    //                               ? DateFormat('dd-MM-yyyy hh:mm a').format(
    //                                   DateTime.parse(
    //                                       Timestamp.now().toDate().toString()))
    //                               : DateFormat('dd-MM-yyyy hh:mm a').format(
    //                                   DateTime.parse(
    //                                     snapshot.data!.docs[index]['msgTime']
    //                                         .toDate()
    //                                         .toString(),
    //                                   ),
    //                                 ),
    //                         ),
    //                       );
    //                     }
    //                   });
    //         },
    //       ),
    //     ),
    //     MessagesCompose(
    //       chatId: widget.chatId,
    //       peerUserId: widget.profile['user']['uid'],
    //       peerUserFullName: widget.profile['full_name'],
    //       peerUserProfileImage: widget.profile['profile_image'],
    //     ),
    //   ],
    // );
  }
}
