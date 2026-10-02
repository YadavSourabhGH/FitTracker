import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/haptic_feedback_util.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../common_widgets/floating_nav_bar.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/shell_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/step_providers.dart';
import '../../providers/workout_providers.dart';
import '../diet/diet_screen.dart';
import '../diet/food_search_modal.dart';
import '../insights/insights_screen.dart';
import '../steps/step_telemetry_screen.dart';
import '../workouts/active_workout_screen.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_plans_screen.dart';

/// Main scaffold hosting the floating dock and the four primary tabs.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> with WidgetsBindingObserver {
  static const _screens = [
    InsightsScreen(),
    WorkoutPlansScreen(),
    StepTelemetryScreen(),
    DietScreen(),
  ];

  String _day = DateKeys.today();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle != AppLifecycleState.resumed) return;
    final today = DateKeys.today();
    if (today != _day) {
      _day = today;
      ref.invalidate(todayStepProvider);
      ref.invalidate(waterTodayProvider);
      ref.invalidate(dietDateProvider);
      ref.invalidate(weekSessionsProvider);
    } else {
      ref.read(todayStepProvider.notifier).refresh();
    }
    ref.invalidate(userStatsProvider);
  }

  void _openQuickActions() {
    final todaysWorkout = ref.read(todaysWorkoutProvider).value;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick actions', style: AppTypography.titleLarge),
              const SizedBox(height: 10),
              _actionTile(
                LucideIcons.dumbbell,
                todaysWorkout == null ? 'Browse workouts' : "Start today's workout",
                todaysWorkout?.title ?? 'Pick a routine from the library',
                () {
                  Navigator.pop(ctx);
                  if (todaysWorkout == null) {
                    ref.read(shellTabProvider.notifier).select(1);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: todaysWorkout)),
                    );
                  }
                },
              ),
              _actionTile(LucideIcons.utensils, 'Log a meal', 'Search foods or pick a recent one', () {
                Navigator.pop(ctx);
                ref.read(shellTabProvider.notifier).select(3);
                showFoodSearch(context, ref, DateKeys.today());
              }),
              _actionTile(LucideIcons.droplets, 'Add a glass of water', '250 ml', () async {
                Navigator.pop(ctx);
                HapticUtil.light();
                await ref.read(waterTodayProvider.notifier).add(1);
                if (!mounted) return;
                final glasses = ref.read(waterTodayProvider).value ?? 0;
                showAppSnack(context, 'Water logged: $glasses glass${glasses == 1 ? '' : 'es'} today');
              }),
              _actionTile(LucideIcons.refreshCw, 'Refresh activity', 'Re-read the step sensor and Health Connect', () async {
                Navigator.pop(ctx);
                await ref.read(todayStepProvider.notifier).refresh();
                if (!mounted) return;
                final steps = ref.read(todayStepProvider).value?.stepCount ?? 0;
                showAppSnack(context, 'Activity refreshed: ${MetricFormatter.formatSteps(steps)} steps today');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: IconBadge(icon: icon, size: 40),
      title: Text(title, style: AppTypography.titleMedium),
      subtitle: Text(subtitle, style: AppTypography.bodyMedium),
      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(shellTabProvider);
    final active = ref.watch(activeWorkoutProvider);

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(shellTabProvider.notifier).select(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBase,
        body: Stack(
          children: [
            IndexedStack(index: index, children: _screens),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (active != null) _ResumeBanner(title: active.workout.title),
                    FloatingNavBar(
                      currentIndex: index,
                      onItemSelected: (i) => ref.read(shellTabProvider.notifier).select(i),
                      onActionTap: _openQuickActions,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  final String title;
  const _ResumeBanner({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Material(
        color: AppColors.textHeadline,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(LucideIcons.timer, color: AppColors.primaryFixedDim, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Workout in progress - $title',
                    style: AppTypography.titleMedium.copyWith(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Resume',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primaryFixedDim, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
