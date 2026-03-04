// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
// import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
// import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';

// void showViewersAndContributorsBottomSheet({
//   required BuildContext context,
//   // required List<dynamic> viewers,
//   required LiveStreamingController streamingController,
//   required Function onUpdateAction,
// }) {
//   AuthController authController = Get.find();
//   showModalBottomSheet(
//       context: context,
//       barrierColor: Colors.transparent,
//       enableDrag: false,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(30.0),
//         ),
//       ),
//       builder: (context) {
//         // if (authController.showingOverlay.value) {
//         //   Navigator.of(context).pop();
//         // }
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.50,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue, Theme.of(context).primaryColor],
//               // colors: [Colors.black, Colors.transparent],
//               begin: Alignment.bottomLeft,
//               end: Alignment.topRight,
//             ),
//             // borderRadius: const BorderRadius.horizontal(
//             //   left: Radius.circular(20),
//             //   right: Radius.circular(20),
//             // ),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: streamingController.showViewersTab.value
//                           ? Obx(() {
//                               return Text(
//                                 // 'Viewers ${streamingController.liveStreamData.value['viewers_count'] ?? 0}',
//                                 'Viewers ${streamingController.viewersCount.value}',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color:
//                                       streamingController.showViewersTab.value
//                                           ? Colors.white
//                                           : Colors.grey,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               );
//                             })
//                           : Text(
//                               'Contribution ranking',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: !streamingController.showViewersTab.value
//                                     ? Colors.white
//                                     : Colors.grey,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                     ),
//                     // InkWell(
//                     //   onTap: () => streamingController.setShowViewersTab(
//                     //       showViewers: true),
//                     //   child: Text(
//                     //     'Viewers ${viewers.length}',
//                     //     style: TextStyle(
//                     //       color: streamingController.showViewersTab.value
//                     //           ? Colors.white
//                     //           : Colors.grey,
//                     //       fontWeight: FontWeight.w700,
//                     //     ),
//                     //   ),
//                     // ),
//                     // InkWell(
//                     //   onTap: () => streamingController.setShowViewersTab(
//                     //       showViewers: false),
//                     //   child: Text(
//                     //     'Contribution ranking',
//                     //     style: TextStyle(
//                     //       color: !streamingController.showViewersTab.value
//                     //           ? Colors.white
//                     //           : Colors.grey,
//                     //       fontWeight: FontWeight.w700,
//                     //     ),
//                     //   ),
//                     // ),
//                     InkWell(
//                       onTap: () {
//                         // Get.back();
//                         Navigator.of(context).pop();
//                       },
//                       child: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 16,
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 // child: Obx(() {
//                 child: streamingController.showViewersTab.value
//                     ? ViewerWidget(
//                         onUpdateAction: onUpdateAction,
//                         streamingController: streamingController,
//                       )
//                     : ContributorWidget(
//                         streamingController: streamingController,
//                         onUpdateAction: onUpdateAction,
//                       ),

//                 // }),
//               ),
//             ],
//           ),
//         );
//       });
// }

// class ViewerWidget extends StatelessWidget {
//   const ViewerWidget({
//     Key? key,
//     required this.onUpdateAction,
//     required this.streamingController,
//   }) : super(key: key);

