import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/liveroom_isolation_actions.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/user_interact_bottom_sheet_funtion.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/no_video.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RoomDisplayLayout {
  static Widget displayScreenView({
    required ParticipantTrack? view,
    required dynamic data,
    String? serial,
    required double roomWidth,
    double? roomHeight,
    required String channelName,
    required int myUid,
    required bool isBroadcaster,
    required Function onUpdateAction,
    required LiveStreamingController livekitStreamingController,

    required AuthController authController,
    required BuildContext context,
  }) {
    final VVIPorVipPackageController packageController =
        Get.isRegistered<VVIPorVipPackageController>()
        ? Get.find<VVIPorVipPackageController>()
        : Get.put(VVIPorVipPackageController());
    data['width'] = roomWidth;
    return Container(
      color: AppColors.transparent,
      width: roomWidth,
      height: roomHeight ?? roomWidth,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (livekitStreamingController.listActiveCall.length > 1) {
                  if (data['uid'] != myUid) {
                    livekitStreamingController.setSelectedGift(
                      giftType: '',
                      id: 0,
                    );
                    livekitStreamingController.setUserInteractTab(tab: 'gifts');
                    showUserInteractBottomSheet(
                      context: context,
                      data: data,
                      onUpdateAction: onUpdateAction,
                    );
                  } else {
                    showUserInfoBottomSheet(
                      context: context,
                      data: data,
                      onUpdateAction: onUpdateAction,
                    );
                  }
                }
              },
              child: Container(
                width: roomWidth,
                height: roomHeight ?? roomWidth,
                decoration: BoxDecoration(
                  // color:  AppColors.textPrimary,
                  // gradient: livekitStreamingController.listActiveCall.length >
                  //                 1
                  //         ? Palette.linearGradient2
                  //         : Palette.linearGradient1,
                  border:
                      view != null &&
                          view.participant.isSpeaking &&
                          !view.isScreenShare &&
                          // !data['muted']
                          view.participant.isMicrophoneEnabled()
                      ? Border.all(
                          color: data['call_type'] == 'audio'
                              ? AppColors.cyan
                              : AppColors.pinkLight,
                          width: 3,
                          // strokeAlign: StrokeAlign.center,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        )
                      : Border.all(color: AppColors.onMediaSubtle),
                ),

                child:
                    view == null ||
                        data['call_type'] == 'audio' ||
                        data['video_disabled'] == true
                    ? NoVideoWidget(data: data)
                    : ParticipantWidget.widgetFor(
                        participantTrack: view,
                        data: data,
                      ),
              ),
            ),
          ),
          // (!livekitStreamingController.pkState.value && data['uid'].toString() != channelName) ||
          //         (livekitStreamingController.pkState.value && livekitStreamingController.listActivePK.length > 1)

          // Bottom
          livekitStreamingController.listActiveCall.length > 1
              ? Positioned(
                  bottom: 4,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayChip,
                          borderRadius: BorderRadius.circular(20.0),
                          border: VIDEO_AS_CONTAINER
                              ? Border.all(color: AppColors.onMediaSubtle)
                              : null,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showUserInfoBottomSheet(
                              context: context,
                              data: data,
                              onUpdateAction: onUpdateAction,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100.0,
                                        ),
                                        border: Border.all(
                                          width: 2.0,
                                          color: AppColors.onMediaMuted,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          100.0,
                                        ),
                                        child: data['profile_image'] == null
                                            ? Image.asset(
                                                'assets/others/person.jpg',
                                                width:
                                                    data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                height:
                                                    data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    '${data['profile_image']}',
                                                width:
                                                    data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                height:
                                                    data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: AppColors
                                                                .onMedia,
                                                          ),
                                                    ),
                                              ),
                                      ),
                                    ),
                                    data['vvip_or_vip_preference'] != null &&
                                            data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                                null
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
                                                  color: AppColors.gold,
                                                  // width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      100.0,
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      100.0,
                                                    ),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      data['vvip_or_vip_preference']['vvip_or_vip_gif'],
                                                  width: 14,
                                                  height: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          data['uid'] !=
                                              authController
                                                  .profile
                                                  .value
                                                  .user!
                                                  .uid!
                                          ? roomWidth - 72
                                          : roomWidth - 62,
                                    ),
                                    // width: data['uid'] !=
                                    //         myUid
                                    //     ? width - 86
                                    //     : width - 56,
                                    child: Text(
                                      '${data['full_name']}',
                                      // style: TextStyle(
                                      //   color: AppColors.surface,
                                      //   fontSize: 14,
                                      // ),
                                      // "${data['full_name'].length > ((!livekitStreamingController.pkState.value && (livekitStreamingController.listActiveCall.length > 4 || livekitStreamingController.allowVideoCall.value)) ? 8 : 12) ? data['full_name'].substring(0, ((!livekitStreamingController.pkState.value && (livekitStreamingController.listActiveCall.length > 4 || livekitStreamingController.allowVideoCall.value)) ? 8 : 12)) + '...' : data['full_name']}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.onMedia,
                                        fontSize:
                                            (!livekitStreamingController
                                                    .pkState
                                                    .value &&
                                                (livekitStreamingController
                                                            .listActiveCall
                                                            .length >
                                                        4 ||
                                                    livekitStreamingController
                                                        .allowVideoCall
                                                        .value))
                                            ? 8
                                            : 12,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/others/diamond.png',
                                        width: 14,
                                        height: 14,
                                      ),
                                      // const SizedBox(
                                      //   width: 4,
                                      // ),
                                      Text(
                                        '${data['diamonds'] ?? 0}',
                                        // '${(data['diamonds'] ?? 0) / 1000}K',
                                        style: TextStyle(
                                          color: AppColors.onMedia,
                                          fontSize:
                                              (!livekitStreamingController
                                                      .pkState
                                                      .value &&
                                                  (livekitStreamingController
                                                              .listActiveCall
                                                              .length >
                                                          4 ||
                                                      livekitStreamingController
                                                          .allowVideoCall
                                                          .value))
                                              ? 8
                                              : 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),

          // End Call for User
          Obx(() {
            final isModerator =
                authController.profile.value.is_moderator ?? false;
            final hasKingPackage = packageController.hasActiveKingPackage;
            final hasLiveRoomControlAccess =
                isBroadcaster || isModerator || hasKingPackage;

            if (data['uid'] == myUid || !hasLiveRoomControlAccess) {
              return Container();
            }

            return Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () {
                  String action = 'end_call';
                  if (livekitStreamingController.pkState.value) {
                    action = 'end_pk_call';
                    dynamic activeData = {
                      'room_name': '${channelName}_actions',
                      'action': action,
                      'uid': data['uid'],
                      'full_name': data['full_name'],
                      'profile_image': data['profile_image'],
                      'diamonds': data['diamonds'],
                      'level': data['level'],
                      'followers': data['followers'],
                      // 'blocks': data['blocks'],
                      'muted': data['muted'],
                      'video_disabled': data['video_disabled'],
                    };
                    onUpdateAction(activeData);
                  } else {
                    dynamic actionData = {
                      "action": "end_call",
                      "uid": data['uid'],
                    };
                    onUpdateAction(actionData);

                    LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                      submissionData:
                          LiveRoomUpdateRequest.removeUserFromCallingGroup(
                            channelId: int.parse(channelName),
                            uid: int.parse(data['uid'].toString()),
                          ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    // color: AppColors.error.withOpacity(.6),
                    color: AppColors.overlayChip,
                    borderRadius: BorderRadius.circular(100),
                    border: VIDEO_AS_CONTAINER
                        ? Border.all(color: AppColors.onMediaSubtle)
                        : null,
                  ),
                  child: Icon(
                    LucideIcons.x,
                    // color: AppColors.surface,
                    color: AppColors.error,
                    size: livekitStreamingController.pkState.value
                        ? 16.0
                        : 12.0,
                  ),
                ),
              ),
            );
          }),

          serial != null
              ? Positioned(
                  top: 6,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.overlayChip,
                      borderRadius: BorderRadius.circular(20),
                      border: VIDEO_AS_CONTAINER
                          ? Border.all(color: AppColors.onMediaSubtle)
                          : null,
                    ),
                    child: Text(
                      serial,
                      style: const TextStyle(
                        color: AppColors.onMedia,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  static Widget displayInitialRendererScreen({
    required ParticipantTrack view,
    required double roomWidth,
    double? roomHeight,
  }) {
    return Container(
      decoration: BoxDecoration(
        border:
            view.participant.isSpeaking &&
                !view.isScreenShare &&
                view.participant.isMicrophoneEnabled()
            ? Border.all(
                color: AppColors.pinkLight,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              )
            : Border.all(color: AppColors.onMediaSubtle),
      ),
      width: roomWidth,
      height: roomHeight ?? roomWidth,
      child: ParticipantWidget.widgetFor(participantTrack: view, data: null),
    );
  }
}
