import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:flutter/material.dart';

/// Flat surfaces and one motion language for the entire app.
abstract final class AppSurfaceStyles {
  static const duration = Duration(milliseconds: 180);

  static BoxDecoration decoration({
    Color color = AppColors.surface,
    double radius = AppRadius.card,
    bool focused = false,
    BoxShape shape = BoxShape.rectangle,
  }) => BoxDecoration(
    color: color,
    shape: shape,
    borderRadius: shape == BoxShape.rectangle
        ? BorderRadius.circular(radius)
        : null,
    border: focused ? Border.all(color: AppColors.primary, width: 2) : null,
  );
}
