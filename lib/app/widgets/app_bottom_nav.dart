import 'dart:ui';

import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The floating navigation bar shared with the max_Live design.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: 353,
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.55),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.surface.withValues(alpha: 0.82),
                      ),
                    ),
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    Row(
                      children: [
                        _navItem(
                          icon: 'assets/navbar/home.svg',
                          label: 'Home',
                          index: STREAMING_LIST,
                        ),
                        _navItem(
                          icon: 'assets/navbar/video.svg',
                          label: 'Live',
                          index: LIVE_STREAM,
                        ),
                        _navItem(
                          icon: 'assets/navbar/message.svg',
                          label: 'Chat',
                          index: CHATS,
                        ),
                        _navItem(
                          icon: 'assets/navbar/profile.svg',
                          label: 'Profile',
                          index: PROFILE,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required String icon,
    required String label,
    required int index,
  }) {
    final isActive = selectedIndex == index;
    final svg = SvgPicture.asset(
      icon,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      excludeFromSemantics: true,
    );

    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: isActive,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isActive ? null : () => onTap(index),
          child: Center(
            child: isActive
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.gradientPrimary,
                      ),
                    ),
                    child: Center(child: svg),
                  )
                : svg,
          ),
        ),
      ),
    );
  }
}
