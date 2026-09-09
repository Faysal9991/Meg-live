import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
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
        backgroundColor: AppColors.accent,
        tooltip: 'Refresh live rooms',
        elevation: 3.0,
        child: Obx(() {
          if (_livekitStreamingController.loadingLiveRoomList.value ||
              _livekitStreamingController.loadingBannerList.value ||
              _livekitStreamingController.loadingTopHostList.value ||
              _livekitStreamingController.loadingTopContributorList.value) {
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
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
                      'No live rooms yet',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Live Now',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = liveRooms[index];
                    return Semantics(
                      button: true,
                      label:
                          'Join ${data['owner_profile']?['full_name'] ?? 'host'} live room',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _onClickingLiveRoom(data: data),
                        child: _buildLiveRoomCard(
                          context: context,
                          data: data,
                          showKingIcon: _isTopHostLiveRoom(
                            liveRoomData: data,
                            topHostIds: topHostIds,
                          ),
                        ),
                      ),
                    );
                  }, childCount: liveRooms.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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

  Widget _buildLiveRoomCard({
    required BuildContext context,
    required dynamic data,
    required bool showKingIcon,
  }) {
    final owner = data['owner_profile'];
    final name = owner?['full_name']?.toString() ?? '';
    final imageUrl = owner?['profile_image']?.toString();
    return AppCard(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl == null || imageUrl.isEmpty)
                    Image.asset('assets/others/person.jpg', fit: BoxFit.cover)
                  else
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/others/person.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayStrong,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: AppColors.onMedia,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayStrong,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            color: AppColors.onMedia,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data['viewers_count'] ?? 0}',
                            style: const TextStyle(
                              color: AppColors.onMedia,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
            child: Row(
              children: [
                if (showKingIcon) ...[
                  const Tooltip(
                    message: 'Top Host',
                    child: Icon(
                      Icons.workspace_premium,
                      color: AppColors.premiumText,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                if (owner?['vvip_or_vip_gif'] != null) ...[
                  CachedNetworkImage(
                    imageUrl: owner['vvip_or_vip_gif'],
                    width: 20,
                    height: 20,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.stars,
                      size: 18,
                      color: AppColors.premiumText,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
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
