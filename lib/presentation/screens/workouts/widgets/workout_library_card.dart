import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';
import '../workout_detail_screen.dart';

/// Card for library workout items in WorkoutPlansScreen.
class WorkoutLibraryCard extends StatelessWidget {
  final Workout workout;

  const WorkoutLibraryCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surfaceContainerLow,
              ),
              child: const Icon(LucideIcons.play, color: AppColors.primaryCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          workout.difficulty,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSecondaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    workout.title,
                    style: AppTypography.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${workout.estimatedMinutes} min • ${workout.estimatedCalories} kcal',
                    style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textBody),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
