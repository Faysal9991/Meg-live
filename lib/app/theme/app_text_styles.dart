import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Semantic typography for direct use outside of [ThemeData.textTheme].
abstract final class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}
