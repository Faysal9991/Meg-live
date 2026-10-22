import 'package:flutter/material.dart';

/// Neon Night brand palette for Ringo Live.
///
/// Violet carries primary actions and selection. Magenta adds live energy,
/// while cyan and gold identify audio and premium content. Most of the screen
/// stays on the layered night surfaces so the accents remain intentional.
abstract final class AppColors {
  // Palette
  static const Color lavender = Color(0xFFC9A4FF);
  static const Color amethyst = Color(0xFF9B5CFF);
  static const Color royalPurple = Color(0xFF6D3BD6);
  static const Color deepViolet = Color(0xFF3D296A);
  static const Color midnight = Color(0xFF221A45);
  static const Color night = Color(0xFF0D0B1E);

  static const Color magenta = Color(0xFFFF3D9A);
  static const Color magentaDark = Color(0xFFD61F78);
  static const Color magentaLight = Color(0xFFFF7AB8);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color gold = Color(0xFFFFC94D);

  // Brand
  static const Color primary = Color(0xFF8146DB);
  static const Color primaryDark = royalPurple;
  static const Color primaryLight = lavender;
  static const Color primarySoft = Color(0x338146DB);
  static const Color secondary = magenta;
  static const Color secondaryDark = magentaDark;
  static const Color secondaryLight = magentaLight;
  static const Color secondarySoft = Color(0x33FF3D9A);

  // Surfaces
  static const Color bg = night;
  static const Color background = night;
  static const Color surface = Color(0xFF17132E);
  static const Color surfaceElevated = midnight;
  static const Color surfaceHigh = Color(0xFF2E2558);
  static const Color border = Color(0xFF2C2454);
  static const Color borderLight = Color(0xFF443875);
  static const Color divider = Color(0xFF231D42);

  // Text
  static const Color textPrimary = Color(0xFFF7F4FC);
  static const Color textSecondary = Color(0xFFB3ABCF);
  static const Color textTertiary = Color(0xFF8F87AD);
  static const Color textHint = textTertiary;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = night;

  // Status and live features
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF2557A);
  static const Color info = Color(0xFF60A5FA);
  static const Color liveRed = Color(0xFFFF2E63);
  static const Color liveGlow = Color(0x40FF2E63);
  static const Color giftGold = gold;
  static const Color giftGlow = Color(0x33FFC94D);
  static const Color superChat = Color(0xFFFFD976);
  static const Color heartAccent = magenta;

  // Glow and overlays
  static const Color glow = Color(0x669B5CFF);
  static const Color glowSoft = Color(0x33C9A4FF);
  static const Color chatBubble = Color(0x66000000);
  static const Color overlayChip = Color(0x73000000);
  static const Color mediaBackground = Color(0xFF0A0612);
  static const Color onMedia = Color(0xFFFFFFFF);
  static const Color onMediaMuted = Color(0xB3FFFFFF);
  static const Color onMediaSubtle = Color(0x3DFFFFFF);
  static const Color overlay = Color(0x99000000);
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayMedium = Color(0x42000000);
  static const Color overlayStrong = overlayChip;
  static const Color transparent = Color(0x00000000);
  static const Color onLight = night;

  // Gradients
  static const List<Color> gradientPrimary = [Color(0xFFC92772), primary];
  static const List<Color> gradientSecondary = [
    Color(0xFF7542C8),
    Color(0xFF3C62C8),
  ];
  static const List<Color> gradientLive = [
    Color(0xFFC8234B),
    Color(0xFFC92772),
  ];
  static const List<Color> gradientGold = [
    Color(0xFFFFE08A),
    gold,
    Color(0xFFF59E0B),
  ];
  static const List<Color> gradientDark = [midnight, night, night];
  static const List<Color> gradientCard = [Color(0xFF2A2152), surface];

  // Existing semantic names retained for current widgets.
  static const Color pink = magenta;
  static const Color pinkLight = magentaLight;
  static const Color violet = amethyst;
  static const Color accent = amethyst;
  static const Color accentDark = royalPurple;
  static const Color accentLight = lavender;
  static const Color accentSoft = Color(0x339B5CFF);
  static const Color textOnAccent = textOnPrimary;
  static const Color card = surface;
  static const Color surfaceInset = surfaceElevated;
  static const Color surfaceHighlight = surfaceHigh;
  static const Color disabled = textTertiary;
  static const Color disabledBackground = surfaceHigh;
  static const Color premium = gold;
  static const Color premiumText = gold;
  static const Color premiumSoft = Color(0x26FFC94D);
  static const Color agentBannerStart = amethyst;
  static const Color agentBannerMiddle = Color(0xFFB4308F);
  static const Color agentBannerEnd = magenta;
  static const Color onPrimary = textOnPrimary;
  static const Color primaryContainer = primarySoft;
  static const Color scaffoldBackground = bg;
  static const Color surfaceVariant = surfaceHigh;
  static const Color textMuted = textHint;
  static const Color danger = error;
  static const Color black12 = overlayLight;
  static const Color black26 = overlayMedium;
  static const Color black38 = overlay;
  static const Color black45 = overlayStrong;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white24 = onMediaSubtle;
  static const Color white70 = onMediaMuted;
}

abstract final class AppGradients {
  /// Hero action gradient from magenta into the primary violet.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: AppColors.gradientPrimary,
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: AppColors.gradientSecondary,
  );

  /// VIP badge and top-gifter frame.
  static const LinearGradient vip = LinearGradient(
    colors: AppColors.gradientGold,
  );

  static const LinearGradient live = LinearGradient(
    colors: AppColors.gradientLive,
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientCard,
  );

  /// Video scrims keep labels readable over bright frames.
  static const LinearGradient videoBottomScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x99000000)],
  );

  static const LinearGradient videoTopScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0x00000000), Color(0x66000000)],
  );
}
