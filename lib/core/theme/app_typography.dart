import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Color high, Color mid) {
    final sora = GoogleFonts.soraTextTheme();
    final inter = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: sora.displayLarge?.copyWith(
        fontSize: 40, fontWeight: FontWeight.w700,
        letterSpacing: -1.2, color: high,
      ),
      displayMedium: sora.displayMedium?.copyWith(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -0.8, color: high,
      ),
      headlineSmall: sora.headlineSmall?.copyWith(
        fontSize: 20, fontWeight: FontWeight.w600,
        letterSpacing: -0.3, color: high,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontSize: 15, fontWeight: FontWeight.w600, color: high,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14.5, height: 1.55, color: mid,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 12.5, color: mid, letterSpacing: 0.1,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 11, letterSpacing: 1.2,
        fontWeight: FontWeight.w600, color: mid,
      ),
    );
  }
}