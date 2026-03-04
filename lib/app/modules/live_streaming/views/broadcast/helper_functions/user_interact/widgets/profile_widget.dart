import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    Key? key,
    required this.data,
    required this.onUpdateAction,
    required this.streamingController,
    required this.authController,
    required this.profileController,
  }) : super(key: key);
  final dynamic data;
  final Function onUpdateAction;
  final LiveStreamingController streamingController;
  final AuthController authController;
  final ProfileController profileController;

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // executes after build
      widget.profileController.fetchProfileForHost(userId: widget.data['uid']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.profileController.loadingProfileForHost.value) {
        // Displaying LoadingSpinner to indicate waiting state
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User ID: ${widget.data['uid']}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Center(
              child: SpinKitHourGlass(
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ],
        );
      } else if (widget.profileController.profileForHost.value['full_name'] ==
          null) {
        return const Text('Something is wrong');
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.profileController.profileForHost.value['followers'].length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    'Fans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 32,
              ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Text(
              //           '${data['diamonds']}',
              //           style: const TextStyle(
              // color: Colors.white,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w700,
              //           ),
              //         ),
              //         const SizedBox(
              //           width: 4,
              //         ),
              //         const Text(
              //           'Diamonds',
              //           style: TextStyle(
              // color: Colors.white,
              //             fontSize: 16,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 8,
              // ),
              // Center(
              //   child: Text(
              //     'User Id: ${data['uid']}',
              //     style: const TextStyle(
              // color: Colors.white,
              //       fontSize: 18,
              //       fontWeight: FontWeight.w700,
              //     ),
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.diamond,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${widget.profileController.profileForHost.value['diamonds']}',
                    // '${(data['sender_diamonds'] ?? data['diamonds']) / 1000}K',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  // Image.asset(
                  //   'images/icons/coin.png',
                  //   width: 16,
                  //   height: 16,
                  //   fit: BoxFit.contain,
                  // ),
                  // const SizedBox(
                  //   width: 4,
                  // ),
                  // Text(
                  //   '${widget.profileController.profileForHost.value['gift_coins']}',
                  //   // '${profileController.profileForHost.value['gift_coins'] / 1000}K',
                  //   style: const TextStyle(
                  // color: Colors.white,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    'User ID: ${widget.data['uid']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ///////////////
          // TODO: Need to uncomment and modify
          // FutureBuilder(
          //   future: profileController.fetchProfile(
          //       userId: data['uid']),
          //   builder: (context, snapshot) {
          //     // Checking if future is resolved
          //     if (snapshot.connectionState ==
          //         ConnectionState.done) {
          //       // If we got an error
          //       if (snapshot.hasError) {
          //         return const Center(
          //           child: Text(
          //             'Error occurred',
          //             style: TextStyle(
          //color: Colors.white,fontWeight: FontWeight.bold),
          //           ),
          //         );

          //         // if we got our data
          //       } else if (snapshot.hasData) {
          //         // Extracting data from snapshot object
          //         final profileData = snapshot.data as dynamic;
          //         profileController.setHostAccountFollowers(
          //             profileData['followers'] ?? []);
          //         return _profileWidget(
          //           data: profileData,
          //           context: context,
          //           authController: authController,
          //           profileController: _profileController,
          //           streamingController: streamingController,
          //           onUpdateAction: onUpdateAction,
          //         );
          //       }
          //     }
          //     // Displaying LoadingSpinner to indicate waiting state
          //     return Center(
          //       child: SpinKitHourGlass(
          //         color: Theme.of(context).primaryColor,
          //         size: 50.0,
          //       ),
          //     );
          //   },
          // ),
          widget.data['uid'] != widget.authController.profile.value.user!.uid
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (widget
                                .profileController.loadingPerformFollow.value ==
                            widget.data['uid']) {
                          return;
                        }
                        List<dynamic> followers = await widget.profileController
                            .performFollow(uid: widget.data['uid']);
                        widget.profileController
                            .setHostAccountFollowers(followers);
                        widget.onUpdateAction({
                          'action': 'followers',
                          'uid': widget.data['uid'],
                          'followers': followers,
                        });
                      },
                      icon: Obx(() {
                        return widget.profileController.loadingPerformFollow
                                    .value !=
                                widget.data['uid']
                            ? Icon(
                                !widget.profileController.hostAccountFollowers
                                        .contains(widget.authController.profile
                                            .value.user!.uid!)
                                    ? Icons.add
                                    : Icons.remove,
                                // color: !profileController.hostAccountFollowers
                                //         .contains(authController
                                //             .profile.value.user!.uid!)
                                //     ? Colors.blue
                                //     : Colors.red,
                                color: Colors.white,
                                size: 12,
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 12,
                              );
                      }),
                      label: Obx(() {
                        return !widget.profileController.hostAccountFollowers
                                .contains(widget
                                    .authController.profile.value.user!.uid!)
                            ? const Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            : const Text(
                                'Unfollow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                      }),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        // fixedSize: Size(
                        //     MediaQuery.of(context).size.width - 90, 40),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    widget.streamingController.channelName.value ==
                            widget.authController.profile.value.user!.uid
                                .toString()
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              if (widget.profileController.loadingPerformBlock
                                      .value ==
                                  widget.data['uid']) {
                                return;
                              }
                              List<dynamic> blocks = await widget
                                  .profileController
                                  .performBlock(uid: widget.data['uid']);
                              widget.onUpdateAction({
                                'action': 'blocks',
                                'uid': widget.data['uid'],
                                'blocks': blocks,
                              });
                            },
                            icon: Obx(() {
                              return widget.profileController
                                          .loadingPerformBlock.value !=
                                      widget.data['uid']
                                  ? Icon(
                                      !widget.authController.profile.value
                                              .blocks!
                                              .contains(widget.data['uid'])
                                          ? Icons.block
                                          : Icons.flag,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 12,
                                    );
                            }),
                            label: Obx(() {
                              return !widget
                                      .authController.profile.value.blocks!
                                      .contains(widget.data['uid'])
                                  ? const Text(
                                      'Block',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    )
                                  : const Text(
                                      'Unblock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                            }),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              // fixedSize: Size(
                              //     MediaQuery.of(context).size.width - 90, 40),
                            ),
                          )
                        : Container(),
                    widget.streamingController.channelName.value ==
                            widget.authController.profile.value.user!.uid
                                .toString()
                        ? const SizedBox(
                            width: 8,
                          )
                        : Container(),
                    ElevatedButton(
                      onPressed: () {
                        // Get.snackbar(
                        //   'Coming Soon',
                        //   "Will be implemented later.",
                        //   backgroundColor: Colors.orange,
                        //   colorText: Colors.white,
                        // );
                        // rShowSnackBar(
                        //   context: context,
                        //   title: "Coming soon",
                        //   color: Colors.green,
                        //   durationInSeconds: 1,
                        // );
                        rShowAlertDialog(
                          context: context,
                          title: 'Coming soon',
                          content: 'Please try again later',
                          onConfirm: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        // fixedSize: Size(
                        //     MediaQuery.of(context).size.width - 90, 40),
                      ),
                      child: const Text(
                        'Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 8,
                    // ),
                    // Container(
                    //   constraints:
                    //       const BoxConstraints(maxHeight: 40, maxWidth: 40),
                    //   margin: const EdgeInsets.only(left: 8),
                    //   child: IconButton(
                    //       icon: const Icon(
                    //         Icons.chat,
                    //         color: Colors.white,
                    //       ),
                    //       iconSize: 32,
                    //       onPressed: () {
                    //         if (!widget
                    //             .streamingController.isBroadcaster.value) {
                    //           rShowAlertDialog2(
                    //             context: context,
                    //             title: 'Not allowed',
                    //             content: 'Only host can go into Inbox',
                    //             onConfirm: () {
                    //               Navigator.pop(context);
                    //             },
                    //           );
                    //           return;
                    //         }
                    //         dynamic profile = {
                    //           'profile_image':
                    //               widget.data['profile_image'] == ''
                    //                   ? null
                    //                   : widget.data['profile_image'],
                    //           'full_name': widget.data['full_name'],
                    //           'user': {'uid': widget.data['uid']},
                    //         };
                    //         String chatId = getChatId(
                    //           uid: widget
                    //               .authController.profile.value.user!.uid!,
                    //           peeredUserId: widget.data['uid'],
                    //         );
                    //         widget.authController
                    //             .setShowingOverlay(overlay: true);
                    //         Get.to(
                    //           () => MessagesView(
                    //             profile: profile,
                    //             chatId: chatId,
                    //           ),
                    //           fullscreenDialog: true,
                    //         );
                    //       }),
                    // )
                  ],
                )
              : Container(),
        ],
      );
    });
  }
}
