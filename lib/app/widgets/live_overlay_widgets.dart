import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

const List<Shadow> _mediaTextShadow = [
  Shadow(color: Color(0x80000000), blurRadius: 3),
];

/// Chat comment over live video — readable on any video frame.
class LiveChatBubble extends StatelessWidget {
  const LiveChatBubble({
    super.key,
    required this.name,
    required this.message,
    this.nameColor = AppColors.pinkLight,
    this.leading,
  });

  final String name;
  final String message;
  final Color nameColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.chatBubble,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          if (leading != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: leading,
              ),
            ),
          TextSpan(
            text: '$name  ',
            style: TextStyle(
              color: nameColor,
              fontWeight: FontWeight.w700,
              shadows: _mediaTextShadow,
            ),
          ),
          TextSpan(
            text: message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              shadows: _mediaTextShadow,
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 13, height: 1.3),
    ),
  );
}

/// LIVE badge — the only place [AppColors.liveRed] is used.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.label = 'LIVE'});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.liveRed,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
  );
}

/// Semi-transparent chip for viewer counts, timers and host info over video.
class LiveOverlayChip extends StatelessWidget {
  const LiveOverlayChip({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.overlayChip,
      borderRadius: BorderRadius.circular(999),
    ),
    child: DefaultTextStyle.merge(
      style: const TextStyle(
        color: AppColors.onMedia,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        shadows: _mediaTextShadow,
      ),
      child: IconTheme.merge(
        data: const IconThemeData(color: AppColors.onMedia, size: 14),
        child: child,
      ),
    ),
  );
}

/// Top and bottom scrims over live video so overlays stay readable.
class LiveVideoScrims extends StatelessWidget {
  const LiveVideoScrims({
    super.key,
    this.topHeight = 140,
    this.bottomHeight = 320,
  });

  final double topHeight;
  final double bottomHeight;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topHeight,
          child: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.videoTopScrim),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: bottomHeight,
          child: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.videoBottomScrim),
          ),
        ),
      ],
    ),
  );
}
