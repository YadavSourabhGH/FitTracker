import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../../../../core/utils/metric_formatter.dart';
import '../../../common_widgets/ui_kit.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/nutrition_providers.dart';
import '../../../providers/shell_providers.dart';
import '../../../providers/step_providers.dart';
import '../../settings/health_connect_screen.dart';

/// 2x2 grid: hydration and nutrition (logged in-app) plus heart rate and
/// sleep (Health Connect). Unmeasured values are shown as "-".
class HealthOverviewRow extends ConsumerWidget {
  const HealthOverviewRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final water = ref.watch(waterTodayProvider).value ?? 0;
    final kcal = ref.watch(todayCaloriesProvider).value ?? 0;
    final vitals = ref.watch(healthSnapshotProvider).value;
    final hcOn = settings.healthConnectEnabled;
    final target = settings.calorieTarget;

    void openHc() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthConnectScreen()),
        );

    final hr = vitals?.avgHeartRate ?? vitals?.latestHeartRate;
    final sleep = vitals?.sleepMinutes;

    return Column(
      children: [
        SectionHeader(
          title: 'Health Overview',
          actionLabel: hcOn ? 'Health Connect' : 'Connect',
          onAction: openHc,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _HydrationCard(
                glasses: water,
                goal: settings.waterGoalGlasses,
                onAdd: () {
                  HapticUtil.light();
                  ref.read(waterTodayProvider.notifier).add(1);
                },
                onRemove: () => ref.read(waterTodayProvider.notifier).add(-1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.utensils,
                iconColor: AppColors.primaryCoral,
                iconBg: AppColors.primaryCoralLight,
                badge: '${(target - kcal).round().clamp(0, 99999)} left',
                title: 'Calories eaten',
                value: MetricFormatter.formatKcal(kcal),
                unit: 'kcal',
                progress: target <= 0 ? 0.0 : (kcal / target).clamp(0.0, 1.0).toDouble(),
                color: AppColors.primaryCoral,
                onTap: () => ref.read(shellTabProvider.notifier).select(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.heart,
                iconColor: AppColors.accentPink,
                iconBg: AppColors.accentPinkLight,
                badge: !hcOn ? 'Sync' : (hr == null ? 'No data' : 'Avg today'),
                title: 'Heart rate',
                value: hr?.toString() ?? '-',
                unit: 'bpm',
                onTap: openHc,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.moon,
                iconColor: AppColors.accentPurple,
                iconBg: AppColors.accentPurpleLight,
                badge: !hcOn ? 'Sync' : (sleep == null ? 'No data' : 'Last night'),
                title: 'Sleep',
                value: sleep == null ? '-' : MetricFormatter.formatDurationMins(sleep),
                unit: '',
                progress: sleep == null ? null : (sleep / 480).clamp(0.0, 1.0).toDouble(),
                color: AppColors.accentPurple,
                onTap: openHc,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String badge;
  final String title;
  final String value;
  final String unit;
  final double? progress;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badge,
    required this.title,
    required this.value,
    required this.unit,
    this.progress,
    this.color = AppColors.primaryCoral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBadge(icon: icon, color: iconColor, background: iconBg, size: 30, circle: false),
              const SizedBox(width: 4),
              Flexible(
                child: Pill(
                  label: badge,
                  background: AppColors.surfaceContainer,
                  foreground: AppColors.textBody,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.monoNumber(fontSize: 18, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: AppTypography.bodyMedium.copyWith(fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress ?? 0.0,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final int glasses;
  final int goal;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _HydrationCard({
    required this.glasses,
    required this.goal,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final segments = goal.clamp(1, 12);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                icon: LucideIcons.droplets,
                color: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
                size: 30,
                circle: false,
              ),
              const Spacer(),
              _roundBtn(Icons.remove, glasses > 0 ? onRemove : null),
              const SizedBox(width: 6),
              _roundBtn(Icons.add, onAdd),
            ],
          ),
          const SizedBox(height: 12),
          Text('Hydration', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$glasses', style: AppTypography.monoNumber(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Text('/ $goal glasses', style: AppTypography.bodyMedium.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(segments, (i) {
              final filled = i < glasses;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < segments - 1 ? 3 : 0),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.accentBlue : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.surfaceContainer : AppColors.accentBlueLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.textMuted : AppColors.accentBlue),
      ),
    );
  }
}
