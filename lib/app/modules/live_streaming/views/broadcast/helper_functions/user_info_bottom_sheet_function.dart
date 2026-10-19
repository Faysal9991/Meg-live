import 'package:doyel_live/app/theme/app_colors.dart';
import 'room_admin_button.dart';
import 'transfer_host_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/messenger/utils/utils.dart';
import 'package:doyel_live/app/modules/messenger/views/messages/message_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  // Agency the user hosts for; hidden when they aren't linked to one.
  Widget _agencyBadge(dynamic agency) {
    if (agency is! Map) return const SizedBox.shrink();
    final name = '${agency['agent_name'] ?? ''}'.trim();
    if (name.isEmpty) return const SizedBox.shrink();
    final logo = '${agency['logo'] ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.surfaceHigh,
            backgroundImage: logo.isNotEmpty
                ? CachedNetworkImageProvider(logo)
                : null,
            child: logo.isEmpty
                ? const Icon(LucideIcons.building2, size: 14)
                : null,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Agency: $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

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
    barrierColor: AppColors.transparent,
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
                    child: SpinKitHourGlass(
                      color: AppColors.textSecondary,
                      size: 50.0,
                    ),
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
                  : (profileData['agency'] is Map ? 192 : 160),
              // decoration: BoxDecoration(
              //   gradient: Palette.linearGradient2,
              // ),
              color: AppColors.transparent,
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
                        // color: AppColors.textSecondary,
                        // gradient: LinearGradient(
                        //   colors: [
                        //     AppColors.overlay,
                        //     AppColors.overlayMedium,
                        //     AppColors.overlayLight,
                        //   ],
                        //   begin: Alignment.bottomLeft,
                        //   end: Alignment.topRight,
                        // ),
                        color: AppColors.surface,
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
                          RoomAdminButton(
                            uid: int.parse(data['uid'].toString()),
                          ),
                          TransferHostButton(
                            uid: int.parse(data['uid'].toString()),
                            fullName: data['full_name']?.toString(),
                          ),
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
                                          color: AppColors.textPrimary,
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
                          _agencyBadge(profileData['agency']),
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
                                                    ? LucideIcons.plus
                                                    : LucideIcons.minus,
                                                // color: !profileController
                                                //         .accountFollowers
                                                //         .contains(authController
                                                //             .profile
                                                //             .value
                                                //             .user!
                                                //             .uid!)
                                                //     ? AppColors.info
                                                //     : AppColors.error,
                                                color: AppColors.textPrimary,
                                                size: 12,
                                              )
                                            : Icon(
                                                LucideIcons.refreshCw,
                                                color: AppColors.textPrimary,
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
                                    streamingController.isCurrentHost
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
                                                          ? LucideIcons.ban
                                                          : LucideIcons.flag,
                                                      color:
                                                          AppColors.textPrimary,
                                                      size: 12,
                                                    )
                                                  : Icon(
                                                      LucideIcons.refreshCw,
                                                      color:
                                                          AppColors.textPrimary,
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
                                    //       color: AppColors.surface,
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
                                    color: AppColors.textSecondary,
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
                                color: AppColors.overlay,
                                // borderRadius: BorderRadius.only(
                                //   bottomLeft: Radius.circular(20.0),
                                //   bottomRight: Radius.circular(20.0),
                                // ),
                                border: Border.all(
                                  color: AppColors.gold,
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
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  '${data['level'] != null ? data['level']['level'] : 0}',
                                  style: const TextStyle(
                                    color: AppColors.onLight,
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
