import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/others/slides_top_agents_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamingListView extends StatelessWidget {
  StreamingListView({super.key});
  final AuthController _authController = Get.find();
  final LiveStreamingController _livekitStreamingController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _livekitStreamingController.tryToLoadLiveRoomList();
        },
        backgroundColor: Colors.red,
        elevation: 6.0,
        child: Obx(() {
          if (_livekitStreamingController.loadingLiveRoomList.value) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          return const Icon(
            Icons.refresh_outlined,
            size: 32.0,
          );
        }),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Sliding
          Obx(() {
            if (_livekitStreamingController
                .topSlidingAgentRankingList.isEmpty) {
              return Container();
            }
            return const SlidesTopAgentsView();
          }),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: Obx(() {
              if (_livekitStreamingController.listFilterLiveStreams.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logos/doyel_live.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const Center(
                      child: Text(
                        'Empty',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                shrinkWrap: true,
                itemCount:
                    _livekitStreamingController.listFilterLiveStreams.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0),
                itemBuilder: (BuildContext context, int index) {
                  dynamic data =
                      _livekitStreamingController.listFilterLiveStreams[index];

                  return InkWell(
                    onTap: () => _onClickingLiveRoom(data: data),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        // gradient: Palette.storyGradient,
                        // color: Colors.black38,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      height: MediaQuery.of(context).size.width / 2 - 4,
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              height: MediaQuery.of(context).size.width / 2 - 4,
                              width: MediaQuery.of(context).size.width / 2 - 4,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: data['owner_profile']['profile_image'] ==
                                        null
                                    ? Image.asset(
                                        'assets/others/person.jpg',
                                        height:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                4,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: data['owner_profile']
                                            ['profile_image'],
                                        height:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                4,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.transparent,
                                  Colors.black26,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                // borderRadius: BorderRadius.only(
                                //   topRight: Radius.circular(20.0),
                                // ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    '${data['viewers_count']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                data['owner_profile']['vvip_or_vip_gif'] != null
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(left: 4.0),
                                        decoration: BoxDecoration(
                                            color: Colors.black38,
                                            // borderRadius: BorderRadius.only(
                                            //   bottomLeft: Radius.circular(20.0),
                                            //   bottomRight: Radius.circular(20.0),
                                            // ),
                                            border: Border.all(
                                              color: Colors.orange.shade600,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(100.0)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: CachedNetworkImage(
                                            imageUrl: data['owner_profile']
                                                ['vvip_or_vip_gif'],
                                            width: 40,
                                            height: 40,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      data['owner_profile']['full_name'],
                                      overflow: TextOverflow.ellipsis,
                                      // textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        backgroundColor: Colors.black12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  void _onClickingLiveRoom({required dynamic data}) {
    if (_livekitStreamingController.loadingRoom.value != 0) return;
    if (data['channelName'] == _authController.profile.value.user!.uid!) {
      Get.snackbar(
        'Not allowed',
        "Can't join own Live.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      return;
    }
    // Go to Live
    _livekitStreamingController.setBroadcastStreamingStuffs(
      brdchannelName: data['channel_id'].toString(),
      broadcasterName: data['owner_profile']['full_name'],
      brdImage: data['owner_profile']['profile_image'],
      isBrdOwner: false,
      activeInCalls: [],
      brdViewers: [],
      brdFollowers: [],
      brdBlocks: data['owner_profile']['blocks'],
      brdDiamonds: data['owner_profile']['diamonds'] ?? 0,
      brdLoveReacts: data['reacts'] ?? 0,
      brdLevel: null,
      allowSend: data['allow_send'] ?? true,
    );

    Get.to(
      () => LiveStreamingView(
        channelName: data['channel_id'].toString(),
        isBroadcaster: false,
        fullName: data['owner_profile']['full_name'],
        profileImage: data['owner_profile']['profile_image'],
        broadcasterDiamonds: data['owner_profile']['diamonds'] ?? 0,
        followers: const [],
        blocks: data['owner_profile']['blocks'],
        level: null,
        vVipOrVipPreference: {
          'vvip_or_vip_preference': {
            'rank': data['owner_profile']['vvip_rank'],
            'vvip_or_vip_gif': data['owner_profile']['vvip_or_vip_gif'],
          }
        },
      ),
    );
  }
}
