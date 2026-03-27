import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const double radius = 16; // Increased radius for modern look
  static const double radiusSmall = 10;

  static ThemeData light() {
    const background = AppColors.lightBackground;
    const onBackground = AppColors.lightText;

    final scheme = ColorScheme.fromSeed(seedColor: AppColors.brandPurple, brightness: Brightness.light).copyWith(
      primary: AppColors.brandPurple,
      secondary: AppColors.brandBlue,
      error: AppColors.lightError,
      surface: AppColors.lightSurface,
      outline: AppColors.lightOutline,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: Color(0xFFF3F4F6), // light grey for inputs
    );

    return _base(scheme, background: background, onBackground: onBackground);
  }

  static ThemeData dark() {
    const background = AppColors.darkBackground;
    const onBackground = AppColors.darkText;

    final scheme = ColorScheme.fromSeed(seedColor: AppColors.brandPurple, brightness: Brightness.dark).copyWith(
      primary: AppColors.brandPurple,
      secondary: AppColors.brandBlue,
      error: AppColors.darkError,
      surface: AppColors.darkSurface,
      outline: AppColors.darkOutline,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: Color(0xFF1F2937), // dark grey for inputs
    );

    return _base(scheme, background: background, onBackground: onBackground);
  }

  static ThemeData _base(ColorScheme scheme, {required Color background, required Color onBackground}) {
    // Typography: Outfit for Headings, Inter for Body
    final baseTextTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final themedText = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.outfit(textStyle: baseTextTheme.displayLarge),
      displayMedium: GoogleFonts.outfit(textStyle: baseTextTheme.displayMedium),
      displaySmall: GoogleFonts.outfit(textStyle: baseTextTheme.displaySmall),
      headlineLarge: GoogleFonts.outfit(textStyle: baseTextTheme.headlineLarge),
      headlineMedium: GoogleFonts.outfit(textStyle: baseTextTheme.headlineMedium),
      headlineSmall: GoogleFonts.outfit(textStyle: baseTextTheme.headlineSmall),
      titleLarge: GoogleFonts.outfit(
        textStyle: baseTextTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      titleMedium: GoogleFonts.outfit(
        textStyle: baseTextTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      titleSmall: GoogleFonts.outfit(
        textStyle: baseTextTheme.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface.withValues(alpha: 0.6),
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: themedText,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: themedText.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0, // Using subtle border instead of shadow for base cards, or use custom shadows
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radius)),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest, // Grey background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusSmall)),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusSmall)),
          borderSide: BorderSide(color: Colors.transparent), // Transparent border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusSmall)),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusSmall)),
          borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
        ),
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Use finite min width — Size.fromHeight(52) is Size(infinity, 52) and breaks Row/ListView layouts.
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radiusSmall))),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radiusSmall))),
          side: BorderSide(color: scheme.outline),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radiusSmall))),
        backgroundColor: scheme.onSurface,
        contentTextStyle: TextStyle(color: scheme.surface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurface),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary);
          }
          return IconThemeData(color: scheme.onSurface.withValues(alpha: 0.6));
        }),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline.withValues(alpha: 0.5), space: 1, thickness: 1),
    );
  }
}
