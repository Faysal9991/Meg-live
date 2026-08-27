import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

/// Restrained neumorphic styles for small interactive utility surfaces.
abstract final class AppNeumorphicStyles {
  static NeumorphicStyle raised({
    Color color = AppColors.secondary,
    double depth = 3,
    double radius = AppRadius.button,
  }) {
    return NeumorphicStyle(
      color: color,
      depth: depth,
      intensity: 0.6,
      lightSource: LightSource.topLeft,
      shadowLightColor: AppColors.surface,
      shadowDarkColor: AppColors.overlayLight,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
    );
  }

  static NeumorphicStyle inset({
    Color color = AppColors.secondary,
    double depth = -2,
    double radius = AppRadius.button,
  }) {
    return NeumorphicStyle(
      color: color,
      depth: depth,
      intensity: 0.45,
      lightSource: LightSource.topLeft,
      shadowLightColorEmboss: AppColors.surface,
      shadowDarkColorEmboss: AppColors.overlayLight,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
    );
  }

  static NeumorphicStyle circle({
    Color color = AppColors.secondary,
    double depth = 3,
  }) {
    return NeumorphicStyle(
      color: color,
      depth: depth,
      intensity: 0.55,
      lightSource: LightSource.topLeft,
      shadowLightColor: AppColors.surface,
      shadowDarkColor: AppColors.overlayLight,
      boxShape: const NeumorphicBoxShape.circle(),
    );
  }
}
