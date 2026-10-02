import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/metric_formatter.dart';
import '../../../common_widgets/circular_gauge.dart';
import '../../../common_widgets/ui_kit.dart';
import 'weekly_distribution_bars.dart';

/// Daily step goal gauge with the last seven days of activity.
class GoalProgressCard extends StatelessWidget {
  final int currentSteps;
  final int targetSteps;
  final double percentage;
  final int streakDays;
  final List<int> weekValues;
  final List<String> weekLabels;
  final VoidCallback onEditGoal;

  const GoalProgressCard({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
    required this.percentage,
    required this.streakDays,
    required this.weekValues,
    required this.weekLabels,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (targetSteps - currentSteps) > 0 ? (targetSteps - currentSteps) : 0;
    final avg = weekValues.isEmpty ? 0 : weekValues.reduce((a, b) => a + b) ~/ weekValues.length;
    final reached = percentage >= 100;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Goal Progress', style: AppTypography.titleLarge),
              const SizedBox(width: 8),
              Pill(label: '$streakDays day streak', icon: LucideIcons.flame),
              const Spacer(),
              InkWell(
                onTap: onEditGoal,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    'Edit goal',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.innerContainerDecoration,
            child: Row(
              children: [
                CircularGauge(
                  percentage: percentage,
                  size: 84,
                  strokeWidth: 9,
                  progressColor: reached ? AppColors.accentGreen : AppColors.primaryCoral,
                  centerText: '${percentage.toInt()}%',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(
                        label: reached ? 'Goal reached' : (currentSteps > 0 ? 'In progress' : 'Get started'),
                        background: reached ? AppColors.accentGreenLight : AppColors.surfaceContainerHigh,
                        foreground: reached ? AppColors.onSecondaryContainer : AppColors.textBody,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'STEP GOAL',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textBody,
                          letterSpacing: 0.8,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 1),
                      RichText(
                        text: TextSpan(
                          text: '${MetricFormatter.formatSteps(currentSteps)} ',
                          style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(
                              text: '/ ${MetricFormatter.formatSteps(targetSteps)}',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            reached ? Icons.check_circle_outline : LucideIcons.flag,
                            size: 12,
                            color: reached ? AppColors.accentGreen : AppColors.primaryCoral,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              reached
                                  ? 'Goal achieved today'
                                  : '${MetricFormatter.formatSteps(remaining)} steps left',
                              style: AppTypography.labelSmall.copyWith(
                                color: reached ? AppColors.accentGreen : AppColors.primaryCoral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last 7 days', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
              Text(
                'Avg ${MetricFormatter.compact(avg)} / day',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryCoral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          WeeklyDistributionBars(values: weekValues, labels: weekLabels, goal: targetSteps),
        ],
      ),
    );
  }
}
