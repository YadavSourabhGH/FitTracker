import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common_widgets/circular_gauge.dart';

/// Goal Overview multi-metric card from the right UI reference mockup.
class GoalOverviewCard extends StatelessWidget {
  final int streakDays;
  final List<bool> weekDots;
  final double movePct;
  final double exercisePct;
  final double hydrationPct;

  const GoalOverviewCard({
    super.key,
    required this.streakDays,
    required this.weekDots,
    required this.movePct,
    required this.exercisePct,
    required this.hydrationPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Left: Streak & Weekday Dots
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
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final dayChar = entry.value;
                  final todayIdx = DateTime.now().weekday % 7;
                  final isToday = idx == todayIdx;
                  final isPast = idx < todayIdx;
                  final isDone = (isPast && (todayIdx - idx) <= streakDays && streakDays > 0) ||
                      (isToday && streakDays > 0);

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      children: [
                        Text(
                          dayChar,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 8,
                            color: isToday ? AppColors.primaryCoral : AppColors.textBody,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primaryCoral : AppColors.cardBorder,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const Spacer(),
          Container(width: 1, height: 60, color: AppColors.divider),
          const Spacer(),

          // Right: 3 Progress Gauges (Move, Exercise, Hydration)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Goal Overview', style: AppTypography.titleMedium),
                  const SizedBox(width: 16),
                  Text('Edit goal', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ringTile('Move', movePct, AppColors.primaryCoral, LucideIcons.flame),
                  const SizedBox(width: 10),
                  _ringTile('Exercise', exercisePct, AppColors.accentGreen, LucideIcons.footprints),
                  const SizedBox(width: 10),
                  _ringTile('Hydration', hydrationPct, AppColors.accentBlue, LucideIcons.droplets),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ringTile(String label, double pct, Color color, IconData icon) {
    return Column(
      children: [
        CircularGauge(
          percentage: pct,
          size: 40,
          strokeWidth: 4.5,
          progressColor: color,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 9)),
      ],
    );
  }
}
