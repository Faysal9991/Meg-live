import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftsWidget extends StatelessWidget {
  const GiftsWidget({
    super.key,
    required this.streamingController,
    required this.authController,
    required this.data,
    required this.onUpdateAction,
  });
  final LiveStreamingController streamingController;
  final AuthController authController;
  final dynamic data;
  final Function onUpdateAction;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (streamingController.listAnimatedGift.isEmpty ||
          streamingController.listNormalGift.isEmpty) {
        streamingController.fetchGiftList();
      }
    });
    return Obx(() {
      if (streamingController.loadingGfitList.value) {
        return const Center(
          child: SpinKitChasingDots(
            color: Colors.red,
            size: 50.0,
          ),
        );
      }
      return SizedBox(
        // height: 260,
        height: streamingController.listActiveCall.length == 1 &&
                streamingController.channelName.value ==
                    authController.profile.value.user!.uid!.toString()
            ? 260
            : 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 2,
            ),
            SizedBox(
              height: 42,
              child: Obx(
                () {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: streamingController.listActiveCall.length,
                    separatorBuilder: (context, index) => SizedBox(
                      width: streamingController.listActiveCall[index]['uid'] ==
                              authController.profile.value.user!.uid!
                          ? 0
                          : 4,
                    ),
                    itemBuilder: ((context, index) {
                      dynamic data = streamingController.listActiveCall[index];
                      if (data['uid'] ==
                          authController.profile.value.user!.uid!) {
                        return Container();
                      }
                      return InkWell(
                        onTap: () {
                          if (data['selected'] != null) {
                            data['selected'] = !data['selected'];
                          } else {
                            data['selected'] = true;
                          }
                          streamingController.listActiveCall.removeAt(index);
                          streamingController.listActiveCall
                              .insert(index, data);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width:
                                  data['selected'] == null || !data['selected']
                                      ? 1
                                      : 2,
                              color:
                                  data['selected'] == null || !data['selected']
                                      ? Colors.grey
                                      : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        border: Border.all(
                                          width: 2.0,
                                          color: Colors.orange.shade600,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: data['profile_image'] == null
                                            ? Image.asset(
                                                'assets/others/person.jpg',
                                                width: data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']
                                                                [
                                                                'vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                height: data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']
                                                                [
                                                                'vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    '${data['profile_image']}',
                                                width: data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']
                                                                [
                                                                'vvip_or_vip_gif'] !=
                                                            null
                                                    ? 22
                                                    : 28,
                                                height: data['vvip_or_vip_preference'] !=
                                                            null &&
                                                        data['vvip_or_vip_preference']
                                                                [
                                                                'vvip_or_vip_gif'] !=
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
                                            data['vvip_or_vip_preference']
                                                    ['vvip_or_vip_gif'] !=
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
                                                    color:
                                                        Colors.orange.shade600,
                                                    // width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: data[
                                                          'vvip_or_vip_preference']
                                                      ['vvip_or_vip_gif'],
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
                              Text(
                                '#${data['uid']}',
                                style: const TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(
              height: 74,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: streamingController.listAnimatedGift.length,
                itemBuilder: ((context, index) {
                  dynamic giftData =
                      streamingController.listAnimatedGift[index];
                  return giftItem(
                    streamingController: streamingController,
                    authController: authController,
                    giftData: giftData,
                  );
                }),
              ),
            ),
            SizedBox(
              height: 74,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: streamingController.listNormalGift.length,
                itemBuilder: ((context, index) {
                  dynamic giftData = streamingController.listNormalGift[index];
                  return giftItem(
                    streamingController: streamingController,
                    authController: authController,
                    giftData: giftData,
                  );
                }),
              ),
            ),
            data['uid'] == authController.profile.value.user!.uid! &&
                    streamingController.listActiveCall.firstWhereOrNull((el) =>
                            el['selected'] != null &&
                            el['selected'] == true &&
                            el['uid'] !=
                                authController.profile.value.user!.uid!) ==
                        null
                ? const SizedBox(
                    height: 50,
                  )
                : SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                        ),
                        // const Icon(
                        //   Icons.diamond,
                        //   color: Colors.blue,
                        // ),
                        Image.asset(
                          'assets/others/diamond.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Obx(() {
                          return Text(
                            '${authController.profile.value.diamonds}',
                            // style: const TextStyle(color: Colors.white),
                          );
                        }),
                        const SizedBox(
                          width: 4,
                        ),
                        rPrimaryElevatedButton(
                            onPressed: () => Get.snackbar(
                                  'Oops',
                                  "Coming Soon!",
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                ),
                            primaryColor: Colors.green,
                            buttonText: '+ Recharge',
                            borderRadius: 8.0,
                            fontSize: 12.0),
                        // const SizedBox(
                        //   width: 64,
                        // ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Obx(() {
                                return rPrimaryElevatedButton(
                                    onPressed: () async {
                                      if (streamingController
                                              .selectedGift.value['id'] !=
                                          0) {
                                        List<dynamic> listReceiverIds = [];
                                        String receiverFullNames = '';

                                        int giftDiamonds = int.parse(
                                            streamingController
                                                .selectedGift.value['diamonds']
                                                .toString());
                                        List<dynamic> listReceiver =
                                            streamingController.listActiveCall
                                                .where((el) =>
                                                    el['selected'] != null &&
                                                    el['selected'] == true)
                                                .toList();
                                        if (listReceiver.isNotEmpty) {
                                          giftDiamonds *= listReceiver.length;
                                          for (int i = 0;
                                              i < listReceiver.length;
                                              i++) {
                                            dynamic receiverData =
                                                listReceiver[i];
                                            listReceiverIds
                                                .add(receiverData['uid']);
                                            if (i == listReceiver.length - 1) {
                                              receiverFullNames +=
                                                  '${receiverData['full_name']}';
                                            } else {
                                              receiverFullNames +=
                                                  '${receiverData['full_name']}, ';
                                            }
                                          }
                                        } else {
                                          listReceiverIds.add(data['uid']);
                                          receiverFullNames = data['full_name'];
                                        }
                                        if (authController
                                                .profile.value.diamonds! <
                                            giftDiamonds) {
                                          Get.snackbar(
                                            'Failed',
                                            "You've no sufficient diamonds. Please +Recharge.",
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }
                                        if (streamingController
                                                .loadingGiftSend.value !=
                                            -1) {
                                          return;
                                        }

                                        // dynamic roomSocketData = {
                                        //   'type': 'gift',
                                        //   'action': 'activity',
                                        //   'uid': authController
                                        //       .profile.value.user!.uid!,
                                        //   'sender_uid': authController
                                        //       .profile.value.user!.uid!,
                                        //   // 'receiver_uid': data['uid'],
                                        //   'receiver_uids': listReceiverIds,
                                        //   'full_name': authController
                                        //       .profile.value.full_name,
                                        //   'receiver_full_name':
                                        //       receiverFullNames,
                                        //   'profile_image': authController
                                        //           .profile
                                        //           .value
                                        //           .profile_image ??
                                        //       authController
                                        //           .profile.value.photo_url,
                                        //   'level': authController
                                        //       .profile.value.level,
                                        //   'gift_type': streamingController
                                        //       .selectedGift.value['gift_type']
                                        //       .toString(),
                                        //   'gift_id': int.parse(
                                        //       streamingController
                                        //           .selectedGift.value['id']
                                        //           .toString()),
                                        //   'gift_diamonds': giftDiamonds,
                                        //   'diamonds': int.parse(
                                        //       streamingController.selectedGift
                                        //           .value['diamonds']
                                        //           .toString()),
                                        //   'vat': int.parse(streamingController
                                        //       .selectedGift.value['vat']
                                        //       .toString()),
                                        //   'gift_image': streamingController
                                        //       .selectedGift.value['gift_image']
                                        //       .toString(),
                                        //   'gif': streamingController
                                        //       .selectedGift.value['gif']
                                        //       .toString(),
                                        //   'audio': streamingController
                                        //       .selectedGift.value['audio']
                                        //       .toString(),
                                        //   'vvip_or_vip_preference':
                                        //       authController.profile.value
                                        //           .vvip_or_vip_preference,
                                        // };
                                        // onUpdateAction(roomSocketData);
                                        await streamingController
                                            .tryToSendGiftOnLiveStreaming(
                                          channelName: streamingController
                                              .channelName.value,
                                          // receiverUid: data['uid'],
                                          giftType: streamingController
                                              .selectedGift.value['gift_type']
                                              .toString(),
                                          giftId: int.parse(streamingController
                                              .selectedGift.value['id']
                                              .toString()),
                                          context: context,
                                          totalDiamonds: giftDiamonds,
                                          diamonds: int.parse(
                                              streamingController.selectedGift
                                                  .value['diamonds']
                                                  .toString()),
                                          vat: int.parse(streamingController
                                              .selectedGift.value['vat']
                                              .toString()),
                                          receiverFullNames: receiverFullNames,
                                          receiverUids: listReceiverIds,
                                          giftImage: streamingController
                                              .selectedGift.value['gift_image']
                                              .toString(),
                                          gif: streamingController
                                              .selectedGift.value['gif']
                                              .toString(),
                                          audio: streamingController
                                              .selectedGift.value['audio']
                                              .toString(),
                                        );
                                        // if (result) {
                                        //   // Get.back();
                                        //   // Navigator.of(context).pop();
                                        // }
                                      }
                                    },
                                    primaryColor: streamingController
                                                .selectedGift.value['id'] !=
                                            0
                                        ? Colors.orange
                                        : Colors.grey,
                                    buttonTextColor: Colors.white,
                                    borderRadius: 8.0,
                                    buttonText: streamingController
                                                .loadingGiftSend.value !=
                                            -1
                                        ? 'Wait...'
                                        : 'Send',
                                    fontSize: 12.0);
                              }),
                              const SizedBox(
                                width: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      );
    });
  }
}

class giftItem extends StatelessWidget {
  const giftItem({
    Key? key,
    required this.streamingController,
    required this.authController,
    required this.giftData,
  }) : super(key: key);

  final LiveStreamingController streamingController;
  final AuthController authController;
  final dynamic giftData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () async {
          if (authController.profile.value.diamonds! < giftData['diamonds']) {
            Get.snackbar(
              'Failed',
              "You've no sufficient diamonds. Please +Recharge.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            // rShowSnackBar(
            //   context: context,
            //   title: "You've no sufficient diamonds. Please +Recharge.",
            //   color: Colors.red,
            //   durationInSeconds: 3,
            // );
            return;
          }
          streamingController.setSelectedGift(
            giftType: giftData['gif'] != null ? 'animation' : 'normal',
            id: giftData['id'],
            diamonds: giftData['diamonds'],
            vat: giftData['vat'],
            giftImage: giftData['gift_image'],
            gif: giftData['gif'],
            audio: giftData['audio'],
          );
        },
        child: Obx(() {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: (streamingController.selectedGift.value['id'] ==
                                giftData['id'] &&
                            streamingController
                                    .selectedGift.value['gift_type'] ==
                                'animation' &&
                            giftData['gif'] != null) ||
                        (streamingController.selectedGift.value['id'] ==
                                giftData['id'] &&
                            streamingController
                                    .selectedGift.value['gift_type'] ==
                                'normal' &&
                            giftData['gift_image'] != null)
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: giftData['gif'] ?? giftData['gift_image'],
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                    color: Colors.red,
                  )),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/others/diamond.png',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      '${giftData['diamonds']}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
