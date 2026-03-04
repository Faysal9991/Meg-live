// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
// import 'package:doyel_live/app/widgets/reusable_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class GiftsWidget extends StatelessWidget {
//   const GiftsWidget({
//     super.key,
//     required this.streamingController,
//     required this.authController,
//     required this.data,
//     required this.onUpdateAction,
//   });
//   final LiveStreamingController streamingController;
//   final AuthController authController;
//   final dynamic data;
//   final Function onUpdateAction;

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(Duration.zero, () {
//       if (streamingController.listNormalGift.isEmpty) {
//         streamingController.fetchGiftList();
//       }
//     });
//     return SizedBox(
//       height: 280,
//       child: Obx(() {
//         if (streamingController.loadingGfitList.value) {
//           return const Center(
//             child: SpinKitHourGlass(
//               color: Colors.red,
//               size: 50.0,
//             ),
//           );
//         }
//         return Stack(
//           children: [
//             SizedBox(
//               height: 220,
//               child: GridView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 4,
//                 ),
//                 shrinkWrap: true,
//                 itemCount: streamingController.listNormalGift.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 4.0,
//                     mainAxisSpacing: 4.0),
//                 itemBuilder: ((context, index) {
//                   dynamic giftData = streamingController.listNormalGift[index];
//                   return giftItem(
//                     streamingController: streamingController,
//                     authController: authController,
//                     giftData: giftData,
//                   );
//                 }),
//               ),
//             ),
//             data['uid'] == authController.profile.value.user!.uid!
//                 ? Container()
//                 : Positioned(
//                     bottom: 8,
//                     left: 0,
//                     right: 0,
//                     child: SizedBox(
//                       height: 50,
//                       child: Row(
//                         children: [
//                           const SizedBox(
//                             width: 24,
//                           ),
//                           // const Icon(
//                           //   Icons.diamond,
//                           //   color: Colors.blue,
//                           // ),
//                           Image.asset(
//                             'assets/others/diamond.png',
//                             width: 18,
//                             height: 18,
//                           ),
//                           const SizedBox(
//                             width: 4,
//                           ),
//                           Obx(() {
//                             return Text(
//                               '${authController.profile.value.diamonds}',
//                               style: const TextStyle(color: Colors.blue),
//                             );
//                           }),
//                           const SizedBox(
//                             width: 4,
//                           ),
//                           rPrimaryElevatedButton(
//                               onPressed: () => Get.snackbar(
//                                     'Oops',
//                                     "Coming Soon!",
//                                     backgroundColor: Colors.orange,
//                                     colorText: Colors.white,
//                                     snackPosition: SnackPosition.TOP,
//                                   ),
//                               primaryColor: Colors.green,
//                               buttonText: '+ Recharge',
//                               borderRadius: 8.0,
//                               fontSize: 12.0),
//                           // const SizedBox(
//                           //   width: 64,
//                           // ),
//                           Expanded(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Obx(() {
//                                   return rPrimaryElevatedButton(
//                                       onPressed: () async {
//                                         if (streamingController
//                                                 .selectedGift.value['id'] !=
//                                             0) {
//                                           if (authController
//                                                   .profile.value.diamonds! <
//                                               int.parse(streamingController
//                                                   .selectedGift
//                                                   .value['diamonds']
//                                                   .toString())) {
//                                             Get.snackbar(
//                                               'Failed',
//                                               "You've no sufficient diamonds. Please +Recharge.",
//                                               backgroundColor: Colors.red,
//                                               colorText: Colors.white,
//                                               snackPosition: SnackPosition.TOP,
//                                             );
//                                             // rShowSnackBar(
//                                             //   context: context,
//                                             //   title:
//                                             //       "You've no sufficient diamonds. Please +Recharge.",
//                                             //   color: Colors.red,
//                                             //   durationInSeconds: 3,
//                                             // );

//                                             return;
//                                           }
//                                           if (streamingController
//                                                   .loadingGiftSend.value !=
//                                               -1) {
//                                             return;
//                                           }
//                                           // // Some issue occured.
//                                           // onUpdateAction({
//                                           //   'type': streamingController.SEND_GIFT,
//                                           //   'gift_type': streamingController
//                                           //       .selectedGift.value['gift_type']
//                                           //       .toString(),
//                                           //   'receiver_uid': data['uid'],
//                                           //   'gift_id': int.parse(streamingController
//                                           //       .selectedGift.value['id']
//                                           //       .toString()),
//                                           // });
//                                           await streamingController
//                                               .tryToSendGiftOnLiveStreaming(
//                                             channelName: streamingController
//                                                 .channelName.value,
//                                             receiverUid: data['uid'],
//                                             giftType: streamingController
//                                                 .selectedGift.value['gift_type']
//                                                 .toString(),
//                                             giftId: int.parse(
//                                                 streamingController
//                                                     .selectedGift.value['id']
//                                                     .toString()),
//                                             context: context,
//                                             diamonds: int.parse(
//                                                 streamingController.selectedGift
//                                                     .value['diamonds']
//                                                     .toString()),
//                                             vat: int.parse(streamingController
//                                                 .selectedGift.value['vat']
//                                                 .toString()),
//                                             receiverFullName: data['full_name'],
//                                             giftImage: streamingController
//                                                 .selectedGift
//                                                 .value['gift_image']
//                                                 .toString(),
//                                             gif: streamingController
//                                                 .selectedGift.value['gif']
//                                                 .toString(),
//                                             audio: streamingController
//                                                 .selectedGift.value['audio']
//                                                 .toString(),
//                                           );
//                                           // if (result) {
//                                           //   // Get.back();
//                                           //   // Navigator.of(context).pop();
//                                           // }
//                                         }
//                                       },
//                                       primaryColor: streamingController
//                                                   .selectedGift.value['id'] !=
//                                               0
//                                           ? Colors.green
//                                           : Colors.grey,
//                                       buttonTextColor: Colors.white,
//                                       borderRadius: 8.0,
//                                       buttonText: streamingController
//                                                   .loadingGiftSend.value !=
//                                               -1
//                                           ? 'Wait...'
//                                           : 'Send',
//                                       fontSize: 12.0);
//                                 }),
//                                 const SizedBox(
//                                   width: 24,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//           ],
//         );
//       }),
//     );
//   }
// }

// class giftItem extends StatelessWidget {
//   const giftItem({
//     Key? key,
//     required this.streamingController,
//     required this.authController,
//     required this.giftData,
//   }) : super(key: key);

//   final LiveStreamingController streamingController;
//   final AuthController authController;
//   final dynamic giftData;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       child: InkWell(
//         onTap: () async {
//           if (authController.profile.value.diamonds! < giftData['diamonds']) {
//             Get.snackbar(
//               'Failed',
//               "You've no sufficient diamonds. Please +Recharge.",
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//               snackPosition: SnackPosition.TOP,
//             );
//             // rShowSnackBar(
//             //   context: context,
//             //   title: "You've no sufficient diamonds. Please +Recharge.",
//             //   color: Colors.red,
//             //   durationInSeconds: 3,
//             // );
//             return;
//           }
//           streamingController.setSelectedGift(
//             giftType: giftData['gif'] != null ? 'animation' : 'normal',
//             id: giftData['id'],
//             diamonds: giftData['diamonds'],
//             vat: giftData['vat'],
//             giftImage: giftData['gift_image'],
//             gif: giftData['gif'],
//             audio: giftData['audio'],
//           );
//         },
//         child: Obx(() {
//           return Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: (streamingController.selectedGift.value['id'] ==
//                                 giftData['id'] &&
//                             streamingController
//                                     .selectedGift.value['gift_type'] ==
//                                 'animation' &&
//                             giftData['gif'] != null) ||
//                         (streamingController.selectedGift.value['id'] ==
//                                 giftData['id'] &&
//                             streamingController
//                                     .selectedGift.value['gift_type'] ==
//                                 'normal' &&
//                             giftData['gift_image'] != null)
//                     ? Theme.of(context).primaryColor
//                     : Colors.transparent,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CachedNetworkImage(
//                   imageUrl: giftData['gif'] ?? giftData['gift_image'],
//                   width: MediaQuery.of(context).size.width * .15,
//                   height: MediaQuery.of(context).size.width * .15,
//                   fit: BoxFit.contain,
//                   placeholder: (context, url) => const Center(
//                       child: CircularProgressIndicator(
//                     color: Colors.red,
//                   )),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(
//                       'assets/others/diamond.png',
//                       width: 18,
//                       height: 18,
//                     ),
//                     const SizedBox(
//                       width: 2,
//                     ),
//                     Text(
//                       '${giftData['diamonds']}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
