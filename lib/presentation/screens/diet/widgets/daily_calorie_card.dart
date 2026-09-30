import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Card displaying consumed calories and macronutrient progress.
class DailyCalorieCard extends StatelessWidget {
  final double targetCalories;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailyCalorieCard({
    super.key,
    required this.targetCalories,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = targetCalories - totalCalories;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Calories', style: AppTypography.titleLarge),
          Text('Target: ${targetCalories.toInt()} kcal', style: AppTypography.labelSmall),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _calMetric('Consumed', totalCalories.toInt().toString(), AppColors.primaryCoral),
          Container(width: 1, height: 32, color: AppColors.cardBorder),
          _calMetric('Remaining', (remaining > 0 ? remaining : 0).toInt().toString(), AppColors.accentGreen),
        ]),
        const SizedBox(height: 14),
        _macroBar('Protein', totalProtein, 180, AppColors.primaryCoral),
        const SizedBox(height: 8),
        _macroBar('Carbs', totalCarbs, 250, AppColors.accentAmber),
        const SizedBox(height: 8),
        _macroBar('Fat', totalFat, 70, AppColors.accentBlue),
      ]),
    );
  }

  Widget _calMetric(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: AppTypography.monoNumber(fontSize: 22, color: color)),
      Text(label, style: AppTypography.bodyMedium),
    ]);
  }

  Widget _macroBar(String name, double val, double target, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: AppTypography.bodyMedium),
        Text('${val.toInt()}g / ${target.toInt()}g', style: AppTypography.monoNumber(fontSize: 11)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (val / target).clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: const Color(0xFFF3EFEA),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}
