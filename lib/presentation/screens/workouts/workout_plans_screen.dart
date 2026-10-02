import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/stats_providers.dart';
import '../../providers/workout_providers.dart';
import 'widgets/weekly_schedule_card.dart';
import 'widgets/workout_hero_plan_card.dart';
import 'widgets/workout_library_card.dart';
import 'workout_detail_screen.dart';
import 'workout_history_screen.dart';

/// Workouts tab: today's plan, weekly schedule and the full library.
class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Strength', 'Hypertrophy', 'HIIT', 'Cardio', 'Mobility', 'Beginner'];

  bool _matches(Workout w) {
    if (_filter == 'All') return true;
    if (_filter == 'Beginner') return w.difficulty == 'Beginner';
    return w.category.toLowerCase() == _filter.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(allWorkoutsProvider);
    final todays = ref.watch(todaysWorkoutProvider).value;
    final sessions = ref.watch(recentSessionsProvider).value ?? const <WorkoutSession>[];
    final stats = ref.watch(userStatsProvider).value;

    final lastDone = <String, DateTime>{};
    for (final s in sessions) {
      final id = s.workoutId;
      if (id != null && !lastDone.containsKey(id)) lastDone[id] = s.startTime;
    }
    final doneToday = todays != null &&
        sessions.any((s) => s.workoutId == todays.id && DateKeys.of(s.startTime) == DateKeys.today());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryCoral,
          onRefresh: () async {
            ref.invalidate(allWorkoutsProvider);
            ref.invalidate(recentSessionsProvider);
            ref.invalidate(weekSessionsProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const FitTrackrHeader(subtitle: 'Workouts'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Workout Plans',
                      style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Pill(
                    icon: LucideIcons.flame,
                    label: '${stats?.workoutsThisWeek ?? 0} this week',
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Workout history',
                    icon: const Icon(Icons.history, color: AppColors.textHeadline),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                    ),
                  ),
                ],
              ),
              Text('Guided routines with set logging and rest timers', style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              if (todays != null) ...[
                SectionHeader(title: "Today's plan", icon: LucideIcons.sparkles),
                const SizedBox(height: 8),
                WorkoutHeroPlanCard(
                  workout: todays,
                  subtitle: DateKeys.weekdayShort[DateTime.now().weekday - 1],
                  completed: doneToday,
                  onStart: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: todays)),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              const WeeklyScheduleCard(),
              const SizedBox(height: 18),
              SectionHeader(title: 'Workout Library', icon: LucideIcons.dumbbell),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final selected = f == _filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.primaryCoral,
                        backgroundColor: AppColors.surfaceContainer,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: selected ? Colors.white : AppColors.textBody,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              workoutsAsync.when(
                data: (workouts) {
                  final filtered = workouts.where(_matches).toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      icon: LucideIcons.search,
                      title: 'No routines in this category',
                      message: 'Try another filter.',
                    );
                  }
                  return Column(
                    children: filtered
                        .map((w) => WorkoutLibraryCard(workout: w, lastDone: lastDone[w.id]))
                        .toList(),
                  );
                },
                loading: () => const LoadingBlock(),
                error: (e, _) => ErrorCard(
                  message: 'Could not load workouts.',
                  onRetry: () => ref.invalidate(allWorkoutsProvider),
                ),
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }
}
