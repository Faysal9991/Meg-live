import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_neumorphic_styles.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.minWidth = 48,
    this.minHeight = 48,
    this.iconColor = AppColors.textPrimary,
    this.backgroundColor,
    this.tooltip,
    this.depth = AppNeumorphicStyles.controlDepth,
  });
  final IconData icon;
  final double iconSize, minWidth, minHeight;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color? backgroundColor;
  final String? tooltip;
  final double depth;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(6),
    child: NeumorphicIconButton(
      icon: icon,
      depth: depth,
      iconSize: iconSize,
      onPressed: onPressed,
      iconColor: iconColor,
      backgroundColor: backgroundColor ?? AppColors.surface,
      size: minWidth > minHeight ? minWidth : minHeight,
      tooltip:
          tooltip ??
          (icon == Icons.close || icon == Icons.close_outlined
              ? 'Close'
              : icon == Icons.share
              ? 'Share'
              : icon == Icons.send
              ? 'Send'
              : null),
    ),
  );
}
