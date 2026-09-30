import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';

/// Active exercise hero focus card matching Stitch Workout Detail & Tracking.
class ActiveExerciseHeroCard extends StatelessWidget {
  final WorkoutExercise currentExercise;
  final int currentSetIndex;
  final int restSeconds;
  final VoidCallback onInfoTap;
  final VoidCallback onToggleRest;
  final VoidCallback onSkipRest;

  const ActiveExerciseHeroCard({
    super.key,
    required this.currentExercise,
    required this.currentSetIndex, required this.restSeconds,
    required this.onInfoTap, required this.onToggleRest, required this.onSkipRest,
  });

  @override
  Widget build(BuildContext context) {
    final ex = currentExercise.exercise;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryCoral, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE FOCUS',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(ex.name, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      'Focus on form and deep muscle activation',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.info, color: AppColors.textMuted, size: 20),
                onPressed: onInfoTap,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exercise Form Visual Banner
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDABK5vEiibbnrM7tW-hIog-1FYxargeAKzDYcXVj8sT8d1b7cr5JU6YadT3tTifhTpQFVvSYlpW_M97DcpZGsOZZJ_KfbPnmIghvhXhPMpuRi5Rhfu6KyVmme7YnXmRvzCcw1B7NLP0oOAS3svEEhu9txT3WD0CJEtA3cv9nBvT5VKGWjI_YzLYktBrSlnYJ31p1qhcOQa5ATnKngZv5LLe4kPxf2UF3XqfJCe2QGAQMDV8n7lVD3y',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppColors.surfaceContainer),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Target: ${ex.muscleGroup}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textHeadline, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Active Set Specifier
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.innerContainerDecoration,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set ${currentSetIndex + 1} of ${currentExercise.targetSets}', style: AppTypography.titleMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primaryCoralLight, borderRadius: BorderRadius.circular(10)),
                      child: Text('In Effort', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoralDark, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Text('TARGET REPS', style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                            Text(currentExercise.targetReps, style: AppTypography.monoNumber(fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Text('LOAD WEIGHT', style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                            Text('16 kg', style: AppTypography.monoNumber(fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.hourglass, size: 14, color: AppColors.primaryCoral),
                        const SizedBox(width: 6),
                        Text(
                          'Rest: ${restSeconds}s',
                          style: AppTypography.monoNumber(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onToggleRest,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text('Pause', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onSkipRest,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text('Skip', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
