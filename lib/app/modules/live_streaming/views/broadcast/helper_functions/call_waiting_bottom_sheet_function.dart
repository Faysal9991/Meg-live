import 'package:doyel_live/app/theme/app_colors.dart';
import 'join_call_mode_bottom_sheet.dart';
import 'room_admin_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/liveroom_isolation_actions.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/widgets/circle_button.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

bool _hasLiveRoomControlAccess({
  required LiveStreamingController streamingController,
  required AuthController authController,
  required VVIPorVipPackageController packageController,
}) {
  final isBroadcaster = streamingController.isBroadcaster.value;
  final isModerator = authController.profile.value.is_moderator ?? false;
  final hasKingPackage = packageController.hasActiveKingPackage;
  return isBroadcaster || isModerator || hasKingPackage;
}

bool _canManageRequests(LiveStreamingController streamingController) =>
    streamingController.isRoomAdmin ||
    _hasLiveRoomControlAccess(
      streamingController: streamingController,
      authController: Get.find<AuthController>(),
      packageController: Get.find<VVIPorVipPackageController>(),
    );

Widget _buildSelfCallActionButton({
  required BuildContext context,
  required LiveStreamingController streamingController,
  required AuthController authController,
  required Function onUpdateAction,
}) {
  if (streamingController.listRequestedCall.indexWhere(
        (element) => element['uid'] == authController.profile.value.user!.uid!,
      ) >
      -1) {
    return ElevatedButton(
      onPressed: () {
        dynamic data = {
          'action': 'cancel_request',
          'uid': authController.profile.value.user!.uid!,
          'full_name': authController.profile.value.full_name,
          'profile_image':
              authController.profile.value.profile_image ??
              authController.profile.value.photo_url,
          'level': authController.profile.value.level,
          'vvip_or_vip_preference':
              authController.profile.value.vvip_or_vip_preference,
        };
        onUpdateAction(data);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('Cancel', style: TextStyle(color: AppColors.surface)),
    );
  }

  if (streamingController.listActiveCall.indexWhere(
        (element) => element['uid'] == authController.profile.value.user!.uid!,
      ) >
      -1) {
    return ElevatedButton(
      onPressed: () {
        dynamic actionData = {
          "action": "end_call",
          "uid": authController.profile.value.user!.uid!,
        };
        onUpdateAction(actionData);
        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
          submissionData: LiveRoomUpdateRequest.removeUserFromCallingGroup(
            channelId: int.parse(streamingController.channelName.value),
            uid: authController.profile.value.user!.uid!,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('End Call'),
    );
  }

  return ElevatedButton(
    onPressed: () async {
      if (streamingController.listActiveCall.isEmpty) {
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

      final mode = await showJoinCallModeBottomSheet(context);
      if (mode == null || !context.mounted) return;
      final microphoneGranted = await Permission.microphone.request().isGranted;
      final cameraGranted =
          mode == JoinCallMode.audio ||
          await Permission.camera.request().isGranted;
      if (!context.mounted) return;
      if (!microphoneGranted || !cameraGranted) {
        rShowSnackBar(
          context: context,
          title: 'Please allow access to join the call.',
          color: AppColors.warning,
          durationInSeconds: 3,
        );
        return;
      }
      // The host may have ended a call while the mode sheet was open.
      if (streamingController.listActiveCall.isEmpty ||
          streamingController.listRequestedCall.any(
            (e) => e['uid'] == authController.profile.value.user!.uid!,
          ) ||
          streamingController.listActiveCall.any(
            (e) => e['uid'] == authController.profile.value.user!.uid!,
          )) {
        return;
      }
      final cameraOff = mode == JoinCallMode.audio;
      dynamic myData = {
        'action': 'call_request',
        'uid': authController.profile.value.user!.uid!,
        'full_name': authController.profile.value.full_name,
        'profile_image':
            authController.profile.value.profile_image ??
            authController.profile.value.photo_url,
        'call_type': 'video',
        'muted': false,
        'video_disabled': cameraOff,
        'diamonds': authController.profile.value.diamonds,
        'is_moderator': authController.profile.value.is_moderator,
        'is_reseller': authController.profile.value.is_reseller,
        'level': authController.profile.value.level,
        'followers': authController.profile.value.followers,
        'vvip_or_vip_preference':
            authController.profile.value.vvip_or_vip_preference,
      };
      if (onUpdateAction(myData) == false) {
        rShowSnackBar(
          context: context,
          title: 'Call connection is not ready. Please try again.',
          color: AppColors.warning,
          durationInSeconds: 3,
        );
        return;
      }
      streamingController.muted.value = false;
      streamingController.videoDisabled.value = cameraOff;
    },
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ),
    child: const Text('Join'),
  );
}

void showCallWaitingBottomSheet({
  required BuildContext context,
  required dynamic data,
  required LiveStreamingController streamingController,
  required AuthController authController,
  required Function onUpdateAction,
}) {
  final VVIPorVipPackageController packageController =
      Get.isRegistered<VVIPorVipPackageController>()
      ? Get.find<VVIPorVipPackageController>()
      : Get.put(VVIPorVipPackageController());
  packageController.ensureKingPackageCatalogLoaded();

  showModalBottomSheet(
    context: context,
    barrierColor: AppColors.transparent,
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
                  final hasLiveRoomControlAccess = _hasLiveRoomControlAccess(
                    streamingController: streamingController,
                    authController: authController,
                    packageController: packageController,
                  );

                  return Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.textSecondary),
                      ),
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
                                    : AppColors.textSecondary,
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
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (hasLiveRoomControlAccess ||
                            streamingController.isRoomAdmin)
                          InkWell(
                            onTap: () =>
                                streamingController.setCallTab(tabName: 'live'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'LIVE',
                                style: TextStyle(
                                  color:
                                      streamingController.callTabName.value ==
                                          'live'
                                      ? Theme.of(context).primaryColor
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (!streamingController.isBroadcaster.value)
                          _buildSelfCallActionButton(
                            context: context,
                            streamingController: streamingController,
                            authController: authController,
                            onUpdateAction: onUpdateAction,
                          ),
                      ],
                    ),
                  );
                }),
              ),
              Expanded(
                child: Obx(() {
                  final hasLiveRoomControlAccess = _hasLiveRoomControlAccess(
                    streamingController: streamingController,
                    authController: authController,
                    packageController: packageController,
                  );

                  final canManageRequests =
                      hasLiveRoomControlAccess ||
                      streamingController.isRoomAdmin;

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
                              hasLiveRoomControlAccess: canManageRequests,
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
                              hasLiveRoomControlAccess:
                                  hasLiveRoomControlAccess,
                              canDropFromCall: canManageRequests,
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
    required this.hasLiveRoomControlAccess,
    this.data,
    required this.onUpdateAction,
  }) : super(key: key);

  final LiveStreamingController streamingController;
  final bool hasLiveRoomControlAccess;
  final dynamic data;
  final Function onUpdateAction;

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
          hasLiveRoomControlAccess
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleButton(
                      icon: LucideIcons.check,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: AppColors.success,
                      onPressed: () {
                        if (!_canManageRequests(streamingController)) return;
                        if (!streamingController.listRequestedCall.any(
                          (e) => e['uid'] == data['uid'],
                        )) {
                          return;
                        }
                        if (streamingController.allowVideoCall.value) {
                          // Video Call
                          if (streamingController.listActiveCall.length >= 9) {
                            rShowSnackBar(
                              context: context,
                              title: 'Not allowed more than 8 Guests in call',
                              color: AppColors.error,
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
                              color: AppColors.error,
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
                          "call_type": "video",
                          "muted": data["muted"] ?? false,
                          "video_disabled":
                              data["video_disabled"] ??
                              data["call_type"] == "audio",
                          "level": data["level"],
                          "vvip_or_vip_preference":
                              data["vvip_or_vip_preference"],
                        };
                        if (onUpdateAction(callerData) == false) return;

                        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                          submissionData:
                              LiveRoomUpdateRequest.addUserToCallingGroup(
                                channelId: int.parse(
                                  streamingController.channelName.value,
                                ),
                                uid: int.parse(data['uid'].toString()),
                              ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    CircleButton(
                      icon: LucideIcons.x,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: AppColors.error,
                      onPressed: () {
                        if (!_canManageRequests(streamingController)) return;
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
    required this.hasLiveRoomControlAccess,
    required this.canDropFromCall,
    this.data,
    required this.onUpdateAction,
  }) : super(key: key);
  final LiveStreamingController streamingController;
  final bool hasLiveRoomControlAccess;
  final bool canDropFromCall;
  final dynamic data;
  final Function onUpdateAction;

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
                    backgroundColor: AppColors.overlayLight,
                    fontSize: 10,
                  ),
                )
              : Container(),
          hasLiveRoomControlAccess || canDropFromCall
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Room admins may only drop guests, not mute them.
                    if (hasLiveRoomControlAccess) ...[
                      CircleButton(
                        icon: data['muted']
                            ? LucideIcons.micOff
                            : LucideIcons.mic,
                        iconSize: 24,
                        minWidth: 32,
                        minHeight: 32,
                        iconColor: data['muted']
                            ? AppColors.textSecondary
                            : AppColors.info,
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
                    ],
                    // Cameras belong to each guest; the host cannot toggle them.
                    CircleButton(
                      icon: LucideIcons.x,
                      iconSize: 24,
                      minWidth: 32,
                      minHeight: 32,
                      iconColor: AppColors.error,
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

                        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                          submissionData:
                              LiveRoomUpdateRequest.removeUserFromCallingGroup(
                                channelId: int.parse(
                                  streamingController.channelName.value,
                                ),
                                uid: int.parse(data['uid'].toString()),
                              ),
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
          child: SpinKitHourGlass(color: AppColors.error, size: 50.0),
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
      trailing: RoomAdminButton(
        uid: int.parse(data['uid'].toString()),
        compact: true,
      ),
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
              border: Border.all(width: 2.0, color: AppColors.warning),
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
                        child: CircularProgressIndicator(
                          color: AppColors.error,
                        ),
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
                    color: AppColors.overlay,
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(20.0),
                    //   bottomRight: Radius.circular(20.0),
                    // ),
                    border: Border.all(
                      color: AppColors.warning,
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
