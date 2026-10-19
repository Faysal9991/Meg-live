import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidesTopAgentsView extends StatefulWidget {
  const SlidesTopAgentsView({super.key});

  @override
  State<SlidesTopAgentsView> createState() => _SlidesTopAgentsViewState();
}

class _SlidesTopAgentsViewState extends State<SlidesTopAgentsView> {
  late LiveStreamingController _livekitStreamingController;

  @override
  void initState() {
    super.initState();
    _livekitStreamingController = Get.find();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = _livekitStreamingController.topSlidingAgentRankingList;

      if (list.isEmpty) {
        return const SizedBox.shrink();
      }
      // A list retained from a dropped connection is not presented as current.
      final reconnecting = _livekitStreamingController.isRankingReconnecting(
        TOP_AGENCIES_UPDATE,
      );
      return AnimatedOpacity(
        opacity: reconnecting ? 0.6 : 1,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay:
                    list.length > 1 && !MediaQuery.disableAnimationsOf(context),
                height:
                    68 +
                    (MediaQuery.textScalerOf(context).scale(13) - 13).clamp(
                          0,
                          13,
                        ) *
                        3,
                viewportFraction: 1.0,
                padEnds: false,
                enlargeCenterPage: false,
                initialPage: 0,
                enableInfiniteScroll: list.length > 1,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 700),
                autoPlayCurve: Curves.easeOutCubic,
              ),
              itemCount: list.length,
              itemBuilder: (_, index, __) {
                return _agentCard(data: list[index], serial: index + 1);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _agentCard({required dynamic data, required int serial}) {
    final agentName = '${data['agent_name'] ?? ''}'.trim();
    // Owner ID can be 0 for agencies without a linked account.
    final rawUserId = '${data['user_id'] ?? ''}'.trim();
    final userId = rawUserId == '0' ? '' : rawUserId;
    // Socket rows score by current host balance; REST rows only send diamonds.
    final diamonds = '${data['total_hosts_diamonds'] ?? data['diamonds'] ?? 0}';
    // Prefer the server-supplied rank over the list position.
    final rank = int.tryParse('${data['rank'] ?? ''}');
    if (rank != null && rank > 0) serial = rank;
    final topLabel = '${data['rank'] ?? data['top'] ?? '-'}';
    final imageUrl = '${data['logo'] ?? ''}'.trim();
    final isAppOwner = data['is_app_owner'] == true;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.agentBannerStart,
            AppColors.agentBannerMiddle,
            AppColors.agentBannerEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white12,
                borderRadius: BorderRadius.circular(64),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildAvatar(imageUrl: imageUrl, serial: serial),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              agentName.isEmpty ? 'Unknown Agent' : agentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.onMedia,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isAppOwner) ...[
                            const SizedBox(width: 6),
                            _buildOwnerBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (userId.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                'ID: $userId',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.onMedia,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Image.asset('assets/others/diamond.png', height: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              diamonds,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onMedia,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTopPill(topLabel: topLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.premium,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: AppColors.onLight, size: 10),
          SizedBox(width: 3),
          Text(
            'Owner',
            style: TextStyle(
              color: AppColors.onLight,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required String imageUrl, required int serial}) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(width: 2, color: AppColors.textPrimary),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: imageUrl.isEmpty
                  ? Container(
                      color: AppColors.overlayMedium,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.onMedia,
                        size: 22,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.onMedia,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.overlayMedium,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.onMedia,
                          size: 22,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.premium,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.onMedia, width: 1.2),
              ),
              child: Text(
                '$serial',
                style: const TextStyle(
                  color: AppColors.onLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPill({required String topLabel}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.premium,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.onMediaSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TOP',
            style: TextStyle(
              color: AppColors.onLight,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            topLabel,
            style: const TextStyle(
              color: AppColors.onLight,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
