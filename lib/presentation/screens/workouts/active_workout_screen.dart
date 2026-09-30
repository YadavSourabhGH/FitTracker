import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_feedback_util.dart';
import '../../../data/models/workout_model.dart';
import '../../providers/workout_providers.dart';
import 'widgets/session_telemetry_card.dart';
import 'widgets/active_exercise_hero_card.dart';
import 'widgets/routine_progression_list.dart';

/// Screen for live active set logging matching Stitch Workout Active Session.
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeWorkoutProvider);
    if (active == null || active.workout.exercises.isEmpty) {
      return const Scaffold(body: Center(child: Text('No active workout')));
    }

    final safeIdx = active.currentExerciseIndex.clamp(0, active.workout.exercises.length - 1);
    final currentExercise = active.workout.exercises[safeIdx];
    final sets = active.setLogs[currentExercise.exercise.id] ?? [];
    final currentSetIdx = sets.indexWhere((s) => !s.isCompleted);
    final activeSetNum = currentSetIdx == -1 ? (sets.isEmpty ? 0 : sets.length - 1) : currentSetIdx;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, active.workout.title),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildMetaBadges(active.workout),
                  const SizedBox(height: 12),
                  SessionTelemetryCard(
                    currentExerciseIndex: active.currentExerciseIndex,
                    totalExercises: active.workout.exercises.length,
                    elapsedSeconds: active.elapsedSeconds,
                    totalEstimatedSeconds: active.workout.estimatedMinutes * 60,
                    caloriesBurned: active.workout.estimatedMinutes > 0
                        ? ((active.elapsedSeconds / (active.workout.estimatedMinutes * 60)) * active.workout.estimatedCalories).toInt()
                        : 0,
                    targetCalories: active.workout.estimatedCalories,
                  ),
                  const SizedBox(height: 14),
                  ActiveExerciseHeroCard(
                    currentExercise: currentExercise,
                    currentSetIndex: activeSetNum,
                    restSeconds: active.restSecondsRemaining,
                    onInfoTap: () => _showFormCues(context, currentExercise.exercise),
                    onToggleRest: () => ref.read(activeWorkoutProvider.notifier).dismissRest(),
                    onSkipRest: () => ref.read(activeWorkoutProvider.notifier).dismissRest(),
                  ),
                  const SizedBox(height: 16),
                  RoutineProgressionList(
                    exercises: active.workout.exercises,
                    currentExerciseIndex: active.currentExerciseIndex,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildBottomBar(context, ref, active, currentExercise.exercise.id, activeSetNum),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textHeadline),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.primaryCoralLight, shape: BoxShape.circle),
            child: const Icon(LucideIcons.flame, color: AppColors.primaryCoral, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Workout Active Session',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBadges(Workout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryCoralLight, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('IN PROGRESS', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoralDark, fontWeight: FontWeight.w800, fontSize: 9)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
              child: Text(workout.difficulty, style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 9)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(workout.title, style: AppTypography.headlineLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(
          '${workout.estimatedMinutes} min duration • ${workout.estimatedCalories} kcal target • ${workout.category}',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
        ),
      ],
    );
  }


  Widget _buildBottomBar(BuildContext context, WidgetRef ref, dynamic active, String exId, int setIdx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.35))),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.pause, size: 18, color: AppColors.textHeadline),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(double.infinity, 44),
                elevation: 0,
              ),
              onPressed: () {
                HapticUtil.medium();
                if (setIdx >= 0) {
                  ref.read(activeWorkoutProvider.notifier).toggleSetComplete(exId, setIdx);
                }
              },
              icon: const Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
              label: Text('Log Set & Next', style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormCues(BuildContext context, Exercise ex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ex.name, style: AppTypography.headlineMedium),
          const SizedBox(height: 4),
          Text('Target: ${ex.muscleGroup}', style: AppTypography.bodyMedium),
          const SizedBox(height: 12),
          Text(ex.setupInstructions, style: AppTypography.bodyLarge),
        ]),
      ),
    );
  }
}

