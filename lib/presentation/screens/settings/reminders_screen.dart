import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/services/notification_service.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';

/// Daily reminder preferences (local notifications, no account needed).
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool? _permission;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.areEnabled().then((v) {
      if (mounted) setState(() => _permission = v);
    });
  }

  Future<void> _update(UserSettings next) async {
    final enabling = (next.workoutReminderEnabled || next.waterReminderEnabled || next.stepNudgeEnabled);
    if (enabling && _permission != true) {
      final granted = await NotificationService.instance.requestPermission();
      if (mounted) setState(() => _permission = granted);
      if (!granted) {
        if (mounted) showAppSnack(context, 'Allow notifications in system settings to receive reminders.');
        return;
      }
    }
    await ref.read(settingsProvider.notifier).save(next);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final time = TimeOfDay(hour: s.workoutReminderHour, minute: s.workoutReminderMinute);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            if (_permission == false)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      const IconBadge(icon: Icons.notifications_off_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications are currently blocked for FitTrackr.',
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final granted = await NotificationService.instance.requestPermission();
                          if (mounted) setState(() => _permission = granted);
                        },
                        child: const Text('Allow'),
                      ),
                    ],
                  ),
                ),
              ),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const IconBadge(icon: LucideIcons.dumbbell),
                    title: Text('Workout reminder', style: AppTypography.titleMedium),
                    subtitle: Text('Daily at ${time.format(context)}', style: AppTypography.bodyMedium),
                    value: s.workoutReminderEnabled,
                    onChanged: (v) => _update(s.copyWith(workoutReminderEnabled: v)),
                  ),
                  ListTile(
                    enabled: s.workoutReminderEnabled,
                    leading: const SizedBox(width: 36),
                    title: Text('Reminder time', style: AppTypography.bodyLarge),
                    trailing: Text(time.format(context), style: AppTypography.monoNumber(fontSize: 14)),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: time);
                      if (picked != null) {
                        await _update(s.copyWith(
                          workoutReminderHour: picked.hour,
                          workoutReminderMinute: picked.minute,
                        ));
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const IconBadge(
                      icon: LucideIcons.droplets,
                      color: AppColors.accentBlue,
                      background: AppColors.accentBlueLight,
                    ),
                    title: Text('Hydration reminders', style: AppTypography.titleMedium),
                    subtitle: Text('Every 2 hours from 9 AM to 7 PM', style: AppTypography.bodyMedium),
                    value: s.waterReminderEnabled,
                    onChanged: (v) => _update(s.copyWith(waterReminderEnabled: v)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const IconBadge(
                      icon: LucideIcons.footprints,
                      color: AppColors.accentGreen,
                      background: AppColors.accentGreenLight,
                    ),
                    title: Text('Evening step check-in', style: AppTypography.titleMedium),
                    subtitle: Text('Daily at 8:00 PM', style: AppTypography.bodyMedium),
                    value: s.stepNudgeEnabled,
                    onChanged: (v) => _update(s.copyWith(stepNudgeEnabled: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reminders are scheduled on this device and work offline. You will also get a notification when you reach your daily step goal.',
              style: AppTypography.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
