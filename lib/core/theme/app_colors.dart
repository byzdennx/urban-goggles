import 'package:flutter/material.dart';

/// Palette: Deep Ink → Amethyst → Cyan Aurora
/// Alasan: bukan gradient pastel generik, ada kontras gelap-terang
/// yang bikin glass effect terlihat "berisi".
class AppColors {
  // Base
  static const ink       = Color(0xFF070A14); // near-black navy
  static const inkSoft   = Color(0xFF0E1324);
  static const surface   = Color(0xFF141A2E);

  // Accents (berurutan sebagai gradient hidup)
  static const amethyst  = Color(0xFF8B5CF6);
  static const violet    = Color(0xFF6D5BFF);
  static const cyan      = Color(0xFF22D3EE);
  static const mint      = Color(0xFF5EEAD4);

  // Text
  static const textHigh  = Color(0xFFF5F7FF);
  static const textMid   = Color(0xFFB5BDD6);
  static const textLow   = Color(0xFF7A85A6);

  // Glass tints
  static const glassFill    = Color(0x14FFFFFF); // 8% white
  static const glassStroke  = Color(0x33FFFFFF);
  static const glassHighlight = Color(0x40FFFFFF);

  // Feedback
  static const danger    = Color(0xFFFF5A7A);
  static const success   = Color(0xFF4ADE80);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ink, Color(0xFF0B0F1E), Color(0xFF10142B)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, amethyst, cyan],
  );
}