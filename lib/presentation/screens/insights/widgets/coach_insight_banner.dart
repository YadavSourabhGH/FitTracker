import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../common_widgets/ui_kit.dart';

/// Rule-based coaching tip derived from today's real numbers.
class CoachInsight {
  final String title;
  final String message;
  final String actionLabel;
  final int targetTab; // shell tab to open

  const CoachInsight(this.title, this.message, this.actionLabel, this.targetTab);

  static CoachInsight from({
    required int steps,
    required int stepGoal,
    required int water,
    required int waterGoal,
    required double kcalEaten,
    required double kcalTarget,
    required bool workedOutToday,
    required bool restDay,
    required int hour,
  }) {
    final remaining = stepGoal - steps;
    if (steps >= stepGoal && workedOutToday) {
      return const CoachInsight(
        'Outstanding day',
        'Step goal reached and workout done. Prioritise protein and 7-9 hours of sleep to recover.',
        'Log a meal',
        3,
      );
    }
    if (!workedOutToday && !restDay && hour >= 7 && hour < 21) {
      return const CoachInsight(
        "Today's session is waiting",
        'Your plan has a workout scheduled today. Even a shorter session keeps the habit alive.',
        'Open workouts',
        1,
      );
    }
    if (water < waterGoal ~/ 2 && hour >= 13) {
      return CoachInsight(
        'Hydration is behind',
        'You have logged $water of $waterGoal glasses. Drink a glass now and keep a bottle nearby.',
        'View dashboard',
        0,
      );
    }
    if (remaining > 0 && hour >= 17) {
      final minutes = (remaining / 100).ceil();
      return CoachInsight(
        'Close your step goal',
        '$remaining steps to go - roughly a $minutes-minute brisk walk.',
        'See activity',
        2,
      );
    }
    if (kcalEaten == 0 && hour >= 10) {
      return const CoachInsight(
        'Track your nutrition',
        'No meals logged yet today. Logging helps you hit your protein and calorie targets.',
        'Log a meal',
        3,
      );
    }
    if (kcalTarget > 0 && kcalEaten > kcalTarget * 1.1) {
      return const CoachInsight(
        'Above calorie target',
        'You are over today\'s target. Favour lean protein and vegetables for remaining meals.',
        'Open diet',
        3,
      );
    }
    return const CoachInsight(
      'Consistency wins',
      'Small daily actions compound. Keep moving, log meals and stay hydrated.',
      'See activity',
      2,
    );
  }
}

class CoachInsightBanner extends StatelessWidget {
  final CoachInsight insight;
  final VoidCallback onTap;

  const CoachInsightBanner({super.key, required this.insight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const IconBadge(icon: LucideIcons.sparkles, size: 48, iconSize: 24, circle: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COACH INSIGHT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(insight.title, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      insight.message,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadline, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.actionLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.textHeadline),
            ],
          ),
        ),
      ),
    );
  }
}
