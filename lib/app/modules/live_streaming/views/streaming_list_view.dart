import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/others/slides_top_agents_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/widgets/home_banner_carousel.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamingListView extends StatelessWidget {
  StreamingListView({super.key, this.onOpenLiveRoomOverride});

  final ValueChanged<Map<String, dynamic>>? onOpenLiveRoomOverride;
  final AuthController _authController = Get.find();
  final LiveStreamingController _livekitStreamingController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _livekitStreamingController.refreshStreamingHomeFeed();
        },
        backgroundColor: AppColors.danger,
        elevation: 6.0,
        child: Obx(() {
          if (_livekitStreamingController.loadingLiveRoomList.value ||
              _livekitStreamingController.loadingBannerList.value ||
              _livekitStreamingController.loadingTopHostList.value) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.onPrimary),
            );
          }
          return const Icon(Icons.refresh_outlined, size: 32.0);
        }),
      ),
      body: Obx(() {
        final liveRooms = _livekitStreamingController.listFilterLiveStreams;
        final topHostIds = _livekitStreamingController.topHostList
            .map((host) => host.uid)
            .toSet();
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (_livekitStreamingController.bannerList.isNotEmpty ||
                _livekitStreamingController.loadingBannerList.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: HomeBannerCarousel(
                    banners: _livekitStreamingController.bannerList.toList(),
                  ),
                ),
              ),
            if (_livekitStreamingController.bannerList.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (_livekitStreamingController
                .topSlidingAgentRankingList
                .isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: SlidesTopAgentsView(),
                ),
              ),

            if (liveRooms.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logos/biho.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Empty',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Live Now',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = liveRooms[index];
                    return InkWell(
                      onTap: () => _onClickingLiveRoom(data: data),
                      child: _buildLiveRoomCard(
                        context: context,
                        data: data,
                        showKingIcon: _isTopHostLiveRoom(
                          liveRoomData: data,
                          topHostIds: topHostIds,
                        ),
                      ),
                    );
                  }, childCount: liveRooms.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ],
        );
      }),
    );
  }

  void _onTapTopHost(TopHost host) {
    final match = _livekitStreamingController.listFilterLiveStreams
        .firstWhereOrNull(
          (element) => _extractLiveRoomHostUid(element) == host.uid,
        );
    if (match == null) {
      Get.snackbar(
        'Unavailable',
        'Host is not live right now.',
        backgroundColor: AppColors.warning,
        colorText: AppColors.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    _onClickingLiveRoom(data: match);
  }

  Widget _buildLiveRoomCard({
    required BuildContext context,
    required dynamic data,
    required bool showKingIcon,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
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
                child: data['owner_profile']['profile_image'] == null
                    ? Image.asset(
                        'assets/others/person.jpg',
                        height: MediaQuery.of(context).size.width / 2 - 4,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: data['owner_profile']['profile_image'],
                        height: MediaQuery.of(context).size.width / 2 - 4,
                        width: MediaQuery.of(context).size.width / 2 - 4,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
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
                colors: [Colors.transparent, AppColors.black26],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility,
                    color: AppColors.onPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${data['viewers_count']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showKingIcon)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black45,
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: AppColors.premium,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Top Host',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
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
                        margin: const EdgeInsets.only(left: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.black38,
                          border: Border.all(
                            color: AppColors.warning,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: CachedNetworkImage(
                            imageUrl: data['owner_profile']['vvip_or_vip_gif'],
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
                     data['owner_profile']?['full_name']?.toString() ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        backgroundColor: AppColors.black12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isTopHostLiveRoom({
    required dynamic liveRoomData,
    required Set<int> topHostIds,
  }) {
    final hostUid = _extractLiveRoomHostUid(liveRoomData);
    if (hostUid == null) {
      return false;
    }
    return topHostIds.contains(hostUid);
  }

  int? _extractLiveRoomHostUid(dynamic liveRoomData) {
    if (liveRoomData is! Map) {
      return null;
    }

    final ownerProfile = liveRoomData['owner_profile'];
    if (ownerProfile is Map) {
      final ownerUid = _toInt(ownerProfile['uid']);
      if (ownerUid != null) {
        return ownerUid;
      }
    }

    return _toInt(liveRoomData['channel_id']);
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  void _onClickingLiveRoom({required dynamic data}) {
    if (_livekitStreamingController.loadingRoom.value != 0) return;
    if (data['channel_id'] == _authController.profile.value.user!.uid!) {
      Get.snackbar(
        'Not allowed',
        "Can't join own Live.",
        backgroundColor: AppColors.warning,
        colorText: AppColors.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      return;
    }
    final liveRoomData = Map<String, dynamic>.from(data as Map);
    if (onOpenLiveRoomOverride != null) {
      onOpenLiveRoomOverride!(liveRoomData);
      return;
    }
    // Go to Live
    _livekitStreamingController.setBroadcastStreamingStuffs(
      brdchannelName: liveRoomData['channel_id'].toString(),
      broadcasterName: liveRoomData['owner_profile']['full_name'],
      brdImage: liveRoomData['owner_profile']['profile_image'],
      isBrdOwner: false,
      activeInCalls: [],
      brdViewers: [],
      brdFollowers: [],
      brdBlocks: liveRoomData['owner_profile']['blocks'],
      brdDiamonds: liveRoomData['owner_profile']['diamonds'] ?? 0,
      brdLoveReacts: liveRoomData['reacts'] ?? 0,
      brdLevel: null,
      allowSend: liveRoomData['allow_send'] ?? true,
    );

    Get.to(
      () => LiveStreamingView(
        channelName: liveRoomData['channel_id'].toString(),
        isBroadcaster: false,
        fullName: liveRoomData['owner_profile']['full_name'],
        profileImage: liveRoomData['owner_profile']['profile_image'],
        broadcasterDiamonds: liveRoomData['owner_profile']['diamonds'] ?? 0,
        followers: const [],
        blocks: liveRoomData['owner_profile']['blocks'],
        level: null,
        vVipOrVipPreference: {
          'vvip_or_vip_preference': {
            'rank': liveRoomData['owner_profile']['vvip_rank'],
            'vvip_or_vip_gif': liveRoomData['owner_profile']['vvip_or_vip_gif'],
          },
        },
      ),
    );
  }
}
