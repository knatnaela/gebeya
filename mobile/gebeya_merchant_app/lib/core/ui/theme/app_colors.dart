import 'package:flutter/material.dart';

/// Design tokens for the Gebeya Merchant app.
///
/// These values are derived from `FLUTTER_UI_UX_STYLE_GUIDE.md` and should be
/// the single source of truth for shared colors.
abstract final class AppColors {
  // Brand
  static const Color brandPurple = Color(0xFF7C3AED);
  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandGreen = Color(0xFF10B981);
  static const Color brandRed = Color(0xFFDC2626);

  // Semantic (light)
  static const Color lightBackground = Color(0xFFF9FAFB); // Slightly off-white for better contrast
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111827);
  static const Color lightMutedText = Color(0xFF6B7280);
  static const Color lightOutline = Color(0xFFE5E7EB);
  static const Color lightError = Color(0xFFDC2626);

  // Semantic (dark)
  static const Color darkBackground = Color(0xFF030712); // Deep rich black/blue
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkMutedText = Color(0xFF9CA3AF);
  static const Color darkOutline = Color(0xFF374151);
  static const Color darkError = Color(0xFFEF4444);

  // Glassmorphism & Overlays
  static final Color glassWhite = Colors.white.withValues(alpha: 0.7);
  static final Color glassBlack = Colors.black.withValues(alpha: 0.7);

  // Auth background tints (soft gradient)
  static const Color authTintPurple = Color(0xFFF3E8FF); // ~ purple-50
  static const Color authTintBlue = Color(0xFFEFF6FF); // ~ blue-50

  // Card background tints (for KPI cards)
  static const Color cardTintPurple = Color(0xFFF5F3FF); // ~ purple-50 (lighter)
  static const Color cardTintBlue = Color(0xFFEFF6FF); // ~ blue-50
  static const Color cardTintGreen = Color(0xFFF0FDF4); // ~ green-50
  static const Color cardTintOrange = Color(0xFFFFF7ED); // ~ orange-50
  static const Color cardTintRed = Color(0xFFFEF2F2); // ~ red-50
  static const Color cardTintNeutral = Color(0xFFF9FAFB); // ~ gray-50

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPurple, brandBlue],
  );

  static const LinearGradient brandGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF1E40AF)], // Darker for deep mode
  );

  static const LinearGradient authBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [authTintPurple, authTintBlue],
  );
}
