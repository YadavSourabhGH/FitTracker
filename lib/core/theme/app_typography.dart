import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography hierarchy using bundled Plus Jakarta Sans and JetBrains Mono
/// (no runtime font downloads, works fully offline).
class AppTypography {
  AppTypography._();

  static const String sans = 'PlusJakartaSans';
  static const String mono = 'JetBrainsMono';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: sans,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textHeadline,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: sans,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: sans,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  /// Fixed-width numbers preventing layout shifts during live counter updates.
  static TextStyle monoNumber({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textHeadline,
  }) {
    return TextStyle(
      fontFamily: mono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
