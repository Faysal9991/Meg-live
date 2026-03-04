import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/messenger/utils/utils.dart';
import 'package:doyel_live/app/modules/messenger/views/messages/message_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';

void showUserInfoBottomSheet({
  required BuildContext context,
  required dynamic data,
  required Function onUpdateAction,
}) {
  final ProfileController profileController = Get.find();
  final AuthController authController = Get.find();
  final LiveStreamingController streamingController = Get.find();

  Future.delayed(Duration.zero, () {
    profileController.fetchProfileForUserInfo(userId: data['uid']);
  });

  Widget _messageWidget({required dynamic data}) {
    dynamic profile = {
      'profile_image': data['profile_image'],
      'full_name': data['full_name'],
      'user': {'uid': data['uid']},
    };
    String chatId = getChatId(
      uid: authController.profile.value.user!.uid!,
      peeredUserId: data['uid'],
    );
    // Get.to(
    //   () => MessagesView(
    //     profile: profile,
    //     chatId: chatId,
    //   ),
    //   fullscreenDialog: true,
    // );
    return data['uid'] == authController.profile.value.user!.uid
        ? Container()
        : Expanded(
            child: MessagesView(
              profile: profile,
              chatId: chatId,
              isShowInLive: true,
            ),
          );
  }

  showModalBottomSheet(
    context: context,
    barrierColor: Colors.transparent,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) {
      // if (authController.showingOverlay.value) {
      //   Navigator.of(context).pop();
      // }
      return SafeArea(
        child: Obx(() {
          if (profileController.loadingProfileForUserInfo.value) {
            // Displaying LoadingSpinner to indicate waiting state
            return SizedBox(
              height: data['uid'] != authController.profile.value.user!.uid
                  ? 260
                  : 160,
              // decoration: BoxDecoration(
              //   gradient: Palette.linearGradient2,
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: SpinKitHourGlass(color: Colors.red, size: 50.0),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .60,
                          ),
                          child: Text(
                            "${data['full_name']}",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'ID: ${data['uid']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          } else if (profileController.profileForUserInfo != null) {
            final profileData = profileController.profileForUserInfo;
            profileData['uid'] = data['uid'];

            return Container(
              height:
                  //  streamingController.channelName.value ==
                  //             authController.profile.value.user!.uid.toString() &&
                  profileData['uid'] != authController.profile.value.user!.uid
                  ? MediaQuery.of(context).size.height * .70
                  : 160,
              // decoration: BoxDecoration(
              //   gradient: Palette.linearGradient2,
              // ),
              color: Colors.black,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        // color: Theme.of(context).primaryColor,
                        // color: Colors.black54,
                        // gradient: LinearGradient(
                        //   colors: [
                        //     Colors.black38,
                        //     Colors.black26,
                        //     Colors.black12,
                        //   ],
                        //   begin: Alignment.bottomLeft,
                        //   end: Alignment.topRight,
                        // ),
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              profileData['vvip_or_vip_preference'] != null &&
                                      profileData['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                          null
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        'L.V.${data['level'] != null ? data['level']['level'] : 0}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .60,
                                  ),
                                  child: Text(
                                    "${profileData['full_name']}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'ID: ${profileData['uid']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/others/diamond.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${profileData['diamonds']}',
                                        // '${(profileData['sender_diamonds'] ?? profileData['diamonds']) / 1000}K',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '⭐ ${profileData['diamonds'] != null ? (profileData['diamonds'] < 100000 ? 0 : (profileData['diamonds'] / 100000).floor()) : 0}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // Center(
                          //   child: Text(
                          //     'User Id: ${profileData['uid']}',
                          //     style: const TextStyle(
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.w700,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          profileData['uid'] !=
                                  authController.profile.value.user!.uid!
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        if (profileController
                                                .loadingPerformFollow
                                                .value ==
                                            profileData['uid']) {
                                          return;
                                        }
                                        List<dynamic> followers =
                                            await profileController
                                                .performFollow(
                                                  uid: profileData['uid'],
                                                );
                                        profileController.setAccountFollowers(
                                          followers,
                                        );
                                        onUpdateAction({
                                          'action': 'followers',
                                          'uid': profileData['uid'],
                                          'followers': followers,
                                        });
                                      },
                                      icon: Obx(() {
                                        return profileController
                                                    .loadingPerformFollow
                                                    .value !=
                                                profileData['uid']
                                            ? Icon(
                                                !profileController
                                                        .accountFollowers
                                                        .contains(
                                                          authController
                                                              .profile
                                                              .value
                                                              .user!
                                                              .uid!,
                                                        )
                                                    ? Icons.add
                                                    : Icons.remove,
                                                // color: !profileController
                                                //         .accountFollowers
                                                //         .contains(authController
                                                //             .profile
                                                //             .value
                                                //             .user!
                                                //             .uid!)
                                                //     ? Colors.blue
                                                //     : Colors.red,
                                                color: Colors.white,
                                                size: 12,
                                              )
                                            : Icon(
                                                Icons.refresh_rounded,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                size: 12,
                                              );
                                      }),
                                      label: Obx(() {
                                        return !profileController
                                                .accountFollowers
                                                .contains(
                                                  authController
                                                      .profile
                                                      .value
                                                      .user!
                                                      .uid!,
                                                )
                                            ? const Text(
                                                'Follow',
                                                style: TextStyle(fontSize: 12),
                                              )
                                            : const Text(
                                                'Unfollow',
                                                style: TextStyle(fontSize: 12),
                                              );
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    streamingController.channelName.value ==
                                            authController
                                                .profile
                                                .value
                                                .user!
                                                .uid
                                                .toString()
                                        ? ElevatedButton.icon(
                                            onPressed: () async {
                                              if (profileController
                                                      .loadingPerformBlock
                                                      .value ==
                                                  profileData['uid']) {
                                                return;
                                              }
                                              List<dynamic> blocks =
                                                  await profileController
                                                      .performBlock(
                                                        uid: profileData['uid'],
                                                      );
                                              onUpdateAction({
                                                'action': 'blocks',
                                                'uid': profileData['uid'],
                                                'blocks': blocks,
                                              });
                                            },
                                            icon: Obx(() {
                                              return profileController
                                                          .loadingPerformBlock
                                                          .value !=
                                                      profileData['uid']
                                                  ? Icon(
                                                      !authController
                                                              .profile
                                                              .value
                                                              .blocks!
                                                              .contains(
                                                                profileData['uid'],
                                                              )
                                                          ? Icons.block
                                                          : Icons.flag,
                                                      color: Colors.white,
                                                      size: 12,
                                                    )
                                                  : Icon(
                                                      Icons.refresh_rounded,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      size: 12,
                                                    );
                                            }),
                                            label: Obx(() {
                                              return !authController
                                                      .profile
                                                      .value
                                                      .blocks!
                                                      .contains(
                                                        profileData['uid'],
                                                      )
                                                  ? const Text(
                                                      'Block',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Unblock',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    );
                                            }),
                                          )
                                        : Container(),

                                    // Container(
                                    //   constraints: const BoxConstraints(
                                    //       maxHeight: 40, maxWidth: 40),
                                    //   child: IconButton(
                                    //     icon: const Icon(
                                    //       Icons.chat,
                                    //       color: Colors.white,
                                    //     ),
                                    //     iconSize: 32,
                                    //     onPressed: () {
                                    //       if (!streamingController
                                    //           .isBroadcaster.value) {
                                    //         rShowAlertDialog2(
                                    //           context: context,
                                    //           title: 'Not allowed',
                                    //           content:
                                    //               'Only host can go into Inbox',
                                    //           onConfirm: () {
                                    //             Navigator.pop(context);
                                    //           },
                                    //         );
                                    //         return;
                                    //       }
                                    //       dynamic profile = {
                                    //         'profile_image': profileData[
                                    //                     'profile_image'] ==
                                    //                 ''
                                    //             ? null
                                    //             : profileData[
                                    //                 'profile_image'],
                                    //         'full_name':
                                    //             profileData['full_name'],
                                    //         'user': {
                                    //           'uid': profileData['uid']
                                    //         },
                                    //       };
                                    //       String chatId = getChatId(
                                    //         uid: authController
                                    //             .profile.value.user!.uid!,
                                    //         peeredUserId: profileData['uid'],
                                    //       );
                                    //       authController.setShowingOverlay(
                                    //           overlay: true);
                                    //       Get.to(
                                    //         () => MessagesView(
                                    //           profile: profile,
                                    //           chatId: chatId,
                                    //         ),
                                    //         fullscreenDialog: true,
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                )
                              : Container(),

                          _messageWidget(data: data),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child:
                            data['profile_image'] == null &&
                                data['photo_url'] == null
                            ? Image.asset(
                                'assets/others/person.jpg',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl:
                                    data['profile_image'] ?? data['photo_url'],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child:
                          profileData['vvip_or_vip_preference'] != null &&
                              profileData['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                  null
                          ? Container(
                              margin: const EdgeInsets.only(left: 60),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                // borderRadius: BorderRadius.only(
                                //   bottomLeft: Radius.circular(20.0),
                                //   bottomRight: Radius.circular(20.0),
                                // ),
                                border: Border.all(
                                  color: Colors.orange.shade600,
                                  // width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      profileData['vvip_or_vip_preference']['vvip_or_vip_gif'],
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                            )
                          : Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: 60),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  '${data['level'] != null ? data['level']['level'] : 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            height: data['uid'] != authController.profile.value.user!.uid
                ? 260
                : 160,
            // decoration: BoxDecoration(
            //   gradient: Palette.linearGradient2,
            // ),
            child: const Center(
              child: Text(
                'Error occurred',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      );
    },
  );
}
