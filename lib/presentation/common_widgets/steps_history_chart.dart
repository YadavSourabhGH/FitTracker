import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_keys.dart';
import '../../core/utils/metric_formatter.dart';

/// Bar chart of daily totals with a dashed goal line.
class DailyBarChart extends StatelessWidget {
  final List<String> dayKeys;
  final List<double> values;
  final double? goal;
  final String unit;
  final Color color;
  final Color goalColor;

  const DailyBarChart({
    super.key,
    required this.dayKeys,
    required this.values,
    this.goal,
    this.unit = 'steps',
    this.color = AppColors.primaryCoral,
    this.goalColor = AppColors.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = values.fold<double>(goal ?? 0.0, (m, v) => v > m ? v : m);
    final maxY = maxVal <= 0 ? 10.0 : maxVal * 1.15;
    final dense = values.length > 10;
    final labelEvery = dense ? (values.length / 6).ceil() : 1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (goal != null && goal! > 0)
              HorizontalLine(
                y: goal!,
                color: goalColor.withValues(alpha: 0.7),
                strokeWidth: 1.5,
                dashArray: const [6, 4],
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: maxY / 4,
              getTitlesWidget: (v, meta) {
                if (v == 0 || v >= maxY * 0.99) return const SizedBox.shrink();
                return Text(MetricFormatter.compact(v), style: AppTypography.labelSmall.copyWith(fontSize: 9));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= dayKeys.length) return const SizedBox.shrink();
                final isLast = i == dayKeys.length - 1;
                if (!isLast && i % labelEvery != 0) return const SizedBox.shrink();
                final d = DateKeys.parse(dayKeys[i]);
                final label = dense ? '${d.day}/${d.month}' : DateKeys.weekdayShort[d.weekday - 1].substring(0, 2);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 9,
                      color: isLast ? AppColors.primaryCoral : AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textHeadline,
            tooltipBorderRadius: BorderRadius.circular(10),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final key = dayKeys[group.x.toInt()];
              return BarTooltipItem(
                '${DateKeys.relativeLabel(key)}\n${MetricFormatter.formatInt(rod.toY)} $unit',
                AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          final v = values[i];
          final hit = goal != null && goal! > 0 && v >= goal!;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: v,
                width: dense ? 6 : 18,
                color: hit ? goalColor : color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.surfaceContainerLow,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
