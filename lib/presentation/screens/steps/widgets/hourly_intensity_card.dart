import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/metric_formatter.dart';
import '../../../../data/models/step_record_model.dart';
import '../../../common_widgets/ui_kit.dart';

/// Steps per hour recorded by the phone sensor for one day.
class HourlyIntensityCard extends StatelessWidget {
  final List<HourlyStepBucket> buckets;
  final bool isToday;

  const HourlyIntensityCard({super.key, required this.buckets, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final nowHour = DateTime.now().hour;
    final hours = List.generate(18, (i) => i + 5); // 5 AM .. 10 PM
    final byHour = {for (final b in buckets) b.hour: b.steps};
    // Early-morning / late-night steps fold into the edge buckets.
    var early = 0;
    var lateNight = 0;
    byHour.forEach((h, s) {
      if (h < 5) early += s;
      if (h > 22) lateNight += s;
    });
    int stepsAt(int h) => (byHour[h] ?? 0) + (h == 5 ? early : 0) + (h == 22 ? lateNight : 0);
    final values = hours.map(stepsAt).toList();
    final maxV = values.fold<int>(0, (m, v) => v > m ? v : m);
    var peakHour = -1;
    if (maxV > 0) peakHour = hours[values.indexOf(maxV)];
    final total = values.fold<int>(0, (a, b) => a + b);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hourly Intensity', style: AppTypography.titleLarge),
                    Text(
                      total > 0
                          ? 'Peak at ${_label(peakHour)} with ${MetricFormatter.formatSteps(maxV)} steps'
                          : 'Hourly breakdown from the phone step sensor',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              Pill(
                icon: total > 0 ? LucideIcons.trendingUp : LucideIcons.clock,
                label: total > 0 ? 'Sensor' : 'No data',
                background: AppColors.surfaceContainerLow,
                foreground: AppColors.primaryCoral,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(hours.length, (i) {
                final h = hours[i];
                final v = values[i];
                final ratio = maxV == 0 ? 0.05 : (v / maxV).clamp(0.05, 1.0).toDouble();
                final isPeak = h == peakHour;
                final isNow = isToday && h == nowHour;
                return Expanded(
                  child: Tooltip(
                    message: '${_label(h)}: ${MetricFormatter.formatSteps(v)} steps',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 70 * ratio,
                            decoration: BoxDecoration(
                              color: v == 0
                                  ? AppColors.surfaceContainerHigh
                                  : (isPeak ? AppColors.primaryCoral : AppColors.primaryFixedDim),
                              borderRadius: BorderRadius.circular(4),
                              border: isNow ? Border.all(color: AppColors.primaryCoralDark, width: 1.2) : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 12,
                            child: (h % 3 == 0)
                                ? FittedBox(
                                    child: Text(
                                      _short(h),
                                      style: AppTypography.labelSmall.copyWith(fontSize: 8),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static String _short(int h) {
    if (h == 0) return '12a';
    if (h == 12) return '12p';
    return h < 12 ? '${h}a' : '${h - 12}p';
  }

  static String _label(int h) {
    if (h < 0) return '-';
    final suffix = h < 12 ? 'AM' : 'PM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh $suffix';
  }
}
