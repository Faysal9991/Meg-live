import 'package:flutter/material.dart';

/// Live streaming palette — dark-first, 60 / 30 / 10.
///
/// * 60% [bg], 30% [surface] / [surfaceHigh], max 10% brand.
/// * Pink/violet only for CTAs, Go Live and selected states.
/// * Feature colors: video live = [pink], audio live = [cyan],
///   gift / coin / VIP = [gold], LIVE badge = [liveRed].
/// * [cyan], [gold], [success], [warning] and [error] always take [onLight]
///   text. [violet] is never used for small text.
///
/// Contrast ratios (WCAG 2.1) are measured against [bg] unless noted.
abstract final class AppColors {
  // ── Base (60% bg / 30% surface) ──────────────────────────────
  static const Color bg = Color(0xFF120C1F); // Night plum — scaffold
  static const Color surface = Color(0xFF1D1530); // cards, sheets, nav bar
  static const Color surfaceHigh = Color(0xFF2A2042); // inputs, chips, dialogs
  static const Color border = Color(0xFF3A2E57);

  // ── Brand (max 10% of screen) ────────────────────────────────
  static const Color pink = Color(0xFFE0246A); // fills — white text 4.5:1
  static const Color pinkLight = Color(0xFFFF5C93); // pink text/icons — 6.6:1
  static const Color violet = Color(0xFF8A3FFC); // gradient end, never small text

  // ── Feature colors ───────────────────────────────────────────
  static const Color cyan = Color(0xFF2EE6D6); // audio live, PK team B
  static const Color gold = Color(0xFFFFC93C); // coins, gifts, VIP
  static const Color liveRed = Color(0xFFE8173A); // LIVE badge only

  // ── Status ───────────────────────────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFF9F43);
  static const Color error = Color(0xFFFF5470); // 6.1:1
  static const Color info = Color(0xFF7AA7FF);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF); // 19:1
  static const Color textSecondary = Color(0xFFC9BFE0); // 10.9:1
  static const Color textHint = Color(0xFF8B80A6); // 5.2:1, bg/surface only
  static const Color onLight = Color(0xFF120C1F); // on cyan/gold/status fills

  // ── Over live video ──────────────────────────────────────────
  static const Color chatBubble = Color(0x66000000); // 40% black per comment
  static const Color overlayChip = Color(0x73000000); // viewer count, timers
  static const Color mediaBackground = Color(0xFF0A0612);
  static const Color onMedia = Color(0xFFFFFFFF);
  static const Color onMediaMuted = Color(0xB3FFFFFF);
  static const Color onMediaSubtle = Color(0x3DFFFFFF);

  // ── Modal overlays ───────────────────────────────────────────
  static const Color overlay = Color(0x99000000);
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayMedium = Color(0x42000000);
  static const Color overlayStrong = overlayChip;
  static const Color transparent = Color(0x00000000);

  // ── Semantic roles (map older call sites onto the palette) ───
  static const Color primary = pink;
  static const Color primaryDark = Color(0xFFB81A55);
  static const Color primaryLight = pinkLight;
  static const Color primarySoft = Color(0x2EE0246A); // 18% pink — selected bg
  static const Color textOnPrimary = textPrimary;

  static const Color accent = violet;
  static const Color accentDark = Color(0xFF6A2BD0);
  static const Color accentLight = Color(0xFFB18CFF);
  static const Color accentSoft = Color(0x2E8A3FFC);
  static const Color textOnAccent = textPrimary;

  static const Color secondary = bg;
  static const Color background = bg;
  static const Color card = surface;
  static const Color surfaceInset = surfaceHigh;
  static const Color surfaceHighlight = surfaceHigh;
  static const Color divider = border;

  static const Color disabled = textHint;
  static const Color disabledBackground = surfaceHigh;

  static const Color premium = gold;
  static const Color premiumText = gold;
  static const Color premiumSoft = Color(0x26FFC93C);

  static const Color agentBannerStart = violet;
  static const Color agentBannerMiddle = Color(0xFFB4308F);
  static const Color agentBannerEnd = pink;

  // Backwards-compatible aliases used by older widgets.
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
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white24 = onMediaSubtle;
  static const Color white70 = onMediaMuted;
}

abstract final class AppGradients {
  /// Primary CTA, Go Live button, selected tab indicator.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.pink, AppColors.violet],
  );

  /// VIP badge, top-gifter frame.
  static const LinearGradient vip = LinearGradient(
    colors: [Color(0xFFFFE08A), AppColors.gold, Color(0xFFF5A524)],
  );

  /// Bottom of video — keeps chat readable on bright frames.
  static const LinearGradient videoBottomScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x99000000)],
  );

  /// Top of video — keeps host name / LIVE badge readable.
  static const LinearGradient videoTopScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0x00000000), Color(0x66000000)],
  );
}
