import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/widgets/contributors_widget.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/widgets/gifts_widget.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showUserInteractBottomSheet({
  required BuildContext context,
  required dynamic data,
  required Function onUpdateAction,
}) {
  final AuthController authController = Get.find();
  final LiveStreamingController streamingController = Get.find();

  // Future.delayed(Duration.zero, () {
  //   profileController.profileForHost.value = {};
  // });

  // final Function onUpdateAction;
  showModalBottomSheet(
    context: context,
    barrierColor: Colors.transparent,
    enableDrag: false,
    // isScrollControlled: true,
    builder: (context) {
      // if (authController.showingOverlay.value) {
      //   Navigator.of(context).pop();
      // }

      return SafeArea(
        child: Obx(() {
          return SizedBox(
            // height: 350,
            height:
                streamingController.listActiveCall.length == 1 &&
                    streamingController.channelName.value ==
                        authController.profile.value.user!.uid!.toString()
                ? 350
                : 390,

            // decoration: BoxDecoration(
            //   gradient: Palette.linearGradient1,
            // ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 58,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          if (streamingController.userInteractTab.value ==
                              'gifts') {
                            return GiftsWidget(
                              data: data,
                              streamingController: streamingController,
                              authController: authController,
                              onUpdateAction: onUpdateAction,
                            );
                          } else if (streamingController
                                  .userInteractTab
                                  .value ==
                              'contributors') {
                            return ContributorsWidget(
                              streamingController: streamingController,
                              data: data,
                              onUpdateAction: onUpdateAction,
                            );
                          }
                          return Container();
                        }),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (streamingController.userInteractTab.value !=
                                'gifts') {
                              streamingController.setUserInteractTab(
                                tab: 'gifts',
                              );
                            }
                          },
                          child: Obx(() {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/others/gift.png',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  // onTap: () => _streamingController.setShowViewersTab(
                                  //     showViewers: false),
                                  child: Text(
                                    'SEND GIFTS',
                                    style: TextStyle(
                                      color:
                                          streamingController
                                                  .userInteractTab
                                                  .value !=
                                              'gifts'
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (streamingController.userInteractTab.value !=
                                'contributors') {
                              streamingController.setUserInteractTab(
                                tab: 'contributors',
                              );
                            }
                          },
                          child: Obx(() {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // const Icon(
                                //   Icons.person_pin,
                                //   color: Colors.blue,
                                // ),
                                data['vvip_or_vip_preference'] != null &&
                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                            null &&
                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                            ''
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        foregroundDecoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              data['vvip_or_vip_preference']['vvip_or_vip_gif'],
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          child:
                                              data['profile_image'] == null &&
                                                  data['photo_url'] == null
                                              ? Image.asset(
                                                  'assets/others/person.jpg',
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      data['profile_image'] ??
                                                      data['photo_url'],
                                                  width: 20,
                                                  height: 20,
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
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        child:
                                            data['profile_image'] == null &&
                                                data['photo_url'] == null
                                            ? Image.asset(
                                                'assets/others/person.jpg',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    data['profile_image'] ??
                                                    data['photo_url'],
                                                width: 24,
                                                height: 24,
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
                                InkWell(
                                  // onTap: () => _streamingController.setShowViewersTab(
                                  //     showViewers: false),
                                  child: Text(
                                    '${data['full_name']}',
                                    style: TextStyle(
                                      color:
                                          streamingController
                                                  .userInteractTab
                                                  .value !=
                                              'contributors'
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    },
  );
}
