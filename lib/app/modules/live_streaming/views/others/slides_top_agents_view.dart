import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidesTopAgentsView extends StatefulWidget {
  const SlidesTopAgentsView({super.key});

  @override
  State<SlidesTopAgentsView> createState() => _SlidesTopAgentsViewState();
}

class _SlidesTopAgentsViewState extends State<SlidesTopAgentsView> {
  late LiveStreamingController _livekitStreamingController;
  int _currentIndex = 0;

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
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
              autoPlay: list.length > 1,
              height: 132,
              viewportFraction: 1.0,
              padEnds: false,
              enlargeCenterPage: false,
              initialPage: 0,
              enableInfiniteScroll: list.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 700),
              autoPlayCurve: Curves.easeOutCubic,
              onPageChanged: (index, _) {
                if (!mounted) return;
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemCount: list.length,
            itemBuilder: (_, index, __) {
              return _agentCard(data: list[index], serial: index + 1);
            },
          ),
          // if (list.length > 1) ...[
          //   const SizedBox(height: 8),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(list.length, (index) {
          //       final active = _currentIndex == index;
          //       return AnimatedContainer(
          //         duration: const Duration(milliseconds: 220),
          //         margin: const EdgeInsets.symmetric(horizontal: 3),
          //         width: active ? 14 : 6,
          //         height: 6,
          //         decoration: BoxDecoration(
          //           color: active ? AppColors.onPrimary : AppColors.white24,
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //       );
          //     }),
          //   ),
          // ],
      
        ],
      );
    });
  }

  Widget _agentCard({required dynamic data, required int serial}) {
    final agentName = '${data['agent_name'] ?? ''}'.trim();
    final userId = '${data['user_id'] ?? ''}'.trim();
    final diamonds = '${data['diamonds'] ?? 0}';
    final topLabel = '${data['top'] ?? '-'}';
    final imageUrl = '${data['logo'] ?? ''}'.trim();
    final isAppOwner = data['is_app_owner'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102133), Color(0xFF174F62), Color(0xFF2F7D78)],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.white12,
                borderRadius: BorderRadius.circular(90),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                _buildAvatar(imageUrl: imageUrl, serial: serial),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        agentName.isEmpty ? 'Unknown Agent' : agentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $userId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Image.asset('assets/others/diamond.png', height: 16),
                          const SizedBox(width: 5),
                          Text(
                            diamonds,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          if (isAppOwner) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.65),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Owner',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildTopPill(topLabel: topLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required String imageUrl, required int serial}) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(width: 2, color: AppColors.onPrimary),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: imageUrl.isEmpty
                  ? Container(
                      color: AppColors.black26,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.onPrimary,
                        size: 28,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.black26,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.onPrimary,
                          size: 28,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.onPrimary, width: 1.2),
              ),
              child: Text(
                '$serial',
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TOP',
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            topLabel,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
