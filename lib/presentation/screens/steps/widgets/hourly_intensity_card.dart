import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Hourly Intensity card with real-time step distribution.
class HourlyIntensityCard extends StatelessWidget {
  final int currentSteps;

  const HourlyIntensityCard({super.key, this.currentSteps = 0});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final hasActivity = currentSteps > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hourly Intensity', style: AppTypography.titleLarge),
                  Text(
                    hasActivity ? 'Live cadence across active hours' : 'Step volume from 6 AM to 10 PM',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasActivity ? LucideIcons.trendingUp : LucideIcons.clock,
                      size: 12,
                      color: AppColors.primaryCoral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasActivity ? 'Real-Time' : 'Live Sensor',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBarChart(currentHour),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(
                hasActivity ? AppColors.primaryCoral : AppColors.cardBorder,
                hasActivity ? 'Active Walk Interval' : 'Awaiting motion events',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 10)),
      ],
    );
  }

  Widget _buildBarChart(int currentHour) {
    // 9 time slots: 6a (6), 8a (8), 10a (10), 12p (12), 1p (13), 3p (15), 5p (17), 7p (19), 9p (21)
    final hours = [
      (label: '6a', hour: 6),
      (label: '8a', hour: 8),
      (label: '10a', hour: 10),
      (label: '12p', hour: 12),
      (label: '1p', hour: 13),
      (label: '3p', hour: 15),
      (label: '5p', hour: 17),
      (label: '7p', hour: 19),
      (label: '9p', hour: 21),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: hours.map((h) {
        final isPastOrCurrent = currentHour >= h.hour;
        final isCurrent = currentHour >= h.hour && currentHour < h.hour + 2;
        final hasSteps = currentSteps > 0 && isPastOrCurrent;

        final double heightRatio;
        if (!hasSteps) {
          heightRatio = 0.10;
        } else if (isCurrent) {
          heightRatio = (currentSteps / 5000).clamp(0.25, 0.95);
        } else {
          heightRatio = 0.18;
        }

        final isPeak = hasSteps && isCurrent && currentSteps > 500;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPeak) ...[
                  Text(
                    '${(currentSteps / 1000).toStringAsFixed(1)}k',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryCoral,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 3),
                ] else ...[
                  const SizedBox(height: 16),
                ],
                Container(
                  height: 64 * heightRatio,
                  decoration: BoxDecoration(
                    gradient: isPeak
                        ? const LinearGradient(
                            colors: [AppColors.primaryCoralDark, AppColors.primaryCoral],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          )
                        : null,
                    color: isPeak ? null : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isPeak
                        ? const [
                            BoxShadow(color: Color(0x44FF5F25), blurRadius: 6, offset: Offset(0, 2)),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  h.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isPeak ? AppColors.primaryCoral : AppColors.textMuted,
                    fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