//   final LiveStreamingController streamingController;
//   final Function onUpdateAction;

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(Duration.zero, () {
//       if (
//           // (streamingController.liveStreamData.value['viewers_count'] ?? 0) >
//           streamingController.viewersCount.value >
//               streamingController.viewers.length) {
//         streamingController.loadLivekitParticipantList(
//           channelName: streamingController.channelName.value,
//           onUpdateAction: onUpdateAction,
//         );
//       }
//     });
//     return Obx(() {
//       if (streamingController.loadingParticipantList.value) {
//         return const Center(
//           child: SpinKitHourGlass(
//             color: Colors.red,
//             size: 50.0,
//           ),
//         );
//       }
//       return ListView.separated(
//         itemCount: streamingController.viewers.length,
//         itemBuilder: ((context, index) {
//           return _viewerItem(
//             data: streamingController.viewers[index],
//             onUpdateAction: onUpdateAction,
//             index: index,
//           );
//         }),
//         separatorBuilder: (BuildContext context, int index) {
//           return const SizedBox(
//             height: 8,
//           );
//         },
//       );
//     });
//   }
// }

// class ContributorWidget extends StatefulWidget {
//   const ContributorWidget(
//       {Key? key,
//       required this.streamingController,
//       required this.onUpdateAction})
//       : super(key: key);
//   final LiveStreamingController streamingController;
//   final Function onUpdateAction;

//   @override
//   State<ContributorWidget> createState() => _ContributorWidgetState();
// }

// class _ContributorWidgetState extends State<ContributorWidget> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     widget.streamingController.loadContributionRankingList(
//         userId: int.parse(widget.streamingController.channelName.value));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (widget.streamingController.loadingContributionRankingList.value) {
//         // Displaying LoadingSpinner to indicate waiting state
//         return const Center(
//           child: SpinKitHourGlass(
//             color: Colors.red,
//             size: 50.0,
//           ),
//         );
//       }
//       final dataList = widget.streamingController.contributionRankingList;
//       return ListView.builder(
//           itemCount: dataList.length,
//           itemBuilder: ((context, index) {
//             dynamic contribData = dataList[index];
//             try {
//               contribData['contributor_profile']['vvip_or_vip_preference'] =
//                   jsonDecode(contribData['contributor_profile']
//                       ['vvip_or_vip_preference']);
//             } catch (e) {
//               //
//             }
//             return _contributorItem(
//               serialNumber: index + 1,
//               data: contribData,
//               onUpdateAction: widget.onUpdateAction,
//             );
//           }));
//     });
//   }
// }

// class _viewerItem extends StatelessWidget {
//   const _viewerItem({
//     Key? key,
//     this.data,
//     this.onUpdateAction,
//     required this.index,
//   }) : super(key: key);
//   final dynamic data;
//   final Function? onUpdateAction;
//   final int index;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () => showUserInfoBottomSheet(
//           context: context, data: data, onUpdateAction: onUpdateAction!),
//       horizontalTitleGap: 0,
//       // leading: data['profile_image'] == null
//       //     ? ClipRRect(
//       //         borderRadius: BorderRadius.circular(100.0),
//       //         child: Image.asset(
//       //           'assets/others/person.jpg',
//       //           width: 28,
//       //           height: 28,
//       //           fit: BoxFit.cover,
//       //         ),
//       //       )
//       //     : ClipRRect(
//       //         borderRadius: BorderRadius.circular(100.0),
//       //         child: CachedNetworkImage(
//       //           imageUrl: data['profile_image'],
//       //           width: 28,
//       //           height: 28,
//       //           fit: BoxFit.cover,
//       //         ),
//       //       ),
//       leading: SizedBox(
//         width: 64,
//         height: 64,
//         child: Stack(children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             child: data['vvip_or_vip_preference'] != null
//                 ? Center(
//                     child: Container(
//                       width: (data['vvip_or_vip_preference']
//                                       ['vvip_or_vip_gif'] !=
//                                   null &&
//                               data['vvip_or_vip_preference']
//                                       ['vvip_or_vip_gif'] !=
//                                   '')
//                           ? 64
//                           : null,
//                       height: (data['vvip_or_vip_preference']
//                                       ['vvip_or_vip_gif'] !=
//                                   null &&
//                               data['vvip_or_vip_preference']
//                                       ['vvip_or_vip_gif'] !=
//                                   '')
//                           ? 64
//                           : null,
//                       decoration: BoxDecoration(
//                         image: (data['vvip_or_vip_preference']
//                                         ['vvip_or_vip_gif'] !=
//                                     null &&
//                                 data['vvip_or_vip_preference']
//                                         ['vvip_or_vip_gif'] !=
//                                     '')
//                             ? DecorationImage(
//                                 image: CachedNetworkImageProvider(
//                                   data['vvip_or_vip_preference']
//                                       ['vvip_or_vip_gif'],
//                                 ),
//                                 fit: BoxFit.fill,
//                               )
//                             : null,
//                       ),
//                       child: data['profile_image'] == null &&
//                               data['photo_url'] == null
//                           ? Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(100),
//                                 child: Image.asset(
//                                   'assets/others/person.jpg',
//                                   width: data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               null &&
//                                           data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               ''
//                                       ? 36
//                                       : 46,
//                                   height: data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               null &&
//                                           data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               ''
//                                       ? 36
//                                       : 46,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           : Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(100),
//                                 child: CachedNetworkImage(
//                                   imageUrl: data['profile_image'] ??
//                                       data['photo_url'],
//                                   width: data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               null &&
//                                           data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               ''
//                                       ? 36
//                                       : 46,
//                                   height: data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               null &&
//                                           data['vvip_or_vip_preference']
//                                                   ['vvip_or_vip_gif'] !=
//                                               ''
//                                       ? 36
//                                       : 46,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) => const Center(
//                                       child: CircularProgressIndicator(color:Colors.red)),
//                                 ),
//                               ),
//                             ),
//                     ),
//                   )
//                 : data['profile_image'] == null && data['photo_url'] == null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(100.0),
//                         child: Image.asset(
//                           'assets/others/person.jpg',
//                           width: 46,
//                           height: 46,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : ClipRRect(
//                         borderRadius: BorderRadius.circular(100.0),
//                         child: CachedNetworkImage(
//                           imageUrl: data['profile_image'] ?? data['photo_url'],
//                           width: 46,
//                           height: 46,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) =>
//                               const Center(child: CircularProgressIndicator(color:Colors.red)),
//                         ),
//                       ),
//           ),
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(100)),
//               child: Center(
//                 child: Text(
//                   '${data['level'] != null ? data['level']['level'] : 0}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 8,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 0,
//             top: 0,
//             child: data['contribution_rank'] == null ||
//                     data['contribution_rank'] == 0 ||
//                     index > 2
//                 ? Container()
//                 : Container(
//                     padding: const EdgeInsets.all(1.0),
//                     decoration: BoxDecoration(
//                       color: Colors.black38,
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     child: Text(
//                       'Top ${data['contribution_rank']}',
//                       style: const TextStyle(
//                         fontSize: 7,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ),
//           ),
//         ]),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "${data['full_name']}",
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             '(${data['is_agent'] ? 'Official Agent' : data['is_host'] ? 'Official Host' : data['is_reseller'] ? 'Official Reseller' : 'General User'})',
//             overflow: TextOverflow.ellipsis,
//             // textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//               backgroundColor: Colors.black12,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _contributorItem extends StatelessWidget {
//   const _contributorItem({
//     Key? key,
//     required this.serialNumber,
//     required this.data,
//     required this.onUpdateAction,
//   }) : super(key: key);
//   final int serialNumber;
//   final dynamic data;
//   final Function? onUpdateAction;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () {
//         showUserInfoBottomSheet(
//             context: context,
//             data: {
//               ...data['contributor_profile'],
//               'uid': data['contributor_profile']['user']['uid']
//             },
//             onUpdateAction: onUpdateAction!);
//       },
//       horizontalTitleGap: 0,
//       // leading: Text(
//       //   '$serialNumber',
//       //   style: const TextStyle(
//       //     fontSize: 16,
//       //     fontWeight: FontWeight.w500,
//       //     color: Colors.grey,
//       //   ),
//       // ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 64,
//             height: 64,
//             child: Stack(children: [
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 child: data['contributor_profile']['vvip_or_vip_preference'] !=
//                         null
//                     ? Center(
//                         child: Container(
//                           width: (data['contributor_profile']
//                                               ['vvip_or_vip_preference']
//                                           ['vvip_or_vip_gif'] !=
//                                       null &&
//                                   data['contributor_profile']
//                                               ['vvip_or_vip_preference']
//                                           ['vvip_or_vip_gif'] !=
//                                       '')
//                               ? 64
//                               : null,
//                           height: (data['contributor_profile']
//                                               ['vvip_or_vip_preference']
//                                           ['vvip_or_vip_gif'] !=
//                                       null &&
//                                   data['contributor_profile']
//                                               ['vvip_or_vip_preference']
//                                           ['vvip_or_vip_gif'] !=
//                                       '')
//                               ? 64
//                               : null,
//                           decoration: BoxDecoration(
//                             image: (data['contributor_profile']
//                                                 ['vvip_or_vip_preference']
//                                             ['vvip_or_vip_gif'] !=
//                                         null &&
//                                     data['contributor_profile']
//                                                 ['vvip_or_vip_preference']
//                                             ['vvip_or_vip_gif'] !=
//                                         '')
//                                 ? DecorationImage(
//                                     image: CachedNetworkImageProvider(
//                                       data['contributor_profile']
//                                               ['vvip_or_vip_preference']
//                                           ['vvip_or_vip_gif'],
//                                     ),
//                                     fit: BoxFit.fill,
//                                   )
//                                 : null,
//                           ),
//                           child: data['contributor_profile']['profile_image'] ==
//                                       null &&
//                                   data['contributor_profile']['photo_url'] ==
//                                       null
//                               ? Center(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(100),
//                                     child: Image.asset(
//                                       'assets/others/person.jpg',
//                                       width: data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   null &&
//                                               data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   ''
//                                           ? 36
//                                           : 46,
//                                       height: data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   null &&
//                                               data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   ''
//                                           ? 36
//                                           : 46,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 )
//                               : Center(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(100),
//                                     child: CachedNetworkImage(
//                                       imageUrl: data['contributor_profile']
//                                               ['profile_image'] ??
//                                           data['contributor_profile']
//                                               ['photo_url'],
//                                       width: data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   null &&
//                                               data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   ''
//                                           ? 36
//                                           : 46,
//                                       height: data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   null &&
//                                               data['contributor_profile'][
//                                                           'vvip_or_vip_preference']
//                                                       ['vvip_or_vip_gif'] !=
//                                                   ''
//                                           ? 36
//                                           : 46,
//                                       fit: BoxFit.cover,
//                                       placeholder: (context, url) =>
//                                           const Center(
//                                               child:
//                                                   CircularProgressIndicator(color:Colors.red)),
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       )
//                     : data['contributor_profile']['profile_image'] == null &&
//                             data['contributor_profile']['photo_url'] == null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(100.0),
//                             child: Image.asset(
//                               'assets/others/person.jpg',
//                               width: 46,
//                               height: 46,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : ClipRRect(
//                             borderRadius: BorderRadius.circular(100.0),
//                             child: CachedNetworkImage(
//                               imageUrl: data['contributor_profile']
//                                       ['profile_image'] ??
//                                   data['contributor_profile']['photo_url'],
//                               width: 46,
//                               height: 46,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) => const Center(
//                                   child: CircularProgressIndicator(color:Colors.red)),
//                             ),
//                           ),
//               ),
//               Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     width: 20,
//                     height: 20,
//                     decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(100)),
//                     child: Center(
//                       child: Text(
//                         '${data['contributor_profile']['level'] != null ? data['contributor_profile']['level']['level'] : 0}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 8,
//                         ),
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//           const SizedBox(
//             width: 8,
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * .40),
//                 child: Text(
//                   "${data['contributor_profile']['full_name']}",
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Text(
//                 '(${data['contributor_profile']['is_agent'] ? 'Official Agent' : data['contributor_profile']['is_host'] ? 'Official Host' : data['contributor_profile']['is_reseller'] ? 'Official Reseller' : 'General User'})',
//                 overflow: TextOverflow.ellipsis,
//                 // textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                   backgroundColor: Colors.black12,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//               child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const Icon(
//                 Icons.diamond,
//                 color: Colors.blue,
//                 size: 16,
//               ),
//               // Image.asset(
//               //   'images/icons/coin.png',
//               //   width: 16,
//               //   fit: BoxFit.contain,
//               // ),
//               const SizedBox(
//                 width: 4,
//               ),
//               Text(
//                 '${data['diamonds']}',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//               serialNumber - 1 == 0
//                   ? const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: 8,
//                         ),
//                         Text(
//                           'Top:',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Icon(
//                           Icons.star_border_outlined,
//                           color: Colors.amber,
//                         ),
//                       ],
//                     )
//                   : serialNumber - 1 == 1
//                       ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const SizedBox(
//                               width: 8,
//                             ),
//                             const Text(
//                               'Top:',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Icon(
//                               Icons.star_border_outlined,
//                               color: Colors.grey[400],
//                             ),
//                           ],
//                         )
//                       : serialNumber - 1 == 2
//                           ? Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 8,
//                                 ),
//                                 const Text(
//                                   'Top:',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.star_border_outlined,
//                                   color: Colors.brown[800],
//                                 ),
//                               ],
//                             )
//                           : Container(),
//             ],
//           )),
//         ],
//       ),
//     );
//   }
// }
