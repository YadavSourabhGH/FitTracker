import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 7-day weekly activity distribution bar chart matching Stitch design.
class WeeklyDistributionBars extends StatelessWidget {
  final int currentSteps;

  const WeeklyDistributionBars({super.key, required this.currentSteps});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIdx = now.weekday % 7; // Sun=0 ... Sat=6
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (idx) {
        final isToday = idx == todayIdx;

        // Real height calculation: 0.1 baseline for empty/future days
        final double h;
        if (isToday) {
          h = currentSteps > 0 ? (currentSteps / 10000).clamp(0.15, 1.0) : 0.12;
        } else {
          // Empty baseline for unrecorded days
          h = 0.10;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 70 * h,
                  decoration: BoxDecoration(
                    gradient: (isToday && currentSteps > 0)
                        ? const LinearGradient(
                            colors: [AppColors.primaryCoralDark, AppColors.primaryCoral],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          )
                        : null,
                    color: isToday
                        ? (currentSteps > 0 ? null : AppColors.primaryCoralLight)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && currentSteps == 0
                        ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.5), width: 1.5)
                        : null,
                    boxShadow: (isToday && currentSteps > 500)
                        ? const [
                            BoxShadow(
                              color: Color(0x55FF5F25),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (isToday && currentSteps > 500)
                      ? RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            '${(currentSteps / 1000).toStringAsFixed(1)}k',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  days[idx],
                  style: AppTypography.labelSmall.copyWith(
                    color: isToday ? AppColors.primaryCoral : AppColors.textBody,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
