import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/modules/messenger/views/messages/message_view.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({Key? key}) : super(key: key);

  @override
  _ChatListWidgetState createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  // late FirebaseFirestore _firestore;
  final AuthController _authController = Get.find();
  final MessengerController _messengerController = Get.find();

  @override
  void initState() {
    super.initState();
    _messengerController.setClearLastMessages();
    _messengerController.tryToFetchLastChatessages(
      uid: _authController.profile.value.user!.uid!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentBefore == 0) {
          // User has reached the end of the list
          // Load more data or trigger pagination in flutter
          _messengerController.loadLastMessagesMoreData(
              uid: _authController.profile.value.user!.uid!);
        }
        return false;
      },
      child: Material(
        textStyle: const TextStyle(
          color: Colors.black,
        ),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _messengerController.loadingLastMessageList.value
                      ? Center(
                          child: SpinKitCircle(
                            color: Theme.of(context).primaryColor,
                            size: 50.0,
                          ),
                        )
                      : Container(),
                  _messengerController.listLastMessage.isEmpty
                      ? const Center(
                          child: Text(
                            'No Message',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            itemCount:
                                _messengerController.listLastMessage.length,
                            itemBuilder: (context, index) {
                              var message = _messengerController.listLastMessage
                                  .elementAt(index);

                              return GestureDetector(
                                onLongPress: () {
                                  Get.defaultDialog(
                                      title: 'Go to delete',
                                      content: const Text(
                                          'Do you wanna delete this last message?'),
                                      confirmTextColor: Colors.white,
                                      onCancel: () => Get.back(),
                                      onConfirm: () async {
                                        await _messengerController
                                            .tryToDeleteChatMessage(data: {
                                          'action': 'last_message',
                                          'chat_id': message['chat_id'],
                                          'user_id': message['user_id'],
                                        }).then((value) => Get.back());
                                        // Get.back();
                                      });
                                },
                                child: chatItem(
                                  message: message,
                                  authController: _authController,
                                  messengerController: _messengerController,
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                height: 8,
                              );
                            },
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: StreamBuilder<QuerySnapshot>(
    //     stream: FireBaseHelper().getLastMessages(
    //         context, _authController.profile.value.user!.uid!.toString()),
    //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       if (snapshot.hasError) {
    //         return const Text(
    //           'Something went wrong',
    //           style: TextStyle(fontSize: 15, color: Colors.red),
    //         );
    //       }

    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(
    //           child: SpinKitCubeGrid(
    //             color: Theme.of(context).primaryColor,
    //             size: 50.0,
    //           ),
    //         );
    //       }

    //       final messages = snapshot.data?.docs;
    //       if (messages!.isEmpty) {
    //         return const Center(
    //           child: Text('Empty message list'),
    //         );
    //       }
    //       return ListView.builder(
    //         itemCount: messages.length,
    //         itemBuilder: (context, index) {
    //           var message = messages.elementAt(index);
    //           return GestureDetector(
    //             onLongPress: () {
    //               Get.defaultDialog(
    //                   title: 'Go to delete',
    //                   content:
    //                       const Text('Do you wanna delete this last message?'),
    //                   confirmTextColor: Colors.white,
    //                   onCancel: () => Get.back(),
    //                   onConfirm: () {
    //                     _firestore
    //                         .collection('lastMessages')
    //                         .doc(_authController.profile.value.user!.uid!
    //                             .toString())
    //                         .collection('message-list')
    //                         .doc(message.id)
    //                         .delete();
    //                     Get.back();
    //                   });
    //             },
    //             child: chatItem(
    //               message: message,
    //               authController: _authController,
    //               firestore: _firestore,
    //             ),
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
  }
}

// {
//             "_id": "2-3-2",
//             "chat_id": "2-3",
//             "datetime": "2024-06-08T04:53:19.302Z",
//             "full_name": "Dummy",
//             "key": "unique_key2",
//             "message": "message 4",
//             "profile_image": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
//             "receiver_id": 3,
//             "sender_id": 2,
//             "type": "text",
//             "user_id": 2
//         }

Widget chatItem({
  required dynamic message,
  required AuthController authController,
  // required FirebaseFirestore firestore,
  required MessengerController messengerController,
}) {
  final chatId = message['chat_id'];

  int peerUserId = 0;
  List<String> ids = message['chat_id'].toString().split('_');
  if (ids[0] == authController.profile.value.user!.uid!.toString()) {
    peerUserId = int.parse(ids[1]);
  } else {
    peerUserId = int.parse(ids[0]);
  }

  String? peerUserImageUrl = message['profile_image'];
  String peerUsername = message['full_name'];
  return Card(
    margin: EdgeInsets.zero,
    elevation: 5,
    child: InkWell(
      onTap: () {
        dynamic profile = {
          'profile_image': peerUserImageUrl,
          'full_name': peerUsername,
          'user': {'uid': peerUserId},
        };
// 'assets/others/person.jpg'
        Get.to(() => MessagesView(
              profile: profile,
              chatId: chatId,
              isShowInLive: false,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              children: [
                Positioned(
                  top: 2,
                  left: 2,
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // color: Colors.grey,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: peerUserImageUrl == null
                          ? Image.asset(
                              'assets/others/person.jpg',
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: peerUserImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/others/person.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 0,
                  bottom: 4,
                  child: Icon(
                    Icons.circle,
                    // color: data["userStatus"] == "Online"
                    //     ? Colors.green
                    //     : Colors.orange,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$peerUsername',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  lastMessage(
                    authController: authController,
                    recentMessage: message,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Text(
            // timeago.format(DateTime.parse(message['msgTime'] == null
            //         ? DateFormat('dd-MM-yyyy hh:mm a').format(
            //             DateTime.parse(
            //                 Timestamp.now().toDate().toString()))
            //         : DateFormat('dd-MM-yyyy hh:mm a').format(
            //             DateTime.parse(
            //                 message['msgTime'].toDate().toString())))
            //     .toLocal()),
            message['datetime'] == null
                ? DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())
                : DateFormat('dd-MM-yyyy hh:mm a')
                    .format(DateTime.parse(message['datetime']).toLocal()),

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Text(
          //   Jiffy(
          //           message['msgTime'] == null
          //               ? DateFormat('dd-MM-yyyy hh:mm a').format(
          //                   DateTime.parse(
          //                       Timestamp.now().toDate().toString()))
          //               : DateFormat('dd-MM-yyyy hh:mm a').format(
          //                   DateTime.parse(message['msgTime']
          //                       .toDate()
          //                       .toString())),
          //           "dd-MM-yyyy hh:mm a")
          //       .fromNow(),
          //   style: const TextStyle(
          //     color: Colors.grey,
          //     fontSize: 12,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
        ]),
      ),
    ),
  );
  // return StreamBuilder(
  //     stream: firestore
  //         .collection('users')
  //         .where('userId', isEqualTo: peerUserId)
  //         .snapshots(),
  //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasData) {
  //         dynamic data = snapshot.data?.docs[0];
  //         peerUserImageUrl = data['profile_image'];
  //         peerUsername = data['full_name'];
  //         peerUserId = data['userId'];
  //         return InkWell(
  //           onTap: () {
  //             dynamic profile = {
  //               'profile_image': peerUserImageUrl,
  //               'full_name': peerUsername,
  //               'user': {'uid': peerUserId},
  //             };

  //             Get.to(() => MessagesView(
  //                   profile: profile,
  //                   chatId: chatId,
  //                 ));
  //           },
  //           child: Card(
  //             color: Theme.of(context).primaryColor,
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(children: [
  //                 SizedBox(
  //                   width: 54,
  //                   height: 54,
  //                   child: Stack(
  //                     children: [
  //                       Positioned(
  //                         top: 2,
  //                         left: 2,
  //                         right: 2,
  //                         bottom: 2,
  //                         child: Container(
  //                           width: 50,
  //                           height: 50,
  //                           decoration: BoxDecoration(
  //                             // color: Colors.grey,
  //                             color: Colors.black,
  //                             borderRadius: BorderRadius.circular(100),
  //                           ),
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(100),
  //                             child: peerUserImageUrl == null
  //                                 ? Image.asset(
  //                                     'assets/others/person.jpg',
  //                                     fit: BoxFit.cover,
  //                                   )
  //                                 : CachedNetworkImage(
  //                                     imageUrl: peerUserImageUrl!,
  //                                     fit: BoxFit.cover,
  //                                     placeholder: (context, url) =>
  //                                         const Center(
  //                                       child: CircularProgressIndicator(),
  //                                     ),
  //                                     errorWidget: (context, url, error) =>
  //                                         Image.asset(
  //                                       'assets/others/person.jpg',
  //                                       fit: BoxFit.cover,
  //                                     ),
  //                                   ),
  //                           ),
  //                         ),
  //                       ),
  //                       Positioned(
  //                         right: 0,
  //                         bottom: 4,
  //                         child: Icon(
  //                           Icons.circle,
  //                           color: data["userStatus"] == "Online"
  //                               ? Colors.green
  //                               : Colors.orange,
  //                           size: 16,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   width: 8,
  //                 ),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         '$peerUsername',
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                       Text(
  //                         lastMessage(
  //                           authController: authController,
  //                           recentMessage: message,
  //                         ),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Text(
  //                   // timeago.format(DateTime.parse(message['msgTime'] == null
  //                   //         ? DateFormat('dd-MM-yyyy hh:mm a').format(
  //                   //             DateTime.parse(
  //                   //                 Timestamp.now().toDate().toString()))
  //                   //         : DateFormat('dd-MM-yyyy hh:mm a').format(
  //                   //             DateTime.parse(
  //                   //                 message['msgTime'].toDate().toString())))
  //                   //     .toLocal()),
  //                   message['msgTime'] == null
  //                       ? DateFormat('dd-MM-yyyy hh:mm a').format(
  //                           DateTime.parse(Timestamp.now().toDate().toString())
  //                               .toLocal())
  //                       : DateFormat('dd-MM-yyyy hh:mm a').format(
  //                           DateTime.parse(
  //                                   message['msgTime'].toDate().toString())
  //                               .toLocal()),

  //                   style: const TextStyle(
  //                     // color: Colors.grey,
  //                     color: Colors.white70,
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 // Text(
  //                 //   Jiffy(
  //                 //           message['msgTime'] == null
  //                 //               ? DateFormat('dd-MM-yyyy hh:mm a').format(
  //                 //                   DateTime.parse(
  //                 //                       Timestamp.now().toDate().toString()))
  //                 //               : DateFormat('dd-MM-yyyy hh:mm a').format(
  //                 //                   DateTime.parse(message['msgTime']
  //                 //                       .toDate()
  //                 //                       .toString())),
  //                 //           "dd-MM-yyyy hh:mm a")
  //                 //       .fromNow(),
  //                 //   style: const TextStyle(
  //                 //     color: Colors.grey,
  //                 //     fontSize: 12,
  //                 //     fontWeight: FontWeight.w500,
  //                 //   ),
  //                 // ),
  //               ]),
  //             ),
  //           ),
  //         );
  //       }
  //       return const Center(child: CircularProgressIndicator());
  //     });
}

String lastMessage({
  required dynamic recentMessage,
  required AuthController authController,
}) {
  String message = '', messageType = '';
  messageType = recentMessage['type'];

  if (messageType == "text") {
    message =
        recentMessage['sender_id'] == authController.profile.value.user!.uid!
            ? "Me : ${recentMessage['message'].toString()}"
            : recentMessage['message'].toString();
  } else if (messageType == "image") {
    // message = recentMessage['sender_id'] ==
    //         authController.profile.value.user!.uid!
    //     ? "You sent image to ${recentMessage['messageTo']['full_name']}"
    //     : "${recentMessage['messageFrom']['full_name']} sent to you image";
    message =
        recentMessage['sender_id'] == authController.profile.value.user!.uid!
            ? "You sent image"
            : "Sent to you image";
  }
  // else if (messageType == "video") {
  //   message = recentMessage['messageSenderId'] ==
  //           authController.profile.value.user!.uid!
  //       ? "You sent video to ${recentMessage['messageTo']['full_name']}"
  //       : "${recentMessage['messageFrom']['full_name']} sent to you video";
  // } else if (messageType == "document") {
  //   message = recentMessage['messageSenderId'] ==
  //           authController.profile.value.user!.uid!
  //       ? "You sent document to ${recentMessage['messageTo']['full_name']}"
  //       : "${recentMessage['messageFrom']['full_name']} sent to you document";
  // } else if (messageType == "audio") {
  //   message = recentMessage['messageSenderId'] ==
  //           authController.profile.value.user!.uid!
  //       ? "You sent audio file to ${recentMessage['messageTo']['full_name']}"
  //       : "${recentMessage['messageFrom']['full_name']} sent to you audio file";
  // }
  else if (messageType == "voice message") {
    // message = recentMessage['messageSenderId'] ==
    //         authController.profile.value.user!.uid!
    //     ? "You sent voice message to ${recentMessage['messageTo']['full_name']}"
    //     : "${recentMessage['messageFrom']['full_name']} sent to you voice message";
    message =
        recentMessage['sender_id'] == authController.profile.value.user!.uid!
            ? "You sent voice message"
            : "Sent to you voice message";
  }

  return message;
}
