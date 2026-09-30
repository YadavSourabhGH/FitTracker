import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../providers/workout_providers.dart';
import 'active_workout_screen.dart';

/// Screen displaying the ordered exercises and biomechanics of a workout plan.
class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  void _startWorkout(BuildContext context, WidgetRef ref) async {
    await ref.read(activeWorkoutProvider.notifier).startWorkout(workout);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textHeadline),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppColors.primaryCoralLight, shape: BoxShape.circle),
              child: const Icon(LucideIcons.flame, color: AppColors.primaryCoral, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                workout.title,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Text(workout.description, style: AppTypography.bodyLarge),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _badge('${workout.estimatedMinutes} mins', LucideIcons.clock),
                      const SizedBox(width: 8),
                      _badge(workout.difficulty, LucideIcons.trendingUp),
                      const SizedBox(width: 8),
                      _badge('${workout.exercises.length} Exercises', LucideIcons.dumbbell),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Exercises', style: AppTypography.titleLarge),
                  const SizedBox(height: 10),
                  ...workout.exercises.map((we) => _exerciseItem(context, we)),
                ],
              ),
            ),

            // Start Workout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _startWorkout(context, ref),
                icon: const Icon(LucideIcons.play, color: Colors.white, size: 18),
                label: Text(
                  'Start Workout Session',
                  style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _badge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryCoral),
          const SizedBox(width: 4),
          Text(text, style: AppTypography.labelSmall.copyWith(color: AppColors.textHeadline)),
        ],
      ),
    );
  }

  Widget _exerciseItem(BuildContext context, WorkoutExercise we) {
    final ex = we.exercise;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryCoralLight,
            child: Text('${we.sortOrder}', style: AppTypography.monoNumber(fontSize: 12, color: AppColors.primaryCoral)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${we.targetSets} sets × ${we.targetReps} reps • ${ex.muscleGroup}',
                  style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.info, color: AppColors.textMuted, size: 20),
            onPressed: () => _showFormCues(context, ex),
          ),
        ],
      ),
    );
  }

  void _showFormCues(BuildContext context, Exercise ex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ex.name, style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text('Target: ${ex.muscleGroup} (Secondary: ${ex.secondaryMuscles})', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            Text('Setup Cues', style: AppTypography.titleMedium),
            Text(ex.setupInstructions, style: AppTypography.bodyLarge),
            const SizedBox(height: 12),
            Text('Execution & Form', style: AppTypography.titleMedium),
            Text(ex.executionInstructions, style: AppTypography.bodyLarge),
            const SizedBox(height: 12),
            Text('Common Mistakes to Avoid', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral)),
            Text(ex.commonMistakes, style: AppTypography.bodyLarge),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
