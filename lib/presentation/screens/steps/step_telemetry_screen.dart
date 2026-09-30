import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../providers/step_providers.dart';
import 'widgets/step_hero_gauge_card.dart';
import 'widgets/hourly_intensity_card.dart';
import 'widgets/step_streak_card.dart';

/// Step Counter & Progress Telemetry Screen matching FitTrackr design system.
class StepTelemetryScreen extends ConsumerWidget {
  const StepTelemetryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepStateAsync = ref.watch(todayStepProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const FitTrackrHeader(subtitle: 'Step Counter'),
              const SizedBox(height: 10),
              _buildDateSwitcher(),
              const SizedBox(height: 14),

              stepStateAsync.when(
                data: (data) => Column(
                  children: [
                    StepHeroGaugeCard(data: data),
                    const SizedBox(height: 14),
                    _buildMetricsRibbon(data),
                    const SizedBox(height: 14),
                    HourlyIntensityCard(currentSteps: data.stepCount),
                    const SizedBox(height: 14),
                    StepStreakCard(
                      streakDays: data.streakDays,
                      currentSteps: data.stepCount,
                      onSyncTap: () => ref.read(todayStepProvider.notifier).syncHealthConnect(),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primaryCoral),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              const SizedBox(height: 110), // Spacing for floating dock
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12B89988),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textBody),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 15, color: AppColors.primaryCoral),
              const SizedBox(width: 6),
              Text('Today', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Live',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildMetricsRibbon(dynamic data) {
    return Row(
      children: [
        _ribbonTile(
          icon: LucideIcons.ruler,
          val: MetricFormatter.formatDistanceKm(data.distanceMeters),
          unit: 'km',
          color: AppColors.primaryCoral,
          bgColor: AppColors.primaryCoralLight,
        ),
        const SizedBox(width: 8),
        _ribbonTile(
          icon: LucideIcons.flame,
          val: MetricFormatter.formatKcal(data.activeCalories),
          unit: 'kcal',
          color: AppColors.accentPink,
          bgColor: AppColors.accentPinkLight,
        ),
        const SizedBox(width: 8),
        _ribbonTile(
          icon: LucideIcons.timer,
          val: MetricFormatter.formatDurationMins(data.activeMinutes),
          unit: 'Active',
          color: AppColors.accentGreen,
          bgColor: AppColors.accentGreenLight,
        ),
        const SizedBox(width: 8),
        _ribbonTile(
          icon: LucideIcons.mountain,
          val: data.stepCount > 0 ? (data.stepCount / 250).toInt().toString() : '0',
          unit: 'Floors',
          color: AppColors.accentPurple,
          bgColor: AppColors.accentPurpleLight,
        ),
      ],
    );
  }

  Widget _ribbonTile({
    required IconData icon,
    required String val,
    required String unit,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.35)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10B89988),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              val,
              style: AppTypography.monoNumber(fontSize: 12, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              unit,
              style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textBody),
            ),
          ],
        ),
      ),
    );
  }
}
