import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/workout_model.dart';
import '../../../common_widgets/icon_map.dart';

/// Hero banner for today's planned workout (drawn locally, no remote images).
class WorkoutHeroPlanCard extends StatelessWidget {
  final Workout workout;
  final String subtitle;
  final bool completed;
  final VoidCallback onStart;

  const WorkoutHeroPlanCard({
    super.key,
    required this.workout,
    required this.subtitle,
    required this.onStart,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A14), Color(0xFF5A2410), AppColors.primaryCoralDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33AD3300), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Icon(
              iconForCategory(workout.category),
              size: 170,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(subtitle, Colors.white.withValues(alpha: 0.92), AppColors.textHeadline),
                    _chip(workout.difficulty, AppColors.accentGreenLight, AppColors.onSecondaryContainer),
                    if (completed) _chip('Completed today', AppColors.accentGreen, Colors.white),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  workout.title,
                  style: AppTypography.headlineLarge.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  workout.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 13, color: AppColors.primaryFixedDim),
                    const SizedBox(width: 4),
                    Text('${workout.estimatedMinutes} min', style: _meta),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.dumbbell, size: 13, color: AppColors.primaryFixedDim),
                    const SizedBox(width: 4),
                    Text('${workout.exercises.length} exercises', style: _meta),
                    const SizedBox(width: 12),
                    Text(workout.category, style: _meta),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(64, 46)),
                    onPressed: onStart,
                    icon: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                    label: Text(completed ? 'Train again' : 'Start workout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final TextStyle _meta = AppTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9));

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}
