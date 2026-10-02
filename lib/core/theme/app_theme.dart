import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 theme configured for FitTrackr's warm aesthetic.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.sans,
      scaffoldBackgroundColor: AppColors.scaffoldBase,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryCoral,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryCoralLight,
        secondary: AppColors.accentGreen,
        onSecondary: Colors.white,
        tertiary: AppColors.accentPurple,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textHeadline,
        outline: AppColors.cardBorder,
        error: AppColors.accentPink,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textHeadline),
        titleTextStyle: AppTypography.headlineMedium,
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
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          minimumSize: const Size(64, 50),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryCoral,
          side: const BorderSide(color: AppColors.primaryCoral),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.titleMedium,
          minimumSize: const Size(64, 46),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryCoral,
          textStyle: AppTypography.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryCoral, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textHeadline,
        contentTextStyle: AppTypography.bodyLarge.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyLarge,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryCoral
              : AppColors.surfaceContainerHigh,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryCoral,
        thumbColor: AppColors.primaryCoral,
        inactiveTrackColor: AppColors.surfaceContainerHigh,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryCoral),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.primaryCoral),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Reusable card box decoration with warm ambient diffuse shadow.
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
        ),
      ],
    );
  }

  /// Inner container decoration matching surface-container-low.
  static BoxDecoration get innerContainerDecoration {
    return BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3), width: 1),
    );
  }
}
