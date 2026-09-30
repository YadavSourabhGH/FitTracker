import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Session live telemetry dashboard card from Stitch Workout Active Session.
class SessionTelemetryCard extends StatelessWidget {
  final int currentExerciseIndex;
  final int totalExercises;
  final int elapsedSeconds;
  final int totalEstimatedSeconds;
  final int caloriesBurned;
  final int targetCalories;

  const SessionTelemetryCard({
    super.key,
    required this.currentExerciseIndex,
    required this.totalExercises,
    required this.elapsedSeconds,
    required this.totalEstimatedSeconds,
    required this.caloriesBurned,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final remainingSecs = (totalEstimatedSeconds - elapsedSeconds) > 0 ? (totalEstimatedSeconds - elapsedSeconds) : 0;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final progress = totalExercises > 0 ? (currentExerciseIndex / totalExercises).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryCoralLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.timer, color: AppColors.primaryCoral, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REMAINING', style: AppTypography.labelSmall.copyWith(fontSize: 9, letterSpacing: 0.6)),
                      Text(timeStr, style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('BURNED', style: AppTypography.labelSmall.copyWith(fontSize: 9, letterSpacing: 0.6)),
                  RichText(
                    text: TextSpan(
                      text: '$caloriesBurned ',
                      style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryCoral),
                      children: [
                        TextSpan(
                          text: '/ $targetCalories kcal',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${currentExerciseIndex + 1} of $totalExercises',
                style: AppTypography.titleMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryCoral),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.accentPinkLight, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.heart, color: AppColors.accentPink, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('- bpm', style: AppTypography.monoNumber(fontSize: 12, fontWeight: FontWeight.w800)),
                          Text('No Sensor', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 9, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.accentGreenLight, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.dumbbell, color: AppColors.accentGreen, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active', style: AppTypography.titleMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
                          Text('Strength Focus', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
