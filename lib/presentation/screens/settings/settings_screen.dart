import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../common_widgets/ui_kit.dart';
import '../../../data/models/user_settings.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/step_providers.dart';
import '../../providers/workout_providers.dart';
import '../onboarding/onboarding_screen.dart';
import '../workouts/widgets/weekly_schedule_card.dart';
import 'edit_profile_screen.dart';
import 'goal_sheets.dart';
import 'health_connect_screen.dart';
import 'reminders_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(
      context,
      title: 'Reset all data?',
      message: 'This permanently deletes your profile, workouts, steps history, meals, water and weight logs '
          'from this device. This cannot be undone.',
      confirmLabel: 'Delete everything',
      destructive: true,
    );
    if (!ok) return;
    final defaults = UserSettings.defaults();
    await DatabaseHelper.instance.clearUserData();
    await SettingsRepository().clearAll();
    await ref.read(settingsProvider.notifier).save(defaults);
    await NotificationService.instance.applySettings(defaults);
    ref.invalidate(todayStepProvider);
    ref.invalidate(stepHistoryProvider);
    ref.invalidate(userStatsProvider);
    ref.invalidate(waterTodayProvider);
    ref.invalidate(mealsForDateProvider);
    ref.invalidate(recentSessionsProvider);
    ref.invalidate(weekSessionsProvider);
    ref.invalidate(personalRecordsProvider);
    ref.invalidate(scheduleProvider);
    ref.invalidate(weightHistoryProvider);
    ref.read(activeWorkoutProvider.notifier).discard();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            _group('Profile & goals', [
              _tile(LucideIcons.user, 'Edit profile', '${s.name} - ${s.age} y - ${s.heightCm.round()} cm - ${MetricFormatter.formatWeight(s.weightKg)} kg',
                  () => push(const EditProfileScreen())),
              _tile(LucideIcons.footprints, 'Daily step goal', '${MetricFormatter.formatSteps(s.stepGoal)} steps',
                  () => showStepGoalSheet(context, ref)),
              _tile(LucideIcons.droplets, 'Daily water goal', '${s.waterGoalGlasses} glasses (250 ml)',
                  () => showWaterGoalSheet(context, ref)),
              _tile(LucideIcons.calendar, 'Weekly workout plan', 'Assign workouts to weekdays',
                  () => showScheduleEditor(context, ref)),
            ]),
            _group('App', [
              _tile(LucideIcons.bell, 'Reminders', 'Workout, hydration and step reminders', () => push(const RemindersScreen())),
              _tile(LucideIcons.heartPulse, 'Data sources', s.healthConnectEnabled ? 'Phone sensor + Health Connect' : 'Phone sensor',
                  () => push(const HealthConnectScreen())),
            ]),
            _group('Privacy & data', [
              _tile(LucideIcons.shieldCheck, 'Privacy', 'All data stays on this device', () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Privacy'),
                    content: const Text(
                      'FitTrackr stores your profile, workouts, steps, meals and water logs only in a local database on this '
                      'device. There are no accounts, ads or analytics. Food searches are sent to the Open Food Facts public '
                      'API. Health Connect data is read-only and never leaves your phone.',
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                  ),
                );
              }),
              _tile(Icons.delete_forever_outlined, 'Reset all data', 'Delete everything and start over',
                  () => _resetAll(context, ref),
                  color: AppColors.accentPink),
            ]),
            _group('About', [
              _tile(LucideIcons.info, '${AppInfo.name} ${AppInfo.version}', 'Build ${AppInfo.build} - by ${AppInfo.author}', () {
                showAboutDialog(
                  context: context,
                  applicationName: AppInfo.name,
                  applicationVersion: '${AppInfo.version} (${AppInfo.build})',
                  applicationIcon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/branding/logo.png', width: 48, height: 48),
                  ),
                  children: const [
                    Text('Offline-first fitness tracker: steps, workouts, nutrition, hydration and progress analytics.'),
                    SizedBox(height: 8),
                    Text('Source: ${AppInfo.repoUrl}'),
                  ],
                );
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title.toUpperCase(), style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8)),
          ),
          AppCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap, {Color color = AppColors.primaryCoral}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: AppTypography.titleMedium.copyWith(color: color == AppColors.primaryCoral ? null : color)),
      subtitle: Text(subtitle, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
