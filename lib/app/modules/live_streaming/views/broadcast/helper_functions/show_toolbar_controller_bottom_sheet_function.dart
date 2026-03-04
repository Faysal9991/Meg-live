// import 'package:doyel_live/app/modules/livekit_streaming/controllers/livekit_streaming_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
// import 'package:doyel_live/app/modules/livekit_streaming/firebase/livestreaming_firebase_stuffs.dart';
// import 'package:doyel_live/app/modules/livekit_streaming/views/broadcast/helper_functions/show_camera_filters_bottom_sheet_function.dart';
// import 'package:doyel_live/app/widgets/circle_button.dart';

// void showToolbarControllerBottomSheet({
//   required BuildContext context,
//   required LivekitStreamingController streamingController,
//   required LiveStreamingFirebaseStuffs streamingFirebaseStuffs,
//   required AuthController authController,
//   required Function onCallEnd,
//   required VoidCallback onToggleMute,
//   required VoidCallback onSpeakerphoneOn,
//   required VoidCallback onToggleVideoEnable,
//   required VoidCallback onSwitchCamera,
//   required Function onUpdateAction,
// }) {
//   showModalBottomSheet(
//       context: context,
//       barrierColor: Colors.transparent,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(30.0),
//         ),
//       ),
//       builder: (context) {
//         if (authController.showingOverlay.value) {
//           Navigator.of(context).pop();
//         }
//         return Container(
//           height: 54,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue, Theme.of(context).primaryColor],
//               // colors: [Colors.black, Colors.transparent],
//               begin: Alignment.bottomLeft,
//               end: Alignment.topRight,
//             ),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Obx(() {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     Obx(() {
//                       return RawMaterialButton(
//                         onPressed: onToggleMute,
//                         shape: const CircleBorder(),
//                         elevation: 2.0,
//                         fillColor: streamingController.muted.value
//                             ? Colors.blueAccent
//                             : Colors.white,
//                         padding: const EdgeInsets.all(6.0),
//                         constraints: const BoxConstraints(
//                           minWidth: 36,
//                           minHeight: 36,
//                         ),
//                         child: Icon(
//                           streamingController.muted.value
//                               ? Icons.mic_off
//                               : Icons.mic,
//                           color: streamingController.muted.value
//                               ? Colors.white
//                               : Colors.blueAccent,
//                           size: 16.0,
//                         ),
//                       );
//                     }),
//                     // const SizedBox(
//                     //   width: 16,
//                     // ),
//                     // IconButton(
//                     //   disabledColor: Colors.grey,
//                     //   // onPressed: Hardware.instance.canSwitchSpeakerphone
//                     //   //     ? _setSpeakerphoneOn
//                     //   //     : null,
//                     //   onPressed: onSpeakerphoneOn,
//                     //   icon: Icon(Hardware.instance.speakerOn!
//                     //       ? Icons.speaker_phone
//                     //       : Icons.phone_android),
//                     //   tooltip: 'Switch SpeakerPhone',
//                     // ),
//                     const SizedBox(
//                       width: 16,
//                     ),
//                     !streamingController.isBroadcaster.value &&
//                             streamingController.callType.value == 'video'
//                         ? Obx(() {
//                             return RawMaterialButton(
//                               onPressed: onToggleVideoEnable,
//                               shape: const CircleBorder(),
//                               elevation: 2.0,
//                               fillColor: streamingController.videoDisabled.value
//                                   ? Colors.blueAccent
//                                   : Colors.white,
//                               padding: const EdgeInsets.all(6.0),
//                               constraints: const BoxConstraints(
//                                 minWidth: 36,
//                                 minHeight: 36,
//                               ),
//                               child: Icon(
//                                 streamingController.videoDisabled.value
//                                     ? Icons.videocam_off
//                                     : Icons.videocam,
//                                 color: streamingController.videoDisabled.value
//                                     ? Colors.white
//                                     : Colors.blueAccent,
//                                 size: 16.0,
//                               ),
//                             );
//                           })
//                         : const SizedBox(
//                             width: 0,
//                           ),
//                     !streamingController.isBroadcaster.value &&
//                             streamingController.callType.value == 'video'
//                         ? const SizedBox(
//                             width: 16,
//                           )
//                         : const SizedBox(
//                             width: 0,
//                           ),
//                     streamingController.callType.value == 'video'
//                         ? RawMaterialButton(
//                             onPressed: onSwitchCamera,
//                             shape: const CircleBorder(),
//                             elevation: 2.0,
//                             fillColor: Colors.white,
//                             padding: const EdgeInsets.all(6.0),
//                             constraints: const BoxConstraints(
//                               minWidth: 36,
//                               minHeight: 36,
//                             ),
//                             child: const Icon(
//                               Icons.switch_camera,
//                               color: Colors.blueAccent,
//                               size: 16.0,
//                             ),
//                           )
//                         : Container(),
//                     const SizedBox(
//                       width: 16,
//                     ),
//                     // Camera filters
//                     streamingController.isBroadcaster.value &&
//                             streamingController.callType.value == 'video'
//                         ? CircleButton(
//                             minWidth: 36,
//                             minHeight: 36,
//                             icon: Icons.camera,
//                             iconSize: 18,
//                             backgroundColor: Colors.white,
//                             iconColor: Colors.pink,
//                             onPressed: () {
//                               showCameraFiltersBottomSheet(
//                                 context: context,
//                                 authController: authController,
//                                 streamingController: streamingController,
//                                 streamingFirebaseStuffs:
//                                     streamingFirebaseStuffs,
//                               );
//                             })
//                         : Container(),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         );
//       });
// }
