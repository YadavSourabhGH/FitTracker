import 'package:flutter/material.dart';

/// Semantic color tokens matching FitTrackr design system.
class AppColors {
  AppColors._();

  // Canvas & Surfaces (Warm Peach & Cream)
  static const Color scaffoldBase = Color(0xFFFFF8F5); // Warm cream canvas
  static const Color cardSurface = Color(0xFFFFFFFF);  // Pure white card
  static const Color surfaceContainerLow = Color(0xFFFBF2EE);
  static const Color surfaceContainer = Color(0xFFF5ECE8);
  static const Color surfaceContainerHigh = Color(0xFFF0E6E3);
  static const Color surfaceContainerHighest = Color(0xFFEAE1DD);
  static const Color cardBorder = Color(0xFFE3BEB4);   // Warm border

  // Primary Athletic Coral / Orange Brand
  static const Color primaryCoral = Color(0xFFFF5F25);      // Vibrant hero orange
  static const Color primaryCoralDark = Color(0xFFAD3300);  // Deep burnt orange
  static const Color primaryCoralLight = Color(0xFFFFDBD0); // Soft peach tint
  static const Color primaryFixedDim = Color(0xFFFFB59E);

  // Secondary Active Mint / Emerald
  static const Color accentGreen = Color(0xFF006C52);       // Mint emerald
  static const Color accentGreenLight = Color(0xFF89F4CD);  // Soft mint badge
  static const Color onSecondaryContainer = Color(0xFF007056);

  // Tertiary Indigo / Sleep Purple
  static const Color accentPurple = Color(0xFF594EBD);      // Sleep purple
  static const Color accentPurpleLight = Color(0xFFE4DFFF); // Soft lavender badge
  static const Color tertiaryContainer = Color(0xFF9086F8);

  // Health Alert Pink
  static const Color accentPink = Color(0xFFBA1A1A);        // Resting heart rate red
  static const Color accentPinkLight = Color(0xFFFFDAD6);   // Soft red container

  // Backward-compatible accents
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBlueLight = Color(0xFFDBEAFE);

  // Typography Text Tones
  static const Color textHeadline = Color(0xFF1F1B19); // On surface dark
  static const Color textBody = Color(0xFF5B4139);     // On surface variant
  static const Color textMuted = Color(0xFF8F7067);    // Outline muted
  static const Color divider = Color(0xFFF0E6E3);      // Divider line
}

