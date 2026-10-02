import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/workout_model.dart';
import '../../../common_widgets/icon_map.dart';
import '../../../common_widgets/ui_kit.dart';
import '../workout_detail_screen.dart';

/// Library list item.
class WorkoutLibraryCard extends StatelessWidget {
  final Workout workout;
  final DateTime? lastDone;

  const WorkoutLibraryCard({super.key, required this.workout, this.lastDone});

  @override
  Widget build(BuildContext context) {
    final last = lastDone;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
      ),
      child: Row(
        children: [
          IconBadge(
            icon: iconForCategory(workout.category),
            size: 52,
            iconSize: 22,
            circle: false,
            background: AppColors.surfaceContainerLow,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(
                      label: workout.difficulty,
                      background: AppColors.accentGreenLight,
                      foreground: AppColors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Pill(
                      label: workout.category,
                      background: AppColors.surfaceContainer,
                      foreground: AppColors.textBody,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(workout.title, style: AppTypography.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  last == null
                      ? '${workout.estimatedMinutes} min - ${workout.exercises.length} exercises - ${workout.totalSets} sets'
                      : '${workout.estimatedMinutes} min - last done ${last.day}/${last.month}',
                  style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textBody),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
