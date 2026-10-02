import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/nutrition_model.dart';
import '../../../common_widgets/circular_gauge.dart';
import '../../../common_widgets/ui_kit.dart';

/// Calories consumed vs target with macro progress bars.
class DailyCalorieCard extends StatelessWidget {
  final MacroTargets targets;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String goalLabel;

  const DailyCalorieCard({
    super.key,
    required this.targets,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.goalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final target = targets.targetCalories;
    final remaining = target - totalCalories;
    final pct = target <= 0 ? 0.0 : (totalCalories / target * 100);
    final over = remaining < 0;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Daily Calories', style: AppTypography.titleLarge)),
              Pill(label: goalLabel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircularGauge(
                percentage: pct.clamp(0, 100).toDouble(),
                size: 96,
                strokeWidth: 10,
                progressColor: over ? AppColors.accentPink : AppColors.primaryCoral,
                centerText: '${pct.round()}%',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Eaten', totalCalories.round(), AppColors.primaryCoral),
                    const SizedBox(height: 6),
                    _row('Target', target.round(), AppColors.textHeadline),
                    const SizedBox(height: 6),
                    _row(over ? 'Over by' : 'Remaining', remaining.abs().round(),
                        over ? AppColors.accentPink : AppColors.accentGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _macroBar('Protein', totalProtein, targets.targetProteinGrams, AppColors.primaryCoral),
          const SizedBox(height: 8),
          _macroBar('Carbs', totalCarbs, targets.targetCarbsGrams, AppColors.accentAmber),
          const SizedBox(height: 8),
          _macroBar('Fat', totalFat, targets.targetFatGrams, AppColors.accentBlue),
        ],
      ),
    );
  }

  Widget _row(String label, int value, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyLarge)),
        Text('$value kcal', style: AppTypography.monoNumber(fontSize: 14, color: color)),
      ],
    );
  }

  Widget _macroBar(String name, double val, double target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTypography.bodyMedium),
            Text('${val.round()} / ${target.round()} g', style: AppTypography.monoNumber(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: target <= 0 ? 0.0 : (val / target).clamp(0.0, 1.0).toDouble(),
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
