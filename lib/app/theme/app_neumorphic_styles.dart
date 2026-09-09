import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

/// One light source, depth scale, and motion language for the entire app.
abstract final class AppNeumorphicStyles {
  static const duration = Duration(milliseconds: 180);
  static const double cardDepth = 5;
  static const double controlDepth = 3;
  static const double insetDepth = -2;
  static const double intensity = 0.75;
  static const lightSource = LightSource.topLeft;

  static const List<BoxShadow> raisedShadows = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(5, 5),
      blurRadius: 12,
    ),
  ];
  static const List<BoxShadow> controlShadows = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-3, -3),
      blurRadius: 7,
    ),
    BoxShadow(color: AppColors.shadowDark, offset: Offset(3, 3), blurRadius: 7),
  ];
  static const List<BoxShadow> pressedShadows = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-1, -1),
      blurRadius: 2,
    ),
    BoxShadow(color: AppColors.shadowDark, offset: Offset(1, 1), blurRadius: 2),
  ];

  static BoxDecoration decoration({
    Color color = AppColors.surface,
    double radius = AppRadius.card,
    bool pressed = false,
    bool enabled = true,
    bool focused = false,
    bool compact = false,
    BoxShape shape = BoxShape.rectangle,
  }) => BoxDecoration(
    color: color,
    shape: shape,
    borderRadius: shape == BoxShape.rectangle
        ? BorderRadius.circular(radius)
        : null,
    border: focused ? Border.all(color: AppColors.primary, width: 2) : null,
    boxShadow: !enabled
        ? const []
        : pressed
        ? pressedShadows
        : compact
        ? controlShadows
        : raisedShadows,
  );

  static NeumorphicStyle raised({
    Color color = AppColors.surface,
    double depth = cardDepth,
    double radius = AppRadius.card,
  }) => NeumorphicStyle(
    color: color,
    depth: depth,
    intensity: intensity,
    lightSource: lightSource,
    shadowLightColor: AppColors.shadowLight,
    shadowDarkColor: AppColors.shadowDark,
    shadowLightColorEmboss: AppColors.shadowLight,
    shadowDarkColorEmboss: AppColors.shadowDark,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  static NeumorphicStyle inset({
    Color color = AppColors.surfaceInset,
    double depth = insetDepth,
    double radius = AppRadius.control,
  }) => raised(color: color, depth: depth, radius: radius);

  static NeumorphicStyle circle({
    Color color = AppColors.surface,
    double depth = controlDepth,
  }) => raised(
    color: color,
    depth: depth,
  ).copyWith(boxShape: const NeumorphicBoxShape.circle());
}
