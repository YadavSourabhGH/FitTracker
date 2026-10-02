import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../common_widgets/circular_gauge.dart';
import '../../../common_widgets/ui_kit.dart';

/// Streak, this week's active days and today's three goal rings.
class GoalOverviewCard extends StatelessWidget {
  final int streakDays;
  final List<bool> weekDots; // Monday..Sunday
  final double movePct; // 0..100
  final double exercisePct;
  final double hydrationPct;
  final VoidCallback? onEditGoal;

  const GoalOverviewCard({
    super.key,
    required this.streakDays,
    required this.weekDots,
    required this.movePct,
    required this.exercisePct,
    required this.hydrationPct,
    this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final todayIdx = DateTime.now().weekday - 1;
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Goal Overview', actionLabel: onEditGoal == null ? null : 'Edit goal', onAction: onEditGoal),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.flame, color: AppColors.primaryCoral, size: 20),
                      const SizedBox(width: 4),
                      Text('$streakDays', style: AppTypography.displayLarge.copyWith(fontSize: 22)),
                    ],
                  ),
                  Text('Day Streak', style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(7, (idx) {
                      final isToday = idx == todayIdx;
                      final isDone = idx < weekDots.length && weekDots[idx];
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Column(
                          children: [
                            Text(
                              letters[idx],
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 8,
                                color: isToday ? AppColors.primaryCoral : AppColors.textBody,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isDone ? AppColors.primaryCoral : AppColors.cardBorder,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const Spacer(),
              _ringTile('Move', movePct, AppColors.primaryCoral),
              const SizedBox(width: 10),
              _ringTile('Exercise', exercisePct, AppColors.accentGreen),
              const SizedBox(width: 10),
              _ringTile('Water', hydrationPct, AppColors.accentBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ringTile(String label, double pct, Color color) {
    return Column(
      children: [
        CircularGauge(percentage: pct, size: 44, strokeWidth: 4.5, progressColor: color),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 9)),
      ],
    );
  }
}
