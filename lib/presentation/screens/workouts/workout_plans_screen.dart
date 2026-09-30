import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../providers/step_providers.dart';
import '../../providers/workout_providers.dart';
import 'workout_detail_screen.dart';
import 'widgets/workout_hero_plan_card.dart';
import 'widgets/weekly_schedule_card.dart';
import 'widgets/workout_library_card.dart';

/// Workout Plans Exploration & Catalog Screen matching FitTrackr design system.
class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Strength', 'HIIT & Cardio', 'Yoga & Flexibility', 'Beginner'];

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(allWorkoutsProvider);
    final streak = ref.watch(todayStepProvider).value?.streakDays ?? 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FitTrackrHeader(subtitle: 'Workouts'),
              const SizedBox(height: 10),
              _buildHeaderTitle(streak),
              const SizedBox(height: 14),
              _buildCategoryChips(),
              const SizedBox(height: 16),

              workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) return const SizedBox.shrink();
                  final heroWorkout = workouts.first;
                  final filtered = _selectedCategory == 'All'
                      ? workouts
                      : workouts.where((w) => w.category.toLowerCase().contains(_selectedCategory.toLowerCase().split(' ').first)).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primaryCoral),
                              const SizedBox(width: 6),
                              Text("Today's Recommended Plan", style: AppTypography.titleMedium),
                            ],
                          ),
                          Text(
                            'Personalized',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      WorkoutHeroPlanCard(
                        workout: heroWorkout,
                        onStart: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: heroWorkout)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const WeeklyScheduleCard(),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.dumbbell, size: 16, color: AppColors.primaryCoral),
                              const SizedBox(width: 6),
                              Text('Workout Library', style: AppTypography.titleLarge),
                            ],
                          ),
                          Text(
                            '${filtered.length} routines',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...filtered.map((w) => WorkoutLibraryCard(workout: w)),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primaryCoral),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error loading workouts: $e')),
              ),

              const SizedBox(height: 110), // Spacing for floating dock
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(int streak) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workout Plans', style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryCoralLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.flame, size: 13, color: AppColors.primaryCoral),
                  const SizedBox(width: 4),
                  Text(
                    streak > 0 ? '$streak Day Streak' : 'Start Streak',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoralDark, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('Explore guided routines tailored for your goals', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCoral : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textBody,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
