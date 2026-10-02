import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/metric_formatter.dart';

/// Seven-day step distribution bars (oldest on the left, today on the right).
class WeeklyDistributionBars extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final int goal;

  const WeeklyDistributionBars({
    super.key,
    required this.values,
    required this.labels,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [goal, ...values].reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final v = values[i];
          final isToday = i == values.length - 1;
          final hit = v >= goal && goal > 0;
          final h = maxValue <= 0 ? 0.06 : (v / maxValue).clamp(0.06, 1.0).toDouble();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (v > 0)
                    Text(
                      MetricFormatter.compact(v),
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 8,
                        color: isToday ? AppColors.primaryCoral : AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Tooltip(
                    message: '${labels[i]}: ${MetricFormatter.formatSteps(v)} steps',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: 60 * h,
                      decoration: BoxDecoration(
                        gradient: (isToday || hit) && v > 0
                            ? LinearGradient(
                                colors: hit
                                    ? const [AppColors.accentGreen, Color(0xFF2BB58A)]
                                    : const [AppColors.primaryCoralDark, AppColors.primaryCoral],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : null,
                        color: (isToday || hit) && v > 0 ? null : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
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
      ),
    );
  }
}
