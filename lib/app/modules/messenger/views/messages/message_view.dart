import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/modules/messenger/views/widgets/modified/messages_list_widget.dart';

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Block', icon: Icons.block),
];

class MessagesView extends StatefulWidget {
  MessagesView({
    super.key,
    required this.profile,
    required this.chatId,
    required this.isShowInLive,
  });
  final dynamic profile;
  final String chatId;
  final bool isShowInLive;

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView>
    with WidgetsBindingObserver {
  final AuthController _authController = Get.find();
  final MessengerController _messengerController = Get.find();
  // FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // FireBaseHelper().updateUserStatus(
    //     userStatus: "Online", uid: _authController.profile.value.user!.uid!);
    _messengerController.setClearChatMessages();
    _messengerController.tryToFetchChatMessages(chatId: widget.chatId);
    super.initState();
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // FireBaseHelper().updateUserStatus(
    //     userStatus: FieldValue.serverTimestamp(),
    //     uid: _authController.profile.value.user!.uid!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return HelperFunctions().actionForBackPressed();
        },
        child: Scaffold(
          appBar: widget.isShowInLive ? null : buildAppBar(),
          // body: Body(),
          // body: MessageBody(
          //   chatId: widget.chatId,
          //   peerUserId: widget.profile['user']['uid'],
          //   peerUsername: widget.profile['full_name'],
          //   peerUserImageUrl: widget.profile['profile_image'],
          // ),
          body: MessagesList(chatId: widget.chatId, profile: widget.profile),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios),
            constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
          ),
          // widget.profile['profile_image'] == null
          //     ? const CircleAvatar(
          //         backgroundColor: Colors.blueGrey,
          //         backgroundImage: AssetImage('assets/others/person.jpg'),
          //         radius: 16,
          //       )
          //     : CircleAvatar(
          //         backgroundColor: Colors.blueGrey,
          //         backgroundImage: CachedNetworkImageProvider(
          //             widget.profile['profile_image']),
          //         radius: 16,
          //       ),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: widget.profile['profile_image'] == null
                ? Image.asset(
                    'assets/others/person.jpg',
                    fit: BoxFit.cover,
                    height: 36,
                    width: 36,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.profile['profile_image']!,
                    fit: BoxFit.cover,
                    height: 36,
                    width: 36,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                  ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.profile['full_name']}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  'Active',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                // StreamBuilder(
                //   stream: _firestore
                //       .collection('users')
                //       .where('userId', isEqualTo: widget.profile['user']['uid'])
                //       .snapshots(),
                //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                //     String userStatus = "";
                //     if (snapshot.data?.docs[0]["userStatus"] != null) {
                //       if (snapshot.data?.docs[0]["userStatus"] == "Online") {
                //         userStatus = "Active";
                //       } else if (snapshot.data?.docs[0]["userStatus"] ==
                //           "typing....") {
                //         userStatus = snapshot.data?.docs[0]["userStatus"];
                //       } else {
                //         try {
                //           userStatus =
                //               'Active ${timeago.format(DateTime.parse(snapshot.data!.docs[0]["userStatus"].toDate().toString()).toLocal())}';
                //         } catch (e) {
                //           userStatus = 'Active';
                //         }
                //       }
                //     }
                //     return Text(
                //       userStatus,
                //       style: TextStyle(
                //         fontSize: 14,
                //         color: userStatus == "Active"
                //             ? Colors.green
                //             : Colors.orange,
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.menu_open_outlined),
        //   onPressed: () {},
        //   constraints: const BoxConstraints(
        //     maxHeight: 24,
        //     maxWidth: 24,
        //   ),
        // ),
        Obx(() {
          if (_messengerController.loadingMessageList.value ||
              _messengerController.loadingChatBlock.value) {
            return const SizedBox(
              height: 24,
              width: 24,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (_messengerController.isChatBlocked.value) {
            return Container();
          }
          return PopupMenuButton<Choice>(
            icon: const Icon(Icons.menu_open_outlined, color: Colors.white),
            color: Theme.of(context).primaryColor,
            onSelected: (Choice choice) {
              _selectPupupMenuItem(choice, context);
            },
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: ListTile(
                    leading: Icon(choice.icon, color: Colors.white),
                    title: Text(
                      choice.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList();
            },
          );
        }),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // FireBaseHelper().updateUserStatus(
        //     userStatus: FieldValue.serverTimestamp(),
        //     uid: _authController.profile.value.user!.uid!);
        break;
      case AppLifecycleState.inactive:
        // FireBaseHelper().updateUserStatus(
        //     userStatus: FieldValue.serverTimestamp(),
        //     uid: _authController.profile.value.user!.uid!);

        break;
      case AppLifecycleState.detached:
        // FireBaseHelper().updateUserStatus(
        //     userStatus: FieldValue.serverTimestamp(),
        //     uid: _authController.profile.value.user!.uid!);

        break;
      case AppLifecycleState.resumed:
        // FireBaseHelper().updateUserStatus(
        //     userStatus: "Online",
        //     uid: _authController.profile.value.user!.uid!);

        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _selectPupupMenuItem(Choice choice, BuildContext context) {
    int index = choices.indexOf(choice);
    if (index > -1) {
      if (index == 0) {
        // Block User
        Get.defaultDialog(
          title: 'Block',
          content: const Text('Are you sure block this person?'),
          onCancel: () => Get.close,
          onConfirm: () {
            _messengerController
                .tryToUpdateChatBlock(chatId: widget.chatId)
                .then((value) => Get.back());
            // DocumentReference<Map<String, dynamic>> myRef = _firestore
            //     .collection('users')
            //     .doc('${_authController.profile.value.user!.uid!}');
            // myRef.update({
            //   'blocks':
            //       FieldValue.arrayUnion([widget.profile['user']['uid']]),
            // }).whenComplete(() => Get.back());
          },
        );
      }
    }
  }
}
