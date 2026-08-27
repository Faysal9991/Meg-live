import 'package:flutter/material.dart';

/// The single source of truth for colors used throughout the application.
///
/// Prefer the semantic names in this class over framework color constants so
/// that every screen responds consistently to future brand updates.
abstract final class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFFF4F7FB);
  static const Color accent = Color(0xFF0A797B);

  // Primary variants
  static const Color primaryDark = Color(0xFF083875);
  static const Color primaryLight = Color(0xFF4B7AC1);
  static const Color primarySoft = Color(0xFFE8EFF9);

  // Accent variants
  static const Color accentDark = Color(0xFF075C5E);
  static const Color accentLight = Color(0xFF3F9698);
  static const Color accentSoft = Color(0xFFE5F2F2);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textHint = Color(0xFF98A2B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Borders and dividers
  static const Color border = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFEAECF0);

  // Status
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFD92D20);
  static const Color info = Color(0xFF2E90FA);

  // Disabled
  static const Color disabled = Color(0xFFD0D5DD);
  static const Color disabledBackground = Color(0xFFF2F4F7);

  // Media and modal overlays. These remain neutral to keep controls readable
  // over photos and live video, independent of the brand theme.
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayMedium = Color(0x42000000);
  static const Color overlayStrong = Color(0x73000000);
  static const Color onMedia = Color(0xFFFFFFFF);
  static const Color onMediaMuted = Color(0xB3FFFFFF);
  static const Color onMediaSubtle = Color(0x3DFFFFFF);

  // Premium content is intentionally distinct from operational statuses.
  static const Color premium = Color(0xFFF5B700);

  // Backwards-compatible semantic aliases used by older widgets.
  static const Color onPrimary = textOnPrimary;
  static const Color primaryContainer = primarySoft;
  static const Color scaffoldBackground = background;
  static const Color surfaceVariant = disabledBackground;
  static const Color textMuted = textHint;
  static const Color danger = error;
  static const Color black12 = overlayLight;
  static const Color black26 = overlayMedium;
  static const Color black38 = overlay;
  static const Color black45 = overlayStrong;
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white24 = onMediaSubtle;
  static const Color white70 = onMediaMuted;
}
