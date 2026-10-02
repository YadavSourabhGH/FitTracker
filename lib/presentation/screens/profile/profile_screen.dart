import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/fitness_calc.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/step_providers.dart';
import '../../providers/workout_providers.dart';
import '../progress/progress_analytics_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../settings/goal_sheets.dart';
import '../settings/settings_screen.dart';
import 'widgets/achievements_grid.dart';
import 'widgets/goal_overview_card.dart';

/// Athlete profile with real lifetime statistics and achievements.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _shareText(UserSettings s, UserStats st) {
    return 'My FitTrackr progress\n'
        'Level ${st.level} - ${st.totalWorkouts} workouts - ${MetricFormatter.compact(st.totalVolumeKg)} kg lifted\n'
        'Best day: ${MetricFormatter.formatSteps(st.bestStepDay)} steps - longest streak: ${st.longestStreak} days\n'
        'Tracked with FitTrackr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final stats = statsAsync.value ?? UserStats.empty;
    final achievements = ref.watch(achievementsProvider).value ?? const <Achievement>[];
    final prs = ref.watch(personalRecordsProvider).value ?? const <PersonalRecord>[];
    final today = ref.watch(todayStepProvider).value;
    final water = ref.watch(waterTodayProvider).value ?? 0;
    final todaySessions = (ref.watch(weekSessionsProvider).value ?? const <WorkoutSession>[])
        .where((s) => DateKeys.of(s.startTime) == DateKeys.today())
        .toList();
    final exerciseMinutes =
        todaySessions.fold<int>(0, (a, s) => a + s.durationSeconds ~/ 60) + (today?.activeMinutes ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Share progress',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => SharePlus.instance.share(ShareParams(text: _shareText(settings, stats))),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(LucideIcons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryCoral,
          onRefresh: () async {
            ref.invalidate(userStatsProvider);
            ref.invalidate(personalRecordsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _userCard(context, settings),
              const SizedBox(height: 16),
              _levelCard(settings, stats),
              const SizedBox(height: 16),
              GoalOverviewCard(
                streakDays: today?.streakDays ?? 0,
                weekDots: stats.weekActive,
                movePct: today?.progressPercentage ?? 0.0,
                exercisePct: (exerciseMinutes / 30 * 100).clamp(0, 100).toDouble(),
                hydrationPct: settings.waterGoalGlasses <= 0
                    ? 0.0
                    : (water / settings.waterGoalGlasses * 100).clamp(0, 100).toDouble(),
                onEditGoal: () => showStepGoalSheet(context, ref),
              ),
              const SizedBox(height: 20),
              AchievementsGrid(achievements: achievements),
              const SizedBox(height: 20),
              _statsGrid(stats),
              const SizedBox(height: 20),
              _personalBests(context, prs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard(BuildContext context, UserSettings s) {
    final bmi = s.bmi;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCoralLight,
                  boxShadow: [BoxShadow(color: Color(0x33FF5E3A), blurRadius: 18, offset: Offset(0, 6))],
                ),
                child: Text(
                  s.firstName.isEmpty ? 'A' : s.firstName[0].toUpperCase(),
                  style: AppTypography.displayLarge.copyWith(color: AppColors.primaryCoral),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: AppColors.primaryCoral, shape: BoxShape.circle),
                child: const Icon(LucideIcons.pencil, size: 12, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.name, style: AppTypography.titleLarge.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            '${s.goal.label} - ${s.activityLevel.label}',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _mini('${s.age}', 'years'),
              _mini('${s.heightCm.round()}', 'cm'),
              _mini(MetricFormatter.formatWeight(s.weightKg), 'kg'),
              _mini(bmi.toStringAsFixed(1), 'BMI - ${FitnessCalc.bmiCategory(bmi)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _levelCard(UserSettings s, UserStats stats) {
    return AppCard(
      child: Row(
        children: [
          const IconBadge(
            icon: LucideIcons.crown,
            color: Color(0xFFD97706),
            background: Color(0xFFFEF3C7),
            circle: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member since ${DateKeys.monthShort[s.memberSince.month - 1]} ${s.memberSince.year}',
                  style: AppTypography.titleMedium.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${stats.level}', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral)),
                    Text('${stats.xpIntoLevel}/1000 XP', style: AppTypography.monoNumber(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.xpIntoLevel / 1000,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryCoral),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'XP: 100 per workout, 5 per set, 50 per step-goal day, 20 per water-goal day, 5 per meal',
                  style: AppTypography.labelSmall.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(UserStats st) {
    final items = [
      ('Workouts', '${st.totalWorkouts}', LucideIcons.dumbbell),
      ('Total sets', '${st.totalSets}', LucideIcons.target),
      ('Volume', '${MetricFormatter.compact(st.totalVolumeKg)} kg', LucideIcons.barChart2),
      ('Best day', MetricFormatter.compact(st.bestStepDay), LucideIcons.footprints),
      ('Goal days', '${st.daysGoalHit}', LucideIcons.flag),
      ('Longest streak', '${st.longestStreak} d', LucideIcons.flame),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifetime stats', style: AppTypography.titleLarge),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: items
              .map((it) => AppCard(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconBadge(icon: it.$3, size: 30, iconSize: 15),
                        const SizedBox(height: 6),
                        FittedBox(
                          child: Text(it.$2, style: AppTypography.monoNumber(fontSize: 14, fontWeight: FontWeight.w800)),
                        ),
                        Text(it.$1, style: AppTypography.labelSmall, textAlign: TextAlign.center),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _personalBests(BuildContext context, List<PersonalRecord> prs) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Personal bests',
            actionLabel: 'Analytics',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          if (prs.isEmpty)
            Text(
              'Your best weighted sets will appear here once you log them.',
              style: AppTypography.bodyMedium,
            )
          else
            ...prs.take(5).map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(p.exerciseName, style: AppTypography.bodyLarge)),
                        Text(
                          '${MetricFormatter.formatWeight(p.bestWeightKg)} kg x ${p.repsAtBest}',
                          style: AppTypography.monoNumber(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
