import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

typedef _RankedProfile = ({TopHost profile, int rank});

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({
    super.key,
    required this.controller,
    this.currentUserId,
  });

  final LiveStreamingController controller;
  final int? currentUserId;

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  static const _toolbarHeight = 60.0;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadMissingRankings());
  }

  Future<void> _refresh() => widget.controller.loadMissingRankings();

  String _displayName(TopHost profile) =>
      profile.uid == widget.currentUserId ? 'You' : profile.fullName;

  String _metric(TopHost profile) =>
      (_selectedTab == 0 ? profile.giftDiamonds : profile.diamondsContributed)
          .toString();

  String? _levelLabel(TopHost profile) {
    final level = profile.level;
    final number = level is Map ? int.tryParse('${level['level']}') : null;
    return number == null ? null : 'Lv $number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: _toolbarHeight,
        centerTitle: true,
        leadingWidth: 64,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
        title: const Text(
          'Top Ranking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabSwitcher(),
              const SizedBox(height: 20),
              Expanded(child: Obx(_buildContent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _buildTab('Top Hosts', 0),
            _buildTab('Top Contributors', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selectedTab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                child: Text(label, maxLines: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;
    final profiles = _selectedTab == 0
        ? controller.topHostList
        : controller.topContributorList;
    final type = _selectedTab == 0 ? TOP_HOSTS_UPDATE : TOP_CONTRIBUTORS_UPDATE;
    final loading =
        controller.isRankingLoading(type) ||
        (_selectedTab == 0
            ? controller.loadingTopHostList.value
            : controller.loadingTopContributorList.value);
    final reconnecting = controller.isRankingReconnecting(type);

    if (loading && profiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = [
      for (var index = 0; index < profiles.length; index++)
        (
          profile: profiles[index],
          rank: profiles[index].rank > 0 ? profiles[index].rank : index + 1,
        ),
    ];
    final podium = entries.where((entry) => entry.rank <= 3).toList()
      ..sort((a, b) {
        const order = {2: 0, 1: 1, 3: 2};
        return order[a.rank]!.compareTo(order[b.rank]!);
      });
    final rankedList = entries.where((entry) => entry.rank > 3).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        key: PageStorageKey(_selectedTab),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (reconnecting)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Reconnecting…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (entries.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No rankings yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          if (podium.isNotEmpty)
            SliverToBoxAdapter(child: _buildPodium(podium)),
          if (podium.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverList.builder(
            itemCount: rankedList.length,
            itemBuilder: (_, index) => _buildRankedRow(rankedList[index]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // Extra space lets podium labels grow with the system text size.
  double get _podiumExtraHeight =>
      16 + math.max(0, MediaQuery.textScalerOf(context).scale(14) - 14) * 4;

  Widget _buildPodium(List<_RankedProfile> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 260 + _podiumExtraHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final entry in entries)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildPodiumItem(entry),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(_RankedProfile entry) {
    final rank = entry.rank;
    final avatarRadius = rank == 1 ? 44.0 : 36.0;
    final pedestalHeight = (rank == 1 ? 130.0 : 100.0) + _podiumExtraHeight;
    final ringColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFF5B8DEF),
      _ => const Color(0xFF4CAF50),
    };

    return SizedBox(
      key: ValueKey('podium-$rank'),
      height: pedestalHeight + avatarRadius + (rank == 1 ? 30 : 6),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: pedestalHeight,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.secondaryDark : AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: EdgeInsets.only(top: avatarRadius + 10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _displayName(entry.profile),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rank == 1 ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond_outlined,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _metric(entry.profile),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_levelLabel(entry.profile) case final label?)
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: rank == 1 ? 24 : 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 3),
                    color: Colors.white,
                  ),
                  child: _buildAvatar(entry.profile, avatarRadius),
                ),
                Positioned(
                  bottom: -5,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: ringColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: FittedBox(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (rank == 1)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'assets/others/leaderboard_crown.svg',
                  height: 40,
                  width: 40,
                  excludeFromSemantics: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankedRow(_RankedProfile entry) {
    final isYou = entry.profile.uid == widget.currentUserId;
    return Container(
      key: ValueKey('ranking-${entry.rank}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isYou
            ? const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              )
            : null,
        color: isYou ? null : AppColors.surface,
        border: isYou ? null : Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isYou ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildAvatar(entry.profile, 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(entry.profile),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isYou ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (_levelLabel(entry.profile) case final label?)
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.3,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _metric(entry.profile),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isYou ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TopHost profile, double radius) {
    final imageUrl = profile.profileImage?.trim();
    final fallback = ColoredBox(
      color: AppColors.surfaceElevated,
      child: Icon(Icons.person, size: radius, color: AppColors.secondaryDark),
    );
    return ClipOval(
      child: SizedBox.square(
        dimension: radius * 2,
        child: imageUrl == null || imageUrl.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
