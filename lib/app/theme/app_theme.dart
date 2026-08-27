import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_text_theme.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class AppTheme {
  const AppTheme._();

  static final NeumorphicThemeData neumorphicTheme = NeumorphicThemeData(
    baseColor: AppColors.secondary,
    accentColor: AppColors.accent,
    variantColor: AppColors.primarySoft,
    disabledColor: AppColors.disabled,
    defaultTextColor: AppColors.textPrimary,
    depth: 3,
    intensity: 0.6,
    lightSource: LightSource.topLeft,
    shadowLightColor: AppColors.surface,
    shadowDarkColor: AppColors.overlayLight,
    shadowLightColorEmboss: AppColors.surface,
    shadowDarkColorEmboss: AppColors.overlayLight,
    borderColor: AppColors.border,
    boxShape: NeumorphicBoxShape.roundRect(
      BorderRadius.all(Radius.circular(AppRadius.button)),
    ),
  );

  static final ColorScheme _lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primarySoft,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnAccent,
        secondaryContainer: AppColors.accentSoft,
        onSecondaryContainer: AppColors.accentDark,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        shadow: AppColors.overlay,
        scrim: AppColors.overlay,
      );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: _lightColorScheme,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    disabledColor: AppColors.disabled,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: AppTextTheme.lightTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      actionsIconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      titleTextStyle: AppTextTheme.lightTextTheme.titleLarge,
      contentTextStyle: AppTextTheme.lightTextTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: AppColors.overlay,
      showDragHandle: true,
      dragHandleColor: AppColors.disabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textSecondary,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        );
      }),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.divider,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnAccent,
      elevation: 3,
      focusColor: AppColors.accentLight,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: AppColors.accentLight,
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.disabled)
              ? AppColors.disabledBackground
              : AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.disabled)
              ? AppColors.disabled
              : AppColors.textOnPrimary;
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.primaryLight),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 54)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.disabled)
              ? AppColors.disabledBackground
              : AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.disabled)
              ? AppColors.disabled
              : AppColors.textOnPrimary;
        }),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        overlayColor: const WidgetStatePropertyAll(AppColors.primarySoft),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      helperStyle: const TextStyle(color: AppColors.textSecondary),
      errorStyle: const TextStyle(color: AppColors.error),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.disabled),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.disabled;
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.textOnPrimary),
      side: const BorderSide(color: AppColors.border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? AppColors.disabled
            : AppColors.primary;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.textOnAccent
            : AppColors.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.disabledBackground;
        }
        return states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.disabled;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.accentSoft,
      circularTrackColor: AppColors.accentSoft,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primarySoft,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.disabledBackground,
      labelStyle: const TextStyle(color: AppColors.primaryDark),
      secondaryLabelStyle: const TextStyle(color: AppColors.textOnPrimary),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      selectedColor: AppColors.primary,
      selectedTileColor: AppColors.primarySoft,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: AppColors.textOnPrimary),
    ),
  );
}
