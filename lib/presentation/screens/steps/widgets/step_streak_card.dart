import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/metric_formatter.dart';

/// Streak & weekly breakdown card with real step data.
class StepStreakCard extends StatelessWidget {
  final int streakDays;
  final int currentSteps;
  final VoidCallback onSyncTap;

  const StepStreakCard({
    super.key,
    required this.streakDays,
    this.currentSteps = 0,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIdx = now.weekday % 7; // Sun=0 ... Sat=6
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryCoralLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.flame, color: AppColors.primaryCoral, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streakDays Day Streak', style: AppTypography.titleLarge),
                    Text(
                      streakDays > 0 ? 'Daily movement streak active' : 'Hit your step goal today to build a streak',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: streakDays > 0 ? AppColors.accentGreenLight : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  streakDays > 0 ? 'Active' : 'Start Today',
                  style: AppTypography.labelSmall.copyWith(
                    color: streakDays > 0 ? AppColors.onSecondaryContainer : AppColors.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == todayIdx;
              final isPastCompleted = i < todayIdx && (todayIdx - i) <= streakDays && streakDays > 0;
              return Column(
                children: [
                  Text(
                    days[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isToday ? AppColors.primaryCoral : AppColors.textBody,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isPastCompleted
                          ? AppColors.primaryCoral
                          : (isToday ? AppColors.primaryCoralLight : AppColors.surfaceContainerHigh),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColors.primaryCoral, width: 2)
                          : null,
                    ),
                    child: isPastCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : (isToday
                            ? const Center(child: Text('Now', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryCoral)))
                            : null),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppTheme.innerContainerDecoration,
            child: Row(
              children: [
                const Icon(LucideIcons.barChart2, color: AppColors.primaryCoral, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentSteps > 0 ? "TODAY'S RECORDED ACTIVITY" : "DAILY STEP RECORD", style: AppTypography.labelSmall.copyWith(fontSize: 9, letterSpacing: 0.6)),
                      Text(
                        currentSteps > 0 ? '${MetricFormatter.formatSteps(currentSteps)} steps' : '0 steps logged',
                        style: AppTypography.monoNumber(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Live sensor connected • Pedometer',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 10),
                ),
              ),
              GestureDetector(
                onTap: onSyncTap,
                child: Text(
                  'Sync now',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryCoral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
