import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../providers/profile_providers.dart';
import '../../providers/step_providers.dart';
import 'widgets/quick_metrics_grid.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/health_overview_row.dart';
import 'widgets/coach_insight_banner.dart';

/// Fitness Dashboard matching FitTrackr design system.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepStateAsync = ref.watch(todayStepProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final athleteName = profileAsync.value?.name.split(' ').first ?? 'Athlete';
    final stepCount = stepStateAsync.value?.stepCount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryCoral,
          onRefresh: () => ref.read(todayStepProvider.notifier).syncHealthConnect(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FitTrackrHeader(subtitle: 'Dashboard'),
                const SizedBox(height: 10),
                _buildGreetingSection(athleteName, stepCount),
                const SizedBox(height: 16),

                stepStateAsync.when(
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
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primaryCoral),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 16),
                const HealthOverviewRow(),
                const SizedBox(height: 16),
                CoachInsightBanner(stepCount: stepCount),
                const SizedBox(height: 110), // Spacing for floating navigation dock
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String athleteName, int steps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                steps > 0 ? 'Great job, $athleteName' : 'Welcome, $athleteName',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                steps > 0
                    ? '${MetricFormatter.formatSteps(steps)} live steps recorded today.'
                    : 'Track your daily steps and organize workouts.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textBody, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10B89988),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This Week',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textBody),
            ],
          ),
        ),
      ],
    );
  }
}
