import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/workout_providers.dart';

/// Training analytics built from completed sessions and logged sets.
class ProgressAnalyticsScreen extends ConsumerStatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  ConsumerState<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends ConsumerState<ProgressAnalyticsScreen> {
  String? _exerciseId;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(recentSessionsProvider);
    final prsAsync = ref.watch(personalRecordsProvider);
    final stats = ref.watch(userStatsProvider).value;
    final weights = ref.watch(weightHistoryProvider).value ?? const <MapEntry<String, double>>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Training Analytics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Row(
              children: [
                _tile('Workouts', '${stats?.totalWorkouts ?? 0}', LucideIcons.dumbbell),
                const SizedBox(width: 8),
                _tile('Volume', '${MetricFormatter.compact(stats?.totalVolumeKg ?? 0)} kg', LucideIcons.barChart2),
                const SizedBox(width: 8),
                _tile('Time', MetricFormatter.formatDurationMins((stats?.totalWorkoutSeconds ?? 0) ~/ 60), LucideIcons.timer),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) => _weeklyVolumeCard(sessions),
              loading: () => const LoadingBlock(height: 220),
              error: (e, _) => ErrorCard(message: '$e', onRetry: () => ref.invalidate(recentSessionsProvider)),
            ),
            const SizedBox(height: 16),
            prsAsync.when(
              data: (prs) => _oneRepMaxCard(prs),
              loading: () => const LoadingBlock(height: 220),
              error: (e, _) => ErrorCard(message: '$e', onRetry: () => ref.invalidate(personalRecordsProvider)),
            ),
            const SizedBox(height: 16),
            _weightCard(weights),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, IconData icon) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            IconBadge(icon: icon, size: 32, iconSize: 16),
            const SizedBox(height: 6),
            FittedBox(child: Text(value, style: AppTypography.monoNumber(fontSize: 14, fontWeight: FontWeight.w800))),
            Text(label, style: AppTypography.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _weeklyVolumeCard(List<WorkoutSession> sessions) {
    const weeks = 8;
    final thisMonday = DateKeys.startOfWeek(DateTime.now());
    final starts = List.generate(
      weeks,
      (i) => DateTime(thisMonday.year, thisMonday.month, thisMonday.day - 7 * (weeks - 1 - i)),
    );
    final volume = List<double>.filled(weeks, 0);
    final count = List<int>.filled(weeks, 0);
    for (final s in sessions) {
      for (var i = weeks - 1; i >= 0; i--) {
        if (!s.startTime.isBefore(starts[i])) {
          volume[i] += s.totalVolumeKg;
          count[i] += 1;
          break;
        }
      }
    }
    final maxV = volume.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = maxV <= 0 ? 1000.0 : maxV * 1.2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly volume load', style: AppTypography.titleLarge),
          const SizedBox(height: 2),
          Text('Sum of weight x reps over completed sets, last 8 weeks', style: AppTypography.bodyMedium),
          const SizedBox(height: 18),
          if (sessions.isEmpty)
            const EmptyState(
              icon: LucideIcons.barChart2,
              title: 'No sessions yet',
              message: 'Finish a workout to start building your volume chart.',
            )
          else
            SizedBox(
              height: 190,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.divider, strokeWidth: 1),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.textHeadline,
                      getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                        '${MetricFormatter.formatInt(rod.toY)} kg\n${count[group.x]} session(s)',
                        AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: maxY / 4,
                        getTitlesWidget: (v, meta) => v == 0 || v >= maxY * 0.99
                            ? const SizedBox.shrink()
                            : Text(MetricFormatter.compact(v), style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= weeks) return const SizedBox.shrink();
                          final d = starts[i];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${d.day}/${d.month}', style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    weeks,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: volume[i],
                          width: 18,
                          color: i == weeks - 1 ? AppColors.primaryCoral : AppColors.primaryFixedDim,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _oneRepMaxCard(List<PersonalRecord> prs) {
    if (prs.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.trendingUp,
        title: 'Estimated 1RM',
        message: 'Log weighted sets (bench, squat, deadlift...) to see strength trends and personal records.',
      );
    }
    final selected = prs.any((p) => p.exerciseId == _exerciseId) ? _exerciseId! : prs.first.exerciseId;
    final trend = ref.watch(oneRepMaxTrendProvider(selected)).value ?? const <MapEntry<DateTime, double>>[];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimated 1RM trend', style: AppTypography.titleLarge),
          const SizedBox(height: 2),
          Text('Epley formula, best set per session', style: AppTypography.bodyMedium),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: prs.map((p) {
                final isSel = p.exerciseId == selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.exerciseName),
                    selected: isSel,
                    showCheckmark: false,
                    selectedColor: AppColors.primaryCoral,
                    backgroundColor: Colors.white,
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSel ? Colors.white : AppColors.textHeadline,
                      fontSize: 11,
                    ),
                    onSelected: (_) => setState(() => _exerciseId = p.exerciseId),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: trend.length < 2
                ? Center(
                    child: Text(
                      trend.isEmpty ? 'No data yet' : 'Log this lift in another session to see a trend',
                      style: AppTypography.bodyMedium,
                    ),
                  )
                : _lineChart(
                    trend.map((e) => e.value).toList(),
                    trend.map((e) => '${e.key.day}/${e.key.month}').toList(),
                    'kg',
                  ),
          ),
          const SizedBox(height: 16),
          Text('Personal records', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          ...prs.take(8).map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 16, color: AppColors.accentAmber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.exerciseName, style: AppTypography.bodyLarge)),
                      Text(
                        '${MetricFormatter.formatWeight(p.bestWeightKg)} kg x ${p.repsAtBest}',
                        style: AppTypography.monoNumber(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'e1RM ${p.estimatedOneRepMax.toStringAsFixed(1)}',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _weightCard(List<MapEntry<String, double>> weights) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Body weight', style: AppTypography.titleLarge)),
              TextButton.icon(
                onPressed: _logWeight,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log weight'),
              ),
            ],
          ),
          Text(
            weights.isEmpty
                ? 'Log your weight regularly to see the trend.'
                : 'Latest ${MetricFormatter.formatWeight(weights.last.value)} kg on ${DateKeys.relativeLabel(weights.last.key)}',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 14),
          if (weights.length >= 2)
            SizedBox(
              height: 160,
              child: _lineChart(
                weights.map((e) => e.value).toList(),
                weights.map((e) {
                  final d = DateKeys.parse(e.key);
                  return '${d.day}/${d.month}';
                }).toList(),
                'kg',
                color: AppColors.accentPurple,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _logWeight() async {
    final current = ref.read(settingsProvider);
    final value = await promptNumber(context, title: 'Body weight', initial: current.weightKg, suffix: 'kg');
    if (value == null || value < 25 || value > 350) return;
    await ref.read(hydrationRepositoryProvider).logWeight(DateKeys.today(), value);
    await ref.read(settingsProvider.notifier).save(current.copyWith(weightKg: value));
    ref.invalidate(weightHistoryProvider);
    if (mounted) showAppSnack(context, 'Weight logged: ${MetricFormatter.formatWeight(value)} kg');
  }

  Widget _lineChart(List<double> ys, List<String> labels, String unit, {Color color = AppColors.primaryCoral}) {
    final minV = ys.reduce((a, b) => a < b ? a : b);
    final maxV = ys.reduce((a, b) => a > b ? a : b);
    final pad = (maxV - minV).abs() < 1 ? 2.0 : (maxV - minV) * 0.2;
    final every = (ys.length / 5).ceil();
    return LineChart(
      LineChartData(
        minY: minV - pad,
        maxY: maxV + pad,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textHeadline,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${labels[s.x.toInt()]}\n${s.y.toStringAsFixed(1)} $unit',
                      AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11),
                    ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0), style: AppTypography.labelSmall.copyWith(fontSize: 9)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length || v != i.toDouble()) return const SizedBox.shrink();
                if (i % every != 0 && i != labels.length - 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(ys.length, (i) => FlSpot(i.toDouble(), ys[i])),
            isCurved: true,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}
