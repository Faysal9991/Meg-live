import 'package:flutter/material.dart';

/// The single source of truth for colors used throughout the application.
///
/// Prefer the semantic names in this class over framework color constants so
/// that every screen responds consistently to future brand updates.
abstract final class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF3156A6);
  static const Color secondary = background;
  static const Color accent = Color(0xFF087479);

  // Primary variants
  static const Color primaryDark = Color(0xFF213D7A);
  static const Color primaryLight = Color(0xFF6686C4);
  static const Color primarySoft = Color(0xFFDDE6F6);

  // Accent variants
  static const Color accentDark = Color(0xFF075C61);
  static const Color accentLight = Color(0xFF52A4A7);
  static const Color accentSoft = Color(0xFFDCEFED);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFE9EEF5);
  static const Color surface = background;
  static const Color card = surface;
  static const Color surfaceInset = Color(0xFFE3EAF3);
  static const Color surfaceHighlight = Color(0xFFF4F7FB);
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0xFFBCC9DB);
  static const Color mediaBackground = Color(0xFF101827);
  static const Color transparent = Color(0x00000000);

  // Text
  static const Color textPrimary = Color(0xFF24334C);
  static const Color textSecondary = Color(0xFF56657B);
  static const Color textHint = Color(0xFF596980);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Borders and dividers
  static const Color border = Color(0xFFC9D3E1);
  static const Color divider = Color(0xFFD8E0EB);

  // Status
  static const Color success = Color(0xFF19734D);
  static const Color warning = Color(0xFF895800);
  static const Color error = Color(0xFFBB3444);
  static const Color info = Color(0xFF3156A6);

  // Disabled
  static const Color disabled = Color(0xFF758296);
  static const Color disabledBackground = Color(0xFFE0E6EF);

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
  static const Color premium = Color(0xFFE9B84A);
  static const Color premiumText = Color(0xFF785510);
  static const Color premiumSoft = Color(0xFFF1E9D7);

  // Agent ranking banner uses a vivid gradient with white foregrounds.
  static const Color agentBannerStart = Color(0xFF4338CA);
  static const Color agentBannerMiddle = Color(0xFF7C3AED);
  static const Color agentBannerEnd = Color(0xFFBE185D);

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
