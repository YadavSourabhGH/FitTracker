import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/health_snapshot.dart';
import '../../../data/services/health_connect_service.dart';
import '../../../data/services/pedometer_service.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/step_providers.dart';

/// Data sources: phone step sensor and Android Health Connect.
class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  bool _busy = false;

  Future<void> _connect() async {
    setState(() => _busy = true);
    final service = ref.read(healthConnectServiceProvider);
    try {
      final state = await service.getState();
      if (state == HealthConnectState.needsInstall) {
        await service.installOrUpdate();
        return;
      }
      if (state == HealthConnectState.unavailable) {
        if (mounted) showAppSnack(context, 'Health Connect is not available on this device.');
        return;
      }
      final granted = await service.requestPermissions();
      final hasSteps = granted || await service.hasPermissions();
      final settings = ref.read(settingsProvider);
      await ref.read(settingsProvider.notifier).save(settings.copyWith(healthConnectEnabled: hasSteps));
      ref.invalidate(healthConnectPermissionProvider);
      ref.invalidate(healthSnapshotProvider);
      if (hasSteps) {
        await ref.read(todayStepProvider.notifier).refresh();
      }
      if (mounted) {
        showAppSnack(context, hasSteps ? 'Health Connect connected' : 'Permission was not granted');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).save(settings.copyWith(healthConnectEnabled: false));
    ref.invalidate(healthSnapshotProvider);
    if (mounted) showAppSnack(context, 'Health Connect sync turned off');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final hcState = ref.watch(healthConnectStateProvider);
    final permission = ref.watch(healthConnectPermissionProvider).value ?? false;
    final vitals = ref.watch(healthSnapshotProvider).value ?? HealthSnapshot.empty();
    final step = ref.watch(todayStepProvider).value;
    final sensor = step?.sensorStatus ?? SensorStatus.initializing;

    return Scaffold(
      appBar: AppBar(title: const Text('Data sources')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconBadge(icon: LucideIcons.footprints, size: 44, circle: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone step sensor', style: AppTypography.titleMedium),
                            Text(_sensorText(sensor), style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                      _statusDot(sensor == SensorStatus.active),
                    ],
                  ),
                  if (sensor == SensorStatus.permissionDenied) ...[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        final r = await ref.read(todayStepProvider.notifier).requestSensorPermission();
                        if (r == SensorStatus.permissionDenied) {
                          await ref.read(pedometerServiceProvider).openSettings();
                        }
                      },
                      child: const Text('Allow physical activity access'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconBadge(
                        icon: LucideIcons.heartPulse,
                        size: 44,
                        circle: false,
                        color: AppColors.accentPink,
                        background: AppColors.accentPinkLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Health Connect', style: AppTypography.titleMedium),
                            Text(
                              hcState.when(
                                data: (s) => switch (s) {
                                  HealthConnectState.available => settings.healthConnectEnabled && permission
                                      ? 'Connected - steps, heart rate, sleep and SpO2'
                                      : 'Available - not connected',
                                  HealthConnectState.needsInstall => 'Install or update Health Connect to continue',
                                  HealthConnectState.unavailable => 'Not supported on this device',
                                },
                                loading: () => 'Checking availability...',
                                error: (_, _) => 'Status unknown',
                              ),
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      _statusDot(settings.healthConnectEnabled && permission),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Samsung Health, Google Fit, Fitbit and most smartwatches sync into Health Connect. '
                    'FitTrackr only reads data - it never writes or uploads anything.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _busy ? null : _connect,
                          child: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(settings.healthConnectEnabled ? 'Re-check permissions' : 'Connect Health Connect'),
                        ),
                      ),
                      if (settings.healthConnectEnabled) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(onPressed: _disconnect, child: const Text('Turn off')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (settings.healthConnectEnabled) ...[
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest readings', style: AppTypography.titleLarge),
                    const SizedBox(height: 10),
                    _reading('Steps today', step == null ? '-' : MetricFormatter.formatSteps(step.stepCount)),
                    _reading('Heart rate (avg today)', vitals.avgHeartRate == null ? '-' : '${vitals.avgHeartRate} bpm'),
                    _reading('Heart rate (latest)', vitals.latestHeartRate == null ? '-' : '${vitals.latestHeartRate} bpm'),
                    _reading('Sleep (last night)',
                        vitals.sleepMinutes == null ? '-' : MetricFormatter.formatDurationMins(vitals.sleepMinutes!)),
                    _reading('Blood oxygen (latest)',
                        vitals.spo2Percent == null ? '-' : '${vitals.spo2Percent!.toStringAsFixed(0)} %'),
                    const SizedBox(height: 8),
                    Text('"-" means no data was recorded by a connected device.', style: AppTypography.labelSmall),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sensorText(SensorStatus s) {
    switch (s) {
      case SensorStatus.active:
        return 'Counting steps with the built-in pedometer';
      case SensorStatus.permissionDenied:
        return 'Physical activity permission is required';
      case SensorStatus.unavailable:
        return 'This device has no hardware step counter';
      case SensorStatus.initializing:
        return 'Starting...';
    }
  }

  Widget _statusDot(bool ok) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: ok ? AppColors.accentGreen : AppColors.cardBorder,
          shape: BoxShape.circle,
        ),
      );

  Widget _reading(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyLarge)),
          Text(value, style: AppTypography.monoNumber(fontSize: 13)),
        ],
      ),
    );
  }
}
