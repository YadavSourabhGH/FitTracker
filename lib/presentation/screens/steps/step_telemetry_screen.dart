import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/fitness_calc.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/step_record_model.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../common_widgets/steps_history_chart.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/step_providers.dart';
import '../progress/progress_analytics_screen.dart';
import 'widgets/hourly_intensity_card.dart';
import 'widgets/step_hero_gauge_card.dart';
import 'widgets/step_streak_card.dart';

/// Activity tab: day-by-day steps, hourly distribution and history.
class StepTelemetryScreen extends ConsumerStatefulWidget {
  const StepTelemetryScreen({super.key});

  @override
  ConsumerState<StepTelemetryScreen> createState() => _StepTelemetryScreenState();
}

class _StepTelemetryScreenState extends ConsumerState<StepTelemetryScreen> {
  String _day = DateKeys.today();
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final live = ref.watch(todayStepProvider);
    final todayKey = DateKeys.today();
    if (_day.compareTo(todayKey) > 0) _day = todayKey;
    final isToday = _day == todayKey;
    final past = isToday ? null : ref.watch(dayStepRecordProvider(_day)).value;
    final hourly = ref.watch(hourlyStepsProvider(_day)).value ?? const <HourlyStepBucket>[];
    final history = ref.watch(stepHistoryProvider(_range)).value;
    final week = ref.watch(stepHistoryProvider(7)).value;

    final liveState = live.value;
    final steps = isToday ? (liveState?.stepCount ?? 0) : (past?.stepCount ?? 0);
    final goal = settings.stepGoal;
    final distance = settings.distanceMetersFor(steps);
    final kcal = settings.kcalFor(steps);

    // History values with today's live total.
    final keys = DateKeys.lastNDays(_range);
    final histMap = <String, int>{
      for (final DailyStepRecord r in history ?? const <DailyStepRecord>[]) r.dateString: r.stepCount,
    };
    final values = keys
        .map((k) => (k == todayKey ? (liveState?.stepCount ?? histMap[k] ?? 0) : (histMap[k] ?? 0)).toDouble())
        .toList();
    final avg = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
    final best = values.fold<double>(0, (m, v) => v > m ? v : m);
    final daysHit = values.where((v) => v >= goal).length;

    // This week (Mon..Sun) hit map.
    final weekMap = <String, int>{
      for (final DailyStepRecord r in week ?? const <DailyStepRecord>[]) r.dateString: r.stepCount,
    };
    weekMap[todayKey] = liveState?.stepCount ?? weekMap[todayKey] ?? 0;
    final monday = DateKeys.startOfWeek(DateTime.now());
    final weekHits = List<bool?>.generate(7, (i) {
      final d = DateTime(monday.year, monday.month, monday.day + i);
      final key = DateKeys.of(d);
      if (key.compareTo(todayKey) > 0) return null;
      final v = weekMap[key];
      if (v == null) return key == todayKey ? false : null;
      return v >= goal;
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryCoral,
          onRefresh: () async {
            await ref.read(todayStepProvider.notifier).refresh();
            ref.invalidate(stepHistoryProvider);
            ref.invalidate(hourlyStepsProvider);
            ref.invalidate(dayStepRecordProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const FitTrackrHeader(subtitle: 'Activity & Progress'),
              const SizedBox(height: 10),
              _dateSwitcher(isToday),
              const SizedBox(height: 14),
              if (isToday && live.isLoading && liveState == null)
                const LoadingBlock(height: 260)
              else
                StepHeroGaugeCard(
                  steps: steps,
                  goal: goal,
                  activeKcal: kcal,
                  caption: isToday ? 'today' : DateKeys.relativeLabel(_day).toLowerCase(),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _ribbon(LucideIcons.ruler, MetricFormatter.formatDistanceKm(distance), 'Distance',
                      AppColors.primaryCoral, AppColors.primaryCoralLight),
                  const SizedBox(width: 8),
                  _ribbon(LucideIcons.flame, MetricFormatter.formatKcal(kcal), 'kcal',
                      AppColors.accentPink, AppColors.accentPinkLight),
                  const SizedBox(width: 8),
                  _ribbon(LucideIcons.timer, MetricFormatter.formatDurationMins(FitnessCalc.activeMinutes(steps)),
                      'Active', AppColors.accentGreen, AppColors.accentGreenLight),
                  const SizedBox(width: 8),
                  _ribbon(LucideIcons.target, '${goal <= 0 ? 0 : (steps * 100 / goal).round()}%', 'of goal',
                      AppColors.accentPurple, AppColors.accentPurpleLight),
                ],
              ),
              const SizedBox(height: 14),
              HourlyIntensityCard(buckets: hourly, isToday: isToday),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Step history', style: AppTypography.titleLarge)),
                        _rangeChip(7),
                        const SizedBox(width: 6),
                        _rangeChip(30),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Avg ${MetricFormatter.formatInt(avg)} - best ${MetricFormatter.formatInt(best)} - goal met $daysHit/${values.length} days',
                      style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 180,
                      child: DailyBarChart(dayKeys: keys, values: values, goal: goal.toDouble()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              StepStreakCard(
                streakDays: liveState?.streakDays ?? 0,
                weekHits: weekHits,
                sourceLabel: liveState?.sourceLabel ?? 'No data yet',
                lastSync: liveState?.lastSync,
                onSyncTap: () async {
                  await ref.read(todayStepProvider.notifier).refresh();
                  ref.invalidate(stepHistoryProvider);
                  if (context.mounted) showAppSnack(context, 'Activity synced');
                },
              ),
              const SizedBox(height: 14),
              AppCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen()),
                ),
                child: Row(
                  children: [
                    const IconBadge(icon: LucideIcons.barChart2, size: 44, circle: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Training analytics', style: AppTypography.titleMedium),
                          Text(
                            'Volume load, estimated 1RM, sessions and body weight trends',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rangeChip(int days) {
    final selected = _range == days;
    return GestureDetector(
      onTap: () => setState(() => _range = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryCoral : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${days}D',
          style: AppTypography.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textBody,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _dateSwitcher(bool isToday) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            icon: const Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textBody),
            onPressed: () => setState(() => _day = DateKeys.shift(_day, -1)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateKeys.parse(_day),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _day = DateKeys.of(picked));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.calendar, size: 15, color: AppColors.primaryCoral),
                  const SizedBox(width: 6),
                  Text(DateKeys.relativeLabel(_day), style: AppTypography.titleMedium),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    const Pill(
                      label: 'Live',
                      background: AppColors.accentGreenLight,
                      foreground: AppColors.onSecondaryContainer,
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            icon: Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isToday ? AppColors.surfaceContainerHighest : AppColors.textBody,
            ),
            onPressed: isToday ? null : () => setState(() => _day = DateKeys.shift(_day, 1)),
          ),
        ],
      ),
    );
  }

  Widget _ribbon(IconData icon, String val, String unit, Color color, Color bg) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          children: [
            IconBadge(icon: icon, color: color, background: bg, size: 32, iconSize: 16),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(val, style: AppTypography.monoNumber(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            Text(unit, style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textBody)),
          ],
        ),
      ),
    );
  }
}
