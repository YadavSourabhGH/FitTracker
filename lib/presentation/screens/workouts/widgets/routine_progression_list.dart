import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';

/// Routine progression exercise item list matching Stitch design.
class RoutineProgressionList extends StatelessWidget {
  final List<WorkoutExercise> exercises;
  final int currentExerciseIndex;

  const RoutineProgressionList({
    super.key,
    required this.exercises,
    required this.currentExerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Routine Progression', style: AppTypography.titleLarge),
            Text('${exercises.length} Exercises', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          ],
        ),
        const SizedBox(height: 10),
        ...exercises.asMap().entries.map((entry) {
          final idx = entry.key;
          final we = entry.value;
          final isPast = idx < currentExerciseIndex;
          final isCurr = idx == currentExerciseIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.accentGreenLight
                        : (isCurr ? AppColors.primaryCoralLight : AppColors.surfaceContainerHigh),
                    shape: BoxShape.circle,
                  ),
                  child: isPast
                      ? const Icon(Icons.check, size: 14, color: AppColors.onSecondaryContainer)
                      : Center(
                          child: Text(
                            '${idx + 1}',
                            style: AppTypography.monoNumber(
                              fontSize: 11,
                              color: isCurr ? AppColors.primaryCoral : AppColors.textBody,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(we.exercise.name, style: AppTypography.titleMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('${we.targetSets} Sets × ${we.targetReps} Reps', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textBody)),
                    ],
                  ),
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accentGreenLight, borderRadius: BorderRadius.circular(8)),
                    child: Text('Done', style: AppTypography.labelSmall.copyWith(color: AppColors.onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.w700)),
                  )
                else if (isCurr)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryCoral, borderRadius: BorderRadius.circular(8)),
                    child: Text('Active', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
