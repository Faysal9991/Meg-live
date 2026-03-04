import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/liveroom_isolation_actions.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/user_interact_bottom_sheet_funtion.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter/material.dart';

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
    data['width'] = roomWidth;
    return Container(
      color: Colors.transparent,
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
                  // color:  Colors.black,
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
                          color: Colors.red.shade600,
                          width: 3,
                          // strokeAlign: StrokeAlign.center,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        )
                      : Border.all(color: Colors.white30),
                ),

                // TODO: Kyaw
                child:
                    data['call_type'] == 'audio' ||
                        view == null ||
                        // data['video_disabled'] == true
                        !view.participant.isCameraEnabled()
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          serial == null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                    horizontal: 8.0,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                    // color: Colors.black45,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.black12,
                                        Colors.black38,
                                        Colors.black54,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    '${data['full_name']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : Container(),
                          view == null
                              ? Center(
                                  child: Image.asset(
                                    'assets/logos/doyel_live.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    // : view,
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
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20.0),
                          border: VIDEO_AS_CONTAINER
                              ? Border.all(color: Colors.white24)
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
                                          color: Colors.orange.shade600,
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
                                                            color: Colors.red,
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
                                                color: Colors.black38,
                                                // borderRadius: BorderRadius.only(
                                                //   bottomLeft: Radius.circular(20.0),
                                                //   bottomRight: Radius.circular(20.0),
                                                // ),
                                                border: Border.all(
                                                  color: Colors.orange.shade600,
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
                                      //   color: Colors.white,
                                      //   fontSize: 14,
                                      // ),
                                      // "${data['full_name'].length > ((!livekitStreamingController.pkState.value && (livekitStreamingController.listActiveCall.length > 4 || livekitStreamingController.allowVideoCall.value)) ? 8 : 12) ? data['full_name'].substring(0, ((!livekitStreamingController.pkState.value && (livekitStreamingController.listActiveCall.length > 4 || livekitStreamingController.allowVideoCall.value)) ? 8 : 12)) + '...' : data['full_name']}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
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
                                          color: Colors.white,
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
          data['uid'] != myUid &&
                  (isBroadcaster || authController.profile.value.is_moderator!)
              ? Positioned(
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

                        dynamic submissionData = {
                          'action': 'remove_user_from_calling_group',
                          'channel_id': int.parse(channelName),
                          'uid': data['uid'],
                        };
                        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                          submissionData: submissionData,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        // color: Colors.redAccent.withOpacity(.6),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: VIDEO_AS_CONTAINER
                            ? Border.all(color: Colors.white24)
                            : null,
                      ),
                      child: Icon(
                        Icons.close,
                        // color: Colors.white,
                        color: Colors.red,
                        size: livekitStreamingController.pkState.value
                            ? 16.0
                            : 12.0,
                      ),
                    ),
                  ),
                )
              : Container(),

          serial != null
              ? Positioned(
                  top: 6,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                      border: VIDEO_AS_CONTAINER
                          ? Border.all(color: Colors.white24)
                          : null,
                    ),
                    child: Text(
                      serial,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                color: Colors.red.shade600,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              )
            : Border.all(color: Colors.white30),
      ),
      width: roomWidth,
      height: roomHeight ?? roomWidth,
      child: ParticipantWidget.widgetFor(participantTrack: view, data: null),
    );
  }
}
