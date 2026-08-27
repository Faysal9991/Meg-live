import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_neumorphic_styles.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_spacing.dart';
import 'package:doyel_live/app/theme/app_text_styles.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor,
    this.fixedSize,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = AppRadius.button,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Size? fixedSize;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final resolvedForeground =
        foregroundColor ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.dark
            ? AppColors.textOnPrimary
            : AppColors.textPrimary);
    final style = FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: resolvedForeground,
      fixedSize: fixedSize,
      minimumSize: fixedSize == null ? Size(0, compact ? 40 : 54) : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.lg,
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: AppTextStyles.button.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: resolvedForeground,
      ),
    );

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, color: resolvedForeground),
        label: Text(label),
      );
    }
    return FilledButton(onPressed: onPressed, style: style, child: Text(label));
  }
}

class NeumorphicIconButton extends StatelessWidget {
  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 42,
    this.iconSize = 21,
    this.iconColor = AppColors.primary,
    this.backgroundColor = AppColors.secondary,
    this.depth = 3,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox.square(
      dimension: size,
      child: NeumorphicButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: AppNeumorphicStyles.circle(
          color: backgroundColor,
          depth: onPressed == null ? 0 : depth,
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null ? AppColors.disabled : iconColor,
          ),
        ),
      ),
    );
    return Semantics(button: true, label: tooltip, child: button);
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.focusNode,
    this.readOnly = false,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final bool readOnly;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: AppNeumorphicStyles.inset(),
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}
