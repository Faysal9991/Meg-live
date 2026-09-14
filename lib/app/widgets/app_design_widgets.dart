import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_neumorphic_styles.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_spacing.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

/// Soft depth around native Material controls preserves keyboard, focus,
/// disabled, ink, and accessibility behavior.
class _ControlSurface extends StatefulWidget {
  const _ControlSurface({
    required this.builder,
    required this.enabled,
    required this.color,
    required this.radius,
    this.circle = false,
    this.showShadow = true,
  });
  final Widget Function(WidgetStatesController) builder;
  final bool enabled;
  final Color color;
  final double radius;
  final bool circle;
  final bool showShadow;

  @override
  State<_ControlSurface> createState() => _ControlSurfaceState();
}

class _ControlSurfaceState extends State<_ControlSurface> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController({
      if (!widget.enabled) WidgetState.disabled,
    });
  }

  @override
  void didUpdateWidget(covariant _ControlSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, !widget.enabled);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Set<WidgetState>>(
        valueListenable: _states,
        builder: (context, states, _) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppNeumorphicStyles.duration,
          curve: Curves.easeOutCubic,
          decoration: AppNeumorphicStyles.decoration(
            color: widget.enabled ? widget.color : AppColors.disabledBackground,
            radius: widget.radius,
            enabled: widget.enabled,
            pressed: states.contains(WidgetState.pressed),
            compact: true,
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          ).copyWith(boxShadow: widget.showShadow ? null : const []),
          child: widget.builder(_states),
        ),
      );
}

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
    final foreground =
        foregroundColor ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.dark
            ? AppColors.textOnPrimary
            : AppColors.textPrimary);
    final style =
        FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabled,
          fixedSize: fixedSize,
          minimumSize: fixedSize == null ? Size(48, compact ? 48 : 54) : null,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ).copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? const BorderSide(color: AppColors.accentLight, width: 3)
                : BorderSide.none,
          ),
        );
    return _ControlSurface(
      color: backgroundColor,
      radius: borderRadius,
      enabled: onPressed != null,
      builder: (states) => icon == null
          ? FilledButton(
              statesController: states,
              onPressed: onPressed,
              style: style,
              child: Text(label),
            )
          : FilledButton.icon(
              statesController: states,
              onPressed: onPressed,
              style: style,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}

class NeumorphicIconButton extends StatelessWidget {
  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconSize = 21,
    this.iconColor = AppColors.primary,
    this.backgroundColor = AppColors.surface,
    this.depth = AppNeumorphicStyles.controlDepth,
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
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size < 48 ? 48 : size,
    child: _ControlSurface(
      enabled: onPressed != null,
      color: backgroundColor,
      radius: AppRadius.pill,
      circle: true,
      showShadow: depth != 0,
      builder: (states) {
        // TextButton exposes its state controller on Flutter 3.32 as well,
        // keeping the outer surface in sync with pointer and keyboard presses.
        final button = TextButton(
          statesController: states,
          onPressed: onPressed,
          style:
              TextButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: iconColor,
                disabledForegroundColor: AppColors.disabled,
                disabledBackgroundColor: AppColors.disabledBackground,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ).copyWith(
                side: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.focused)
                      ? const BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide.none,
                ),
              ),
          child: Icon(icon, size: iconSize),
        );
        return tooltip == null
            ? button
            : Tooltip(message: tooltip!, child: button);
      },
    ),
  );
}

/// The standard surface for lists, panels, packages, and navigation.
/// A Material child keeps InkWell feedback visible inside the soft shell.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color = AppColors.card,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
    this.elevation = AppNeumorphicStyles.cardDepth,
    this.surfaceTintColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final double elevation;
  final Color? surfaceTintColor;

  @override
  Widget build(BuildContext context) {
    final resolvedShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        );
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color ?? AppColors.card,
          shape: resolvedShape,
          shadows: elevation <= 0
              ? const []
              : AppNeumorphicStyles.raisedShadows,
        ),
        child: Material(
          color: color ?? AppColors.card,
          shape: resolvedShape,
          clipBehavior: clipBehavior,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppInsetSurface extends StatelessWidget {
  const AppInsetSurface({
    super.key,
    required this.child,
    this.color = AppColors.surfaceInset,
    this.radius = AppRadius.control,
  });
  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Neumorphic(
    style: AppNeumorphicStyles.inset(color: color, radius: radius),
    padding: EdgeInsets.zero,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppNeumorphicStyles.duration,
    child: Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(
          context,
        ).inputDecorationTheme.copyWith(fillColor: AppColors.transparent),
      ),
      child: child,
    ),
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
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
  Widget build(BuildContext context) => AppInsetSurface(
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        fillColor: AppColors.transparent,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    ),
  );
}
