import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common_widgets/circular_gauge.dart';
import 'weekly_distribution_bars.dart';

/// Goal Progress Card from Stitch: Radial gauge, On Track badge, & weekly distribution bars.
class GoalProgressCard extends StatelessWidget {
  final int currentSteps;
  final int targetSteps;
  final double percentage;
  final int streakDays;

  const GoalProgressCard({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
    required this.percentage,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (targetSteps - currentSteps) > 0 ? (targetSteps - currentSteps) : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Goal Progress', style: AppTypography.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCoralLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.flame, size: 12, color: AppColors.primaryCoral),
                        const SizedBox(width: 3),
                        Text(
                          '$streakDays Day Streak',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryCoralDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'Edit goal',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryCoral,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Inner Radial Gauge Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.innerContainerDecoration,
            child: Row(
              children: [
                CircularGauge(
                  percentage: percentage,
                  size: 84,
                  strokeWidth: 9,
                  centerText: '${percentage.toInt()}%',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: percentage >= 100 ? AppColors.accentGreen : (percentage > 0 ? AppColors.primaryCoral : AppColors.textBody),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              percentage >= 100 ? 'Goal Reached' : (percentage > 0 ? 'On Track' : 'Get Started'),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
                          text: '$currentSteps ',
                          style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(
                              text: '/ $targetSteps',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.flag, size: 12, color: AppColors.primaryCoral),
                          const SizedBox(width: 4),
                          Text(
                            remaining > 0 ? '$remaining steps left' : 'Goal achieved!',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryCoral,
                              fontWeight: FontWeight.w600,
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

          // Weekly Distribution Bar Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Distribution',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
              ),
              Text(
                currentSteps > 0 ? 'Avg ${(currentSteps / 1000).toStringAsFixed(1)}k / day' : 'Avg 0 / day',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryCoral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          WeeklyDistributionBars(currentSteps: currentSteps),
        ],
      ),
    );
  }
}

