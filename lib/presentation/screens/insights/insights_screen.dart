import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/step_record_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/services/pedometer_service.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../common_widgets/icon_map.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/shell_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/step_providers.dart';
import '../../providers/workout_providers.dart';
import '../settings/goal_sheets.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_history_screen.dart';
import 'widgets/coach_insight_banner.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/health_overview_row.dart';
import 'widgets/quick_metrics_grid.dart';

/// Home dashboard.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(todayStepProvider.notifier).refresh();
    ref.invalidate(stepHistoryProvider);
    ref.invalidate(userStatsProvider);
    ref.invalidate(healthSnapshotProvider);
    ref.invalidate(waterTodayProvider);
    ref.invalidate(todayCaloriesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stepAsync = ref.watch(todayStepProvider);
    final history = ref.watch(stepHistoryProvider(7)).value;
    final todays = ref.watch(todaysWorkoutProvider).value;
    final weekSessions = ref.watch(weekSessionsProvider).value ?? const <WorkoutSession>[];
    final water = ref.watch(waterTodayProvider).value ?? 0;
    final kcal = ref.watch(todayCaloriesProvider).value ?? 0;

    final today = DateKeys.today();
    final workedOutToday = weekSessions.any((s) => DateKeys.of(s.startTime) == today);
    final step = stepAsync.value;
    final steps = step?.stepCount ?? 0;

    final keys = DateKeys.lastNDays(7);
    final byDay = <String, int>{
      for (final DailyStepRecord r in history ?? const <DailyStepRecord>[]) r.dateString: r.stepCount,
    };
    final weekValues = keys.map((k) => k == today ? steps : (byDay[k] ?? 0)).toList();
    final weekLabels = keys.map((k) => DateKeys.weekdayLetter[DateKeys.parse(k).weekday - 1]).toList();

    final insight = CoachInsight.from(
      steps: steps,
      stepGoal: settings.stepGoal,
      water: water,
      waterGoal: settings.waterGoalGlasses,
      kcalEaten: kcal,
      kcalTarget: settings.calorieTarget,
      workedOutToday: workedOutToday,
      restDay: todays == null,
      hour: DateTime.now().hour,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryCoral,
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const FitTrackrHeader(subtitle: 'Dashboard'),
              const SizedBox(height: 10),
              _greeting(settings.firstName, steps),
              const SizedBox(height: 12),
              if (step != null && step.sensorStatus != SensorStatus.active && step.source != 'HEALTH_CONNECT')
                _SensorBanner(status: step.sensorStatus),
              stepAsync.when(
                data: (data) => Column(
                  children: [
                    QuickMetricsGrid(
                      stepsText: MetricFormatter.formatSteps(data.stepCount),
                      kcalText: MetricFormatter.formatKcal(data.activeCalories),
                      distanceText: MetricFormatter.formatDistanceKm(data.distanceMeters),
                      activeTimeText: MetricFormatter.formatDurationMins(data.activeMinutes),
                    ),
                    const SizedBox(height: 16),
                    GoalProgressCard(
                      currentSteps: data.stepCount,
                      targetSteps: data.goalSteps,
                      percentage: data.progressPercentage,
                      streakDays: data.streakDays,
                      weekValues: weekValues,
                      weekLabels: weekLabels,
                      onEditGoal: () => showStepGoalSheet(context, ref),
                    ),
                  ],
                ),
                loading: () => const LoadingBlock(height: 260),
                error: (e, _) => ErrorCard(
                  message: 'Could not read activity data.',
                  onRetry: () => ref.invalidate(todayStepProvider),
                ),
              ),
              const SizedBox(height: 16),
              _TodayWorkoutCard(workout: todays, completed: workedOutToday),
              const SizedBox(height: 16),
              const HealthOverviewRow(),
              const SizedBox(height: 16),
              CoachInsightBanner(
                insight: insight,
                onTap: () => ref.read(shellTabProvider.notifier).select(insight.targetTab),
              ),
              const SizedBox(height: 16),
              _RecentWorkouts(sessions: weekSessions),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }

  Widget _greeting(String name, int steps) {
    final hour = DateTime.now().hour;
    final salutation = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$salutation, $name',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                steps > 0
                    ? '${MetricFormatter.formatSteps(steps)} steps recorded today.'
                    : 'Start moving - your steps will appear here.',
                style: AppTypography.bodyMedium.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        Pill(
          label: DateKeys.pretty(DateTime.now()),
          icon: LucideIcons.calendar,
          background: Colors.white,
          foreground: AppColors.textHeadline,
        ),
      ],
    );
  }
}

class _SensorBanner extends ConsumerWidget {
  final SensorStatus status;
  const _SensorBanner({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (status == SensorStatus.initializing) return const SizedBox.shrink();
    final denied = status == SensorStatus.permissionDenied;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const IconBadge(icon: LucideIcons.footprints),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    denied ? 'Step counting is off' : 'No step sensor found',
                    style: AppTypography.titleMedium,
                  ),
                  Text(
                    denied
                        ? 'Allow physical activity access to count steps.'
                        : 'Connect Health Connect to import steps from a watch or another app.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            if (denied)
              TextButton(
                onPressed: () async {
                  final result = await ref.read(todayStepProvider.notifier).requestSensorPermission();
                  if (result == SensorStatus.permissionDenied) {
                    await ref.read(pedometerServiceProvider).openSettings();
                  }
                },
                child: const Text('Enable'),
              ),
          ],
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final Workout? workout;
  final bool completed;

  const _TodayWorkoutCard({required this.workout, required this.completed});

  @override
  Widget build(BuildContext context) {
    final w = workout;
    return AppCard(
      onTap: w == null
          ? null
          : () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
      child: Row(
        children: [
          IconBadge(
            icon: w == null ? Icons.self_improvement : iconForCategory(w.category),
            size: 48,
            iconSize: 22,
            circle: false,
            background: completed ? AppColors.accentGreenLight : AppColors.primaryCoralLight,
            color: completed ? AppColors.accentGreen : AppColors.primaryCoral,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed ? "TODAY'S WORKOUT - DONE" : "TODAY'S WORKOUT",
                  style: AppTypography.labelSmall.copyWith(
                    color: completed ? AppColors.accentGreen : AppColors.primaryCoral,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(w?.title ?? 'Rest day', style: AppTypography.titleMedium),
                Text(
                  w == null
                      ? 'Recovery is part of training. A walk or mobility flow is a great option.'
                      : '${w.estimatedMinutes} min - ${w.exercises.length} exercises - ${w.category}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          if (w != null) const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _RecentWorkouts extends StatelessWidget {
  final List<WorkoutSession> sessions;
  const _RecentWorkouts({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'This week',
          actionLabel: 'History',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
          ),
        ),
        const SizedBox(height: 10),
        if (sessions.isEmpty)
          const EmptyState(
            icon: LucideIcons.dumbbell,
            title: 'No workouts this week yet',
            message: 'Completed sessions show up here with duration, sets and volume.',
          )
        else
          ...sessions.take(3).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconBadge(icon: iconForCategory(s.category), circle: false, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                              Text(
                                '${DateKeys.relativeLabel(DateKeys.of(s.startTime))} - '
                                '${MetricFormatter.formatClock(s.durationSeconds)} - ${s.setsCompleted} sets',
                                style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          s.totalVolumeKg > 0 ? '${MetricFormatter.formatInt(s.totalVolumeKg)} kg' : '${s.caloriesBurned.round()} kcal',
                          style: AppTypography.monoNumber(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
