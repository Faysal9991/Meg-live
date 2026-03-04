// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void showHomeAgentListBottomSheet({
//   required BuildContext context,
// }) {
//   final LivekitStreamingController streamingController = Get.find();

//   showModalBottomSheet(
//       context: context,
//       barrierColor: Colors.transparent,
//       enableDrag: false,
//       // isScrollControlled: true,
//       builder: (context) {
//         return Container(
//             height: MediaQuery.of(context).size.height * 0.60,
//             decoration: BoxDecoration(
//               // gradient: LinearGradient(
//               //   colors: [Colors.blue, Theme.of(context).primaryColor],
//               //   // colors: [Colors.black, Colors.transparent],
//               //   begin: Alignment.bottomLeft,
//               //   end: Alignment.topRight,
//               // ),
//               gradient: Palette.linearGradient3,
//               borderRadius: const BorderRadius.horizontal(
//                 left: Radius.circular(20),
//                 right: Radius.circular(20),
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 16,
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: TopAgentRankingWidget(
//                     streamingController: streamingController,
//                   ),
//                 ),
//                 Positioned(
//                   right: 16,
//                   top: 8,
//                   child: InkWell(
//                     onTap: () {
//                       // Get.back();
//                       Navigator.of(context).pop();
//                     },
//                     child: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ),
//               ],
//             ));
//       });
// }

// class TopAgentRankingWidget extends StatefulWidget {
//   const TopAgentRankingWidget({Key? key, required this.streamingController})
//       : super(key: key);
//   final LivekitStreamingController streamingController;

//   @override
//   State<TopAgentRankingWidget> createState() => _TopAgentRankingWidgetState();
// }

// class _TopAgentRankingWidgetState extends State<TopAgentRankingWidget> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     widget.streamingController.loadTopAgentRankingList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 16.0),
//           child: Text(
//             'Ranking of Top Agents',
//             style: TextStyle(
//               color: Colors.orangeAccent,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//         Obx(() {
//           if (widget.streamingController.loadingTopAgentRankingList.value) {
//             // Displaying LoadingSpinner to indicate waiting state
//             return const Padding(
//               padding: EdgeInsets.only(top: 100.0),
//               child: Center(
//                 child: SpinKitCircle(
//                   color: Colors.white,
//                   size: 50.0,
//                 ),
//               ),
//             );
//           }
// // Extracting data from snapshot object
//           final dataList = widget.streamingController.topAgentRankingList;
//           return SizedBox(
//             height: MediaQuery.of(context).size.height * 0.50,
//             child: ListView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: dataList.length,
//                 itemBuilder: ((context, index) {
//                   dynamic contribData = dataList[index];

//                   return _agentItem(
//                     serialNumber: index + 1,
//                     data: contribData,
//                     // streamingController: streamingController,
//                   );
//                 })),
//           );
//         }),
//       ],
//     );
//   }
// }

// class _agentItem extends StatelessWidget {
//   const _agentItem({
//     Key? key,
//     required this.serialNumber,
//     required this.data,
//   }) : super(key: key);
//   final int serialNumber;
//   final dynamic data;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () {
//         showUserInfoBottomSheet(
//             context: context, data: data, onUpdateAction: () {});
//       },
//       horizontalTitleGap: 0,
//       // contentPadding: const EdgeInsets.only(left: 16, right: 8),
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
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               '$serialNumber',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 2,
//           ),
//           SizedBox(
//             width: 46,
//             height: 46,
//             child: Stack(children: [
//               Positioned(
//                   top: 0,
//                   left: 0,
//                   child: SizedBox(
//                     width: 46,
//                     height: 46,
//                     child: Center(
//                       child: data['profile_image'] == null
//                           ? Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(100),
//                                 child: Image.asset(
//                                   'assets/others/person.jpg',
//                                   width: 36,
//                                   height: 36,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           : Center(
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(100),
//                                 child: CachedNetworkImage(
//                                   imageUrl: data['profile_image'],
//                                   width: 36,
//                                   height: 36,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) => const Center(
//                                       child: CircularProgressIndicator()),
//                                 ),
//                               ),
//                             ),
//                     ),
//                   )),
//               data["vvip_or_vip_preference"]["vvip_or_vip_gif"] != null
//                   ? Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                             color: Colors.black38,
//                             // borderRadius: BorderRadius.only(
//                             //   bottomLeft: Radius.circular(20.0),
//                             //   bottomRight: Radius.circular(20.0),
//                             // ),
//                             border: Border.all(
//                               color: Colors.orange.shade600,
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(100.0)),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(100.0),
//                           child: CachedNetworkImage(
//                             imageUrl: data["vvip_or_vip_preference"]
//                                 ["vvip_or_vip_gif"],
//                             width: 32,
//                             height: 32,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Container(),
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
//                         '${data['level'] != null ? data['level']['level'] : 0}',
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
//                     maxWidth: MediaQuery.of(context).size.width * .35),
//                 child: Text(
//                   "${data['full_name']}",
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Text(
//                 'Total Hosts: ${data['host_count']}',
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
//               // const Icon(
//               //   Icons.diamond,
//               //   color: Colors.blue,
//               // ),
//               Image.asset(
//                 'images/icons/diamond.gif',
//                 width: 20,
//                 fit: BoxFit.contain,
//               ),
//               Text(
//                 '${data['host_diamonds']}',
//                 style: const TextStyle(
//                   fontSize: 10,
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
//                                   color: Colors.brown[400],
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
