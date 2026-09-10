import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A compact, consistent action used on top of live video.
///
/// The visible control stays intentionally quiet so it does not compete with
/// the stream, while the tooltip and semantic label keep the action clear.
class LiveRoomIconButton extends StatelessWidget {
  const LiveRoomIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor = AppColors.onMedia,
    this.backgroundColor = AppColors.overlayStrong,
    this.size = 40,
    this.iconSize = 19,
    this.showBorder = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: size,
          child: Material(
            color: backgroundColor,
            shape: CircleBorder(
              side: showBorder
                  ? const BorderSide(color: AppColors.white24, width: 1)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
