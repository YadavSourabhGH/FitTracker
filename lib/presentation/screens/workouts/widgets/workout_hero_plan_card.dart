import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/workout_model.dart';

/// Hero workout banner card matching Stitch "Today's Recommended Plan".
class WorkoutHeroPlanCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;

  const WorkoutHeroPlanCard({
    super.key,
    required this.workout,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22B89988),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDuiJH_s7qAVItk02tpKPkpN0vimmHAit51UkNf25uV_s7MbHJN3RR3MvD1IPNTNy7B0pIJ0s6PzbSqctg_Bplbugj64uc-KmIt1z5LjfbTWEddgJu4DdRAfdVrPCSP3teT_k1NY8g4wSVN3izTWUiAI-8TIbw-vW-SkelAkCwN3-iWYIg2pgFOLV0NBc0QsIe4doSC4JjoFKQLoHadVTeTFyyLZu2ynWXcF6w1LMlFidTr9-hMPKdt',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.primaryCoralDark),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${workout.exercises.length} exercises',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textHeadline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreenLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            workout.difficulty,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.bookmark, size: 16, color: AppColors.textHeadline),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 13, color: AppColors.primaryFixedDim),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedMinutes} min',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.flame, size: 13, color: AppColors.primaryFixedDim),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedCalories} kcal',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${workout.category}',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoral,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: onStart,
                      icon: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                      label: Text(
                        'Start Workout',
                        style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
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
