import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 theme configured for FitTrackr's warm aesthetic.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBase,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryCoral,
        secondary: AppColors.accentGreen,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textHeadline,
        outline: AppColors.cardBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textHeadline),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.4), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCoral,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }

  /// Reusable card box decoration with warm ambient diffuse shadow
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4), width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1EB89988),
          blurRadius: 18,
          offset: Offset(0, 6),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Inner container decoration matching surface-container-low (#FBF2EE)
  static BoxDecoration get innerContainerDecoration {
    return BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3), width: 1),
    );
  }
}

