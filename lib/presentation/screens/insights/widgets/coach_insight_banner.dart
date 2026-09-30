import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Coach Insight banner card matching the Stitch Dashboard design with real day and activity.
class CoachInsightBanner extends StatelessWidget {
  final int stepCount;

  const CoachInsightBanner({super.key, this.stepCount = 0});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[now.weekday - 1];

    final insightText = stepCount > 0
        ? "Active progress on $dayName! You've logged $stepCount steps today. Keep your momentum going."
        : "Make the most of $dayName. Organize your workouts and stay consistent with your daily goal.";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10B89988),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primaryCoralLight,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: AppColors.primaryCoral,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primaryCoral),
                    const SizedBox(width: 4),
                    Text(
                      'COACH INSIGHT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insightText,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadline,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.textHeadline),
          ),
        ],
      ),
    );
  }
}
