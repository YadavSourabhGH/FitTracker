import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/fitness_calc.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/workout_providers.dart';
import 'active_workout_screen.dart';

/// Ordered exercise list, technique cues and session start.
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  bool _starting = false;

  Future<void> _start() async {
    final active = ref.read(activeWorkoutProvider);
    if (active != null && active.workout.id != widget.workout.id) {
      final replace = await confirmDialog(
        context,
        title: 'Replace current workout?',
        message: '"${active.workout.title}" is still in progress. Starting a new session discards its unsaved sets.',
        confirmLabel: 'Start new',
        destructive: true,
      );
      if (!replace) return;
    }
    setState(() => _starting = true);
    try {
      await ref.read(activeWorkoutProvider.notifier).start(widget.workout);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()));
    } catch (e) {
      if (mounted) showAppSnack(context, 'Could not start workout: $e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final weight = ref.watch(settingsProvider).weightKg;
    final active = ref.watch(activeWorkoutProvider);
    final resuming = active != null && active.workout.id == workout.id;
    final kcal = FitnessCalc.metKcal(
      FitnessCalc.metForCategory(workout.category),
      weight,
      workout.estimatedMinutes * 60,
    );

    return Scaffold(
      appBar: AppBar(title: Text(workout.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Text(workout.description, style: AppTypography.bodyLarge),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge('${workout.estimatedMinutes} min', LucideIcons.clock),
                      _badge(workout.difficulty, LucideIcons.trendingUp),
                      _badge('${workout.exercises.length} exercises', LucideIcons.dumbbell),
                      _badge('~${kcal.round()} kcal', LucideIcons.flame),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Exercises', style: AppTypography.titleLarge),
                  const SizedBox(height: 10),
                  ...workout.exercises.asMap().entries.map((e) => _exerciseItem(e.key + 1, e.value)),
                  const SizedBox(height: 8),
                  Text(
                    'Calorie estimate uses MET values for ${workout.category.toLowerCase()} training and your body weight.',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _starting || workout.exercises.isEmpty ? null : _start,
                  icon: _starting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(LucideIcons.play, color: Colors.white, size: 18),
                  label: Text(resuming ? 'Resume session' : 'Start workout session'),
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

  Widget _exerciseItem(int number, WorkoutExercise we) {
    final ex = we.exercise;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () => showExerciseInfo(context, ex),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryCoralLight,
            child: Text('$number', style: AppTypography.monoNumber(fontSize: 12, color: AppColors.primaryCoral)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${we.targetLabel} - ${ex.muscleGroup} - rest ${we.restSeconds}s',
                  style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.info, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

/// Technique cues bottom sheet.
void showExerciseInfo(BuildContext context, Exercise ex) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(ex.name, style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Primary: ${ex.muscleGroup}${ex.secondaryMuscles.isEmpty ? '' : ' - Secondary: ${ex.secondaryMuscles}'}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text('Equipment: ${ex.equipment}', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            _cue('Setup', ex.setupInstructions, LucideIcons.target),
            _cue('Execution', ex.executionInstructions, LucideIcons.activity),
            _cue('Common mistakes', ex.commonMistakes, Icons.warning_amber_rounded, color: AppColors.accentPink),
          ],
        ),
      ),
    ),
  );
}

Widget _cue(String title, String body, IconData icon, {Color color = AppColors.primaryCoral}) {
  if (body.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium.copyWith(color: color)),
              const SizedBox(height: 2),
              Text(body, style: AppTypography.bodyLarge),
            ],
          ),
        ),
      ],
    ),
  );
}
