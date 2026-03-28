import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeLocation = '/';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.brandPurple.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(
                AppIcons.store, // Using store icon as logo placeholder
                size: 64,
                color: AppColors.brandPurple,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Text
            Text(
                  'GEBEYA',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPurple,
                    letterSpacing: 4,
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .moveY(begin: 10, end: 0, duration: 600.ms, curve: Curves.easeOut),

            Text(
                  'MERCHANT',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: muted,
                    letterSpacing: 6,
                  ),
                )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .moveY(begin: 10, end: 0, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 48),

            // Loading Indicator
            const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPurple),
                )
                .animate(delay: 800.ms) // Delay showing loader
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
