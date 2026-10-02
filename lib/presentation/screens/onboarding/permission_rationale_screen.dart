import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/health_connect_service.dart';
import '../../../data/services/notification_service.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/step_providers.dart';
import '../shell/main_shell_screen.dart';

/// Explains and requests the permissions FitTrackr uses.
class PermissionRationaleScreen extends ConsumerStatefulWidget {
  const PermissionRationaleScreen({super.key});

  @override
  ConsumerState<PermissionRationaleScreen> createState() => _PermissionRationaleScreenState();
}

class _PermissionRationaleScreenState extends ConsumerState<PermissionRationaleScreen> {
  bool _activity = false;
  bool _notifications = false;
  bool _health = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final activity = await Permission.activityRecognition.isGranted;
    final notif = await NotificationService.instance.areEnabled();
    if (!mounted) return;
    setState(() {
      _activity = activity;
      _notifications = notif;
    });
  }

  Future<void> _requestActivity() async {
    final status = await Permission.activityRecognition.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    await _refresh();
  }

  Future<void> _requestNotifications() async {
    final granted = await NotificationService.instance.requestPermission();
    if (mounted) setState(() => _notifications = granted);
  }

  Future<void> _connectHealth() async {
    final service = ref.read(healthConnectServiceProvider);
    final state = await service.getState();
    if (state == HealthConnectState.needsInstall) {
      await service.installOrUpdate();
      return;
    }
    if (state == HealthConnectState.unavailable) {
      if (mounted) showAppSnack(context, 'Health Connect is not available on this device.');
      return;
    }
    final granted = await service.requestPermissions() || await service.hasPermissions();
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).save(settings.copyWith(healthConnectEnabled: granted));
    if (mounted) setState(() => _health = granted);
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    await ref.read(settingsRepositoryProvider).setOnboardingDone(true);
    ref.invalidate(todayStepProvider);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const IconBadge(icon: LucideIcons.heartPulse, size: 64, iconSize: 32),
            const SizedBox(height: 20),
            Text('Connect your activity', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'FitTrackr only shows real measurements from your phone and connected apps - never simulated numbers. '
              'Choose what to allow; you can change this later in Settings.',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 24),
            _item(
              icon: LucideIcons.footprints,
              title: 'Physical activity (recommended)',
              body: 'Counts steps with your phone\'s low-power hardware step counter.',
              granted: _activity,
              onTap: _requestActivity,
            ),
            _item(
              icon: LucideIcons.bell,
              title: 'Notifications',
              body: 'Optional reminders for workouts, water and your step goal.',
              granted: _notifications,
              onTap: _requestNotifications,
            ),
            _item(
              icon: LucideIcons.refreshCw,
              title: 'Health Connect (optional)',
              body: 'Import steps, heart rate, sleep and SpO2 from Samsung Health, Google Fit or your watch.',
              granted: _health,
              onTap: _connectHealth,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'All data is stored locally on this device. No account required.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _finish,
                child: const Text('Get started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String body,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconBadge(icon: icon, size: 42, circle: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Text(body, style: AppTypography.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 8),
            granted
                ? const Icon(Icons.check_circle, color: AppColors.accentGreen)
                : TextButton(onPressed: onTap, child: const Text('Allow')),
          ],
        ),
      ),
    );
  }
}
