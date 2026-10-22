import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_surface_styles.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Flat surface around native Material controls preserves keyboard, focus,
/// disabled, ink, and accessibility behavior.
class _ControlSurface extends StatefulWidget {
  const _ControlSurface({
    required this.builder,
    required this.enabled,
    required this.color,
    required this.radius,
    this.circle = false,
  });
  final Widget Function(WidgetStatesController) builder;
  final bool enabled;
  final Color color;
  final double radius;
  final bool circle;

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
              : AppSurfaceStyles.duration,
          curve: Curves.easeOutCubic,
          decoration: AppSurfaceStyles.decoration(
            color: widget.enabled ? widget.color : AppColors.disabledBackground,
            radius: widget.radius,
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          ),
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
            : AppColors.onLight);
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


class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    this.icon,
    this.image,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconSize = 21,
    this.iconColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.surfaceHigh,
    this.imageFit = BoxFit.cover,
    this.imagePadding = 0,
  }) : assert(
         icon != null || image != null,
         'Either icon or image must be provided.',
       );

  final IconData? icon;
  final ImageProvider? image;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final BoxFit imageFit;
  final double imagePadding;

  @override
  Widget build(BuildContext context) {
    final dimension = size < 48 ? 48.0 : size;

    final button = SizedBox.square(
      dimension: dimension,
      child: _ControlSurface(
        enabled: onPressed != null,
        color: backgroundColor,
        radius: AppRadius.pill,
        circle: true,
        builder: (states) {
          return TextButton(
            statesController: states,
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: iconColor,
              disabledForegroundColor: AppColors.disabled,
              disabledBackgroundColor: AppColors.disabledBackground,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const BorderSide(
                        color: AppColors.pinkLight,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
            ),
            child: image != null
                ? Padding(
                    padding: EdgeInsets.all(imagePadding),
                    child: ClipOval(
                      child: Image(
                        image: image!,
                        width: dimension - imagePadding * 2,
                        height: dimension - imagePadding * 2,
                        fit: imageFit,
                      ),
                    ),
                  )
                : Icon(icon, size: iconSize),
          );
        },
      ),
    );

    return tooltip == null
        ? button
        : Tooltip(message: tooltip!, child: button);
  }
}

/// The standard surface for lists, panels, packages, and navigation.
/// A Material child keeps InkWell feedback visible inside the flat shell.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color = AppColors.card,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
    this.elevation = 1,
    this.surfaceTintColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  /// Any positive value draws a hairline border; zero renders borderless.
  final double elevation;
  final Color? surfaceTintColor;

  @override
  Widget build(BuildContext context) {
    final resolvedShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: elevation <= 0
              ? BorderSide.none
              : const BorderSide(color: AppColors.divider),
        );
    return Padding(
      padding: margin,
      child: Material(
        color: color ?? AppColors.card,
        shape: resolvedShape,
        clipBehavior: clipBehavior,
        child: Padding(padding: padding, child: child),
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: AppSurfaceStyles.decoration(color: color, radius: radius),
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
