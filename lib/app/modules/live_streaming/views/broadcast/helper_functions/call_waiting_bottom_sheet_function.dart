import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/liveroom_isolation_actions.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/widgets/circle_button.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

void showCallWaitingBottomSheet({
  required BuildContext context,
  required dynamic data,
  required LiveStreamingController streamingController,
  required AuthController authController,
  required Function onUpdateAction,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: Colors.transparent,
    enableDrag: false,
    isScrollControlled: true,
    // shape: const RoundedRectangleBorder(
    //   borderRadius: BorderRadius.all(
    //     Radius.circular(30.0),
    //   ),
    // ),
    builder: (context) {
      // if (authController.showingOverlay.value) {
      //   Future.delayed(const Duration(milliseconds: 50), () {
      //     Navigator.of(context).pop();
      //   });
      // }
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () =>
                              streamingController.setCallTab(tabName: 'views'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'VIEWS',
                              style: TextStyle(
                                color:
                                    streamingController.callTabName.value ==
                                        'views'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => streamingController.setCallTab(
                            tabName: 'waiting',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'WAITING',
                              style: TextStyle(
                                color:
                                    streamingController.callTabName.value ==
                                        'waiting'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Obx(() {
                          if (streamingController.isBroadcaster.value) {
                            return InkWell(
                              onTap: () => streamingController.setCallTab(
                                tabName: 'live',
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color:
                                        streamingController.callTabName.value ==
                                            'live'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            if (streamingController.listRequestedCall
                                    .indexWhere(
                                      (element) =>
                                          element['uid'] ==
                                          authController
                                              .profile
                                              .value
                                              .user!
                                              .uid!,
                                    ) >
                                -1) {
                              return ElevatedButton(
                                onPressed: () {
                                  dynamic data = {
                                    // 'room_name':
                                    //     '${streamingController.channelName.value}_actions',
                                    'action': 'cancel_request',
                                    'uid':
                                        authController.profile.value.user!.uid!,
                                    'full_name':
                                        authController.profile.value.full_name,
                                    'profile_image':
                                        authController
                                            .profile
                                            .value
                                            .profile_image ??
                                        authController.profile.value.photo_url,
                                    // 'call_type': streamingController.callType.value,
                                    // 'muted': streamingController.muted.value,
                                    // 'video_disabled':
                                    //     streamingController.videoDisabled.value,
                                    // 'diamonds': authController.profile.value.diamonds,
                                    // 'gift_coins':
                                    //     authController.profile.value.gift_coins,
                                    // 'is_moderator': authController.profile.value.is_moderator,
                                    // 'is_host': authController.profile.value.is_host,
                                    // 'is_reseller':
                                    //     authController.profile.value.is_reseller,
                                    'level': authController.profile.value.level,
                                    'vvip_or_vip_preference': authController
                                        .profile
                                        .value
                                        .vvip_or_vip_preference,
                                    // 'followers':
                                    //     authController.profile.value.followers,
                                    // 'blocks': authController.profile.value.blocks,
                                  };
                                  onUpdateAction(data);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    // side: BorderSide(color: Colors.red),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (streamingController.listActiveCall
                                    .indexWhere(
                                      (element) =>
                                          element['uid'] ==
                                          authController
                                              .profile
                                              .value
                                              .user!
                                              .uid!,
                                    ) >
                                -1) {
                              return ElevatedButton(
                                onPressed: () {
                                  dynamic actionData = {
                                    "action": "end_call",
                                    "uid":
                                        authController.profile.value.user!.uid!,
                                  };
                                  onUpdateAction(actionData);
                                  dynamic submissionData = {
                                    'action': 'remove_user_from_calling_group',
                                    'channel_id': int.parse(
                                      streamingController.channelName.value,
                                    ),
                                    'uid':
                                        authController.profile.value.user!.uid!,
                                  };

                                  LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                                    submissionData: submissionData,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    // side: BorderSide(color: Colors.red),
                                  ),
                                ),
                                child: const Text('End Call'),
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (streamingController
                                        .listActiveCall
                                        .isEmpty) {
                                      rShowAlertDialog(
                                        context: context,
                                        title: "Not allowed",
                                        content:
                                            "Live data is not properly loaded yet. Please try again later",
                                        onConfirm: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                      return;
                                    }

                                    dynamic myData = {
                                      // 'room_name':
                                      //     '${streamingController.channelName.value}_actions',
                                      'action': 'call_request',
                                      'uid': authController
                                          .profile
                                          .value
                                          .user!
                                          .uid!,
                                      'full_name': authController
                                          .profile
                                          .value
                                          .full_name,
                                      'profile_image':
                                          authController
                                              .profile
                                              .value
                                              .profile_image ??
                                          authController
                                              .profile
                                              .value
                                              .photo_url,
                                      'call_type': 'video',
                                      'muted': streamingController.muted.value,
                                      'video_disabled': streamingController
                                          .videoDisabled
                                          .value,
                                      'diamonds':
                                          authController.profile.value.diamonds,

                                      'is_moderator': authController
                                          .profile
                                          .value
                                          .is_moderator,
                                      'is_reseller': authController
                                          .profile
                                          .value
                                          .is_reseller,
                                      'level':
                                          authController.profile.value.level,

                                      'followers': authController
                                          .profile
                                          .value
                                          .followers,
                                      'vvip_or_vip_preference': authController
                                          .profile
                                          .value
                                          .vvip_or_vip_preference,
                                      // 'blocks':
                                      //     authController.profile.value.blocks,
                                    };
                                    onUpdateAction(myData);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      // side: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  child: const Text('Join'),
                                ),
                              ],
                            );
                          }
                        }),
                      ],
                    ),
                  );
                }),
              ),
              Expanded(
                child: Obx(() {
                  return streamingController.callTabName.value == 'views'
                      ? ViewerWidget(
                          onUpdateAction: onUpdateAction,
                          streamingController: streamingController,
                        )
                      : streamingController.callTabName.value == 'waiting'
                      ? ListView.builder(
                          itemCount:
                              streamingController.listRequestedCall.length,
                          itemBuilder: ((context, index) {
                            return _callRequestItem(
                              authController: authController,
                              streamingController: streamingController,
                              data:
                                  streamingController.listRequestedCall[index],
                              onUpdateAction: onUpdateAction,
                            );
                          }),
                        )
                      : ListView.builder(
                          itemCount:
                              streamingController.listActiveCall.length > 1
                              ? streamingController.listActiveCall.length - 1
                              : 0,
                          itemBuilder: ((context, index) {
                            return _guestLiveItem(
                              authController: authController,
                              streamingController: streamingController,
                              data:
                                  streamingController.listActiveCall[index + 1],
                              onUpdateAction: onUpdateAction,
                            );
                          }),
                        );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _callRequestItem extends StatelessWidget {
  const _callRequestItem({
    Key? key,
    required this.streamingController,
    this.data,
    required this.onUpdateAction,
    required this.authController,
  }) : super(key: key);

  final LiveStreamingController streamingController;
  final dynamic data;
  final Function onUpdateAction;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showUserInfoBottomSheet(
          context: context,
          data: data,
          onUpdateAction: onUpdateAction,
        );
      },
      horizontalTitleGap: 0,
      leading: _profileImageWithVVIPWidget(data: data),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${data['full_name']}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          streamingController.isBroadcaster.value ||
                  authController.profile.value.is_moderator!
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleButton(
                      icon: Icons.check,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: Colors.green,
                      onPressed: () {
                        if (streamingController.allowVideoCall.value) {
                          // Video Call
                          if (streamingController.listActiveCall.length >= 9) {
                            rShowSnackBar(
                              context: context,
                              title: 'Not allowed more than 8 Guests in call',
                              color: Colors.red,
                              durationInSeconds: 3,
                            );
                            return;
                          }
                        } else {
                          // Audio Call
                          if (streamingController.listActiveCall.length >= 9) {
                            rShowSnackBar(
                              context: context,
                              title: 'Not allowed more than 8 Guests in call',
                              color: Colors.red,
                              durationInSeconds: 3,
                            );
                            return;
                          }
                        }

                        // streamingController.tryToAcceptGroupCaller(
                        //   channelName:
                        //       streamingController.channelName.value,
                        //   callerId: data['uid'],
                        //   isPk: false,
                        //   clType: streamingController.callType.value,
                        // );

                        dynamic callerData = {
                          "action": "accept_general_callers",
                          "uid": data["uid"],
                          "full_name": data["full_name"],
                          "profile_image": data["profile_image"],
                          "diamonds": data["diamonds"],
                          "followers": data["followers"],
                          "is_moderator": data["is_moderator"],
                          "is_reseller": data["is_reseller"],
                          "muted": data["muted"],
                          "video_disabled": data["video_disabled"],
                          "level": data["level"],
                          "vvip_or_vip_preference":
                              data["vvip_or_vip_preference"],
                        };
                        onUpdateAction(callerData);

                        dynamic submissionData = {
                          'action': 'add_user_to_calling_group',
                          'channel_id': int.parse(
                            streamingController.channelName.value,
                          ),
                          'uid': data['uid'],
                        };

                        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                          submissionData: submissionData,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    CircleButton(
                      icon: Icons.close,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: Colors.red,
                      onPressed: () {
                        String action = 'cancel_request';
                        dynamic cancelData = {
                          // 'room_name':
                          //     '${streamingController.channelName.value}_actions',
                          'action': action,
                          'uid': data['uid'],
                          'full_name': data['full_name'],
                          'profile_image': data['profile_image'],
                          // 'call_type': data['call_type'],
                          // 'muted': data['muted'],
                          // 'video_disabled': data['video_disabled'],
                          // 'diamonds': data['diamonds'],
                          // 'gift_coins': data['gift_coins'],
                          // 'is_moderator': data['is_moderator'],
                          // 'is_host': data['is_host'],
                          // 'is_reseller': data['is_reseller'],
                          'level': data['level'],
                          'vvip_or_vip_preference':
                              data['vvip_or_vip_preference'],
                          // 'followers': data['followers'],
                          // 'blocks': data['blocks'],
                        };
                        onUpdateAction(cancelData);
                      },
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class _guestLiveItem extends StatelessWidget {
  const _guestLiveItem({
    Key? key,
    required this.streamingController,
    this.data,
    required this.onUpdateAction,
    required this.authController,
  }) : super(key: key);
  final LiveStreamingController streamingController;
  final dynamic data;
  final Function onUpdateAction;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    String? designation;
    try {
      designation = data['is_moderator']
          ? 'Official Moderator'
          : data['is_reseller']
          ? 'Official Reseller'
          : 'General User';
    } catch (e) {
      //
    }
    return ListTile(
      onTap: () {
        showUserInfoBottomSheet(
          context: context,
          data: data,
          onUpdateAction: onUpdateAction,
        );
      },
      horizontalTitleGap: 0,
      leading: _profileImageWithVVIPWidget(data: data),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${data['full_name']}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          designation != null
              ? Text(
                  '($designation)',
                  overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    backgroundColor: Colors.black12,
                    fontSize: 10,
                  ),
                )
              : Container(),
          streamingController.isBroadcaster.value
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleButton(
                      icon: data['muted'] ? Icons.mic_off : Icons.mic,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: data['muted']
                          ? Colors.grey
                          : Colors.blueAccent,
                      onPressed: () {
                        String action = 'controller';
                        // if (_pk) {
                        //   action = 'controller_pk';
                        // }
                        dynamic activeData = {
                          // 'room_name':
                          //     '${streamingController.channelName.value}_actions',
                          'action': action,
                          'uid': data['uid'],
                          // 'full_name': data['full_name'],
                          'profile_image': data['profile_image'],
                          'muted': !data['muted'],
                          'video_disabled': data['video_disabled'],
                          // 'diamonds': data['diamonds'],
                          // 'gift_coins': data['gift_coins'],
                          // 'is_moderator': data['is_moderator'],
                          // 'is_host': data['is_host'],
                          // 'is_reseller': data['is_reseller'],
                          // 'level': data['level'],
                          'vvip_or_vip_preference':
                              data['vvip_or_vip_preference'],
                          // 'package_theme_gif': data['package_theme_gif'],
                          // 'followers': data['followers'],
                          // 'blocks': data['blocks'],
                        };
                        onUpdateAction(activeData);
                      },
                    ),
                    const SizedBox(width: 16),
                    data['call_type'] == 'video'
                        ? CircleButton(
                            icon: data['video_disabled']
                                ? Icons.videocam_off
                                : Icons.videocam,
                            iconSize: 16,
                            minWidth: 24,
                            minHeight: 24,
                            iconColor: data['video_disabled']
                                ? Colors.grey
                                : Colors.blueAccent,
                            onPressed: () {
                              String action = 'controller';
                              // if (_pk) {
                              //   action = 'controller_pk';
                              // }
                              dynamic activeData = {
                                // 'room_name':
                                //     '${streamingController.channelName.value}_actions',
                                'action': action,
                                'uid': data['uid'],
                                // 'full_name': data['full_name'],
                                'profile_image': data['profile_image'],
                                'call_type': data['call_type'],
                                'muted': data['muted'],
                                'video_disabled': !data['video_disabled'],
                                // 'diamonds': data['diamonds'],
                                // 'gift_coins': data['gift_coins'],
                                // 'is_moderator': data['is_moderator'],
                                // 'is_host': data['is_host'],
                                // 'is_reseller': data['is_reseller'],
                                // 'level': data['level'],
                                'vvip_or_vip_preference':
                                    data['vvip_or_vip_preference'],
                                // 'package_theme_gif': data['package_theme_gif'],
                                // 'followers': data['followers'],
                                // 'blocks': data['blocks'],
                              };
                              onUpdateAction(activeData);
                            },
                          )
                        : Container(),
                    data['call_type'] == 'video'
                        ? const SizedBox(width: 16)
                        : Container(),
                    CircleButton(
                      icon: Icons.close,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: Colors.red,
                      onPressed: () {
                        // streamingController.tryToEndCallInLiveKitRoom(
                        //   channelName:
                        //       streamingController.channelName.value,
                        //   uid: data['uid'],
                        // );
                        dynamic actionData = {
                          "action": "end_call",
                          "uid": data['uid'],
                        };
                        onUpdateAction(actionData);

                        dynamic submissionData = {
                          'action': 'remove_user_from_calling_group',
                          'channel_id': int.parse(
                            streamingController.channelName.value,
                          ),
                          'uid': data['uid'],
                        };

                        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                          submissionData: submissionData,
                        );
                      },
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class ViewerWidget extends StatelessWidget {
  const ViewerWidget({
    Key? key,
    required this.onUpdateAction,
    required this.streamingController,
  }) : super(key: key);

  final LiveStreamingController streamingController;
  final Function onUpdateAction;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (
      // (streamingController.liveStreamData.value['viewers_count'] ?? 0) >
      streamingController.viewersCount.value >
          streamingController.viewers.length) {
        streamingController.loadLivekitParticipantList(
          channelName: streamingController.channelName.value,
          onUpdateAction: onUpdateAction,
        );
      }
    });
    return Obx(() {
      if (streamingController.loadingParticipantList.value) {
        return const Center(
          child: SpinKitHourGlass(color: Colors.red, size: 50.0),
        );
      }
      return ListView.separated(
        itemCount: streamingController.viewers.length,
        itemBuilder: ((context, index) {
          return _viewerItem(
            data: streamingController.viewers[index],
            onUpdateAction: onUpdateAction,
            index: index,
          );
        }),
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 8);
        },
      );
    });
  }
}

class _viewerItem extends StatelessWidget {
  const _viewerItem({
    Key? key,
    this.data,
    this.onUpdateAction,
    required this.index,
  }) : super(key: key);
  final dynamic data;
  final Function? onUpdateAction;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showUserInfoBottomSheet(
        context: context,
        data: data,
        onUpdateAction: onUpdateAction!,
      ),
      horizontalTitleGap: 0,
      leading: _profileImageWithVVIPWidget(data: data),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${data['full_name']}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

Widget _profileImageWithVVIPWidget({required data}) {
  return SizedBox(
    width: 64,
    height: 64,
    child: Stack(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(width: 2.0, color: Colors.orange.shade600),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: data['profile_image'] == null
                  ? Image.asset(
                      'assets/others/person.jpg',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: '${data['profile_image']}',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    ),
            ),
          ),
        ),
        data['vvip_or_vip_preference'] != null &&
                data['vvip_or_vip_preference']['vvip_or_vip_gif'] != null
            ? Positioned(
                bottom: 0,
                right: 0,
                child: Container(
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
                          data['vvip_or_vip_preference']['vvip_or_vip_gif'],
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    ),
  );
}
