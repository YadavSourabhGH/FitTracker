import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/fitness_calc.dart';
import '../../../core/utils/haptic_feedback_util.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/workout_providers.dart';
import 'workout_detail_screen.dart';
import 'workout_summary_screen.dart';

/// Live set logging with session clock, rest timer and progression.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _ticker;
  int? _focusSet;
  String? _focusExercise;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final s = ref.read(activeWorkoutProvider);
    if (s != null && s.isResting && !s.isPaused) {
      final left = s.restRemaining(DateTime.now());
      if (left <= 3 && left > 0) HapticUtil.light();
      if (left == 0) {
        HapticUtil.heavy();
        ref.read(activeWorkoutProvider.notifier).skipRest();
      }
    }
    setState(() {});
  }

  int _focusIndex(ActiveWorkoutState s, WorkoutExercise we) {
    final sets = s.setsFor(we);
    if (_focusExercise == we.id && _focusSet != null && _focusSet! < sets.length) return _focusSet!;
    final idx = sets.indexWhere((x) => !x.isCompleted);
    return idx == -1 ? (sets.isEmpty ? 0 : sets.length - 1) : idx;
  }

  Future<void> _finish(ActiveWorkoutState s) async {
    final remaining = s.totalSets - s.completedSets;
    if (remaining > 0) {
      final ok = await confirmDialog(
        context,
        title: 'Finish workout?',
        message: s.completedSets == 0
            ? 'No sets have been logged yet, so this session will be discarded.'
            : '$remaining set(s) are not completed. Only completed sets will be saved.',
        confirmLabel: 'Finish',
      );
      if (!ok || !mounted) return;
    }
    setState(() => _finishing = true);
    final settings = ref.read(settingsProvider);
    final summary = await ref.read(activeWorkoutProvider.notifier).finish(settings);
    ref.invalidate(userStatsProvider);
    if (!mounted) return;
    if (summary == null) {
      Navigator.pop(context);
      showAppSnack(context, 'Session discarded - no sets were logged');
      return;
    }
    HapticUtil.successPattern();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSummaryScreen(summary: summary)),
    );
  }

  Future<void> _discard() async {
    final ok = await confirmDialog(
      context,
      title: 'Discard workout?',
      message: 'All sets logged in this session will be deleted.',
      confirmLabel: 'Discard',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(activeWorkoutProvider.notifier).discard();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(activeWorkoutProvider);
    if (s == null || s.workout.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No active workout')),
      );
    }
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final now = DateTime.now();
    final elapsed = s.elapsedSeconds(now);
    final weight = ref.watch(settingsProvider).weightKg;
    final kcal = FitnessCalc.metKcal(FitnessCalc.metForCategory(s.workout.category), weight, elapsed);
    final we = s.currentExercise;
    final sets = s.setsFor(we);
    final focus = _focusIndex(s, we);
    final allDone = s.completedSets == s.totalSets && s.totalSets > 0;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.workout.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: s.isPaused ? 'Resume' : 'Pause',
              icon: Icon(s.isPaused ? LucideIcons.play : LucideIcons.pause),
              onPressed: notifier.togglePause,
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'discard') _discard();
                if (v == 'finish') _finish(s);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'finish', child: Text('Finish workout')),
                PopupMenuItem(value: 'discard', child: Text('Discard workout')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    _sessionCard(s, elapsed, kcal),
                    if (s.isResting) ...[
                      const SizedBox(height: 12),
                      _restBanner(s, now, notifier),
                    ],
                    const SizedBox(height: 14),
                    _exerciseCard(s, we, sets, focus, notifier),
                    const SizedBox(height: 16),
                    Text('Routine', style: AppTypography.titleLarge),
                    const SizedBox(height: 8),
                    ...s.workout.exercises.asMap().entries.map((e) => _routineItem(s, e.key, e.value, notifier)),
                  ],
                ),
              ),
              _bottomBar(s, we, sets, focus, allDone, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionCard(ActiveWorkoutState s, int elapsed, double kcal) {
    final progress = s.totalSets == 0 ? 0.0 : s.completedSets / s.totalSets;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: s.isPaused ? AppColors.accentAmber : AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.isPaused ? 'PAUSED' : 'ELAPSED',
                          style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Text(
                      MetricFormatter.formatClock(elapsed),
                      style: AppTypography.monoNumber(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _stat('${kcal.round()}', 'kcal'),
              const SizedBox(width: 14),
              _stat('${s.completedSets}/${s.totalSets}', 'sets'),
              const SizedBox(width: 14),
              _stat(MetricFormatter.compact(s.volumeKg), 'kg vol'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryCoral),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${s.currentExerciseIndex + 1} of ${s.workout.exercises.length}',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
              ),
              Text(
                '${(progress * 100).round()}% complete',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: AppTypography.monoNumber(fontSize: 15, fontWeight: FontWeight.w800)),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _restBanner(ActiveWorkoutState s, DateTime now, ActiveWorkoutNotifier notifier) {
    final left = s.restRemaining(now);
    final total = s.restTotalSeconds <= 0 ? 1 : s.restTotalSeconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryCoral,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x55FF5F25), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.timer, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Rest', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
              const SizedBox(width: 8),
              Text(
                MetricFormatter.formatTimer(left),
                style: AppTypography.monoNumber(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => notifier.addRest(30),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('+30s'),
              ),
              TextButton(
                onPressed: notifier.skipRest,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Skip'),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (left / total).clamp(0.0, 1.0).toDouble(),
              minHeight: 4,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(
    ActiveWorkoutState s,
    WorkoutExercise we,
    List<WorkoutSetLog> sets,
    int focus,
    ActiveWorkoutNotifier notifier,
  ) {
    final ex = we.exercise;
    final focusSet = sets.isEmpty ? null : sets[focus];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE EXERCISE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(ex.name, style: AppTypography.headlineMedium),
                    Text(
                      'Target ${we.targetLabel}${we.targetRpe != null ? ' @ RPE ${we.targetRpe!.toStringAsFixed(1)}' : ''} - ${ex.muscleGroup}',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Technique',
                icon: const Icon(LucideIcons.info, color: AppColors.textMuted),
                onPressed: () => showExerciseInfo(context, ex),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (focusSet != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.innerContainerDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set ${focus + 1}${focusSet.isCompleted ? ' (completed - edits are saved)' : ''}',
                    style: AppTypography.titleMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (ex.usesWeight) ...[
                        Expanded(
                          child: NumberStepper(
                            label: 'WEIGHT (KG)',
                            value: MetricFormatter.formatWeight(focusSet.weightKg),
                            onMinus: () => notifier.updateSet(we.id, focus, weightKg: focusSet.weightKg - 2.5),
                            onPlus: () => notifier.updateSet(we.id, focus, weightKg: focusSet.weightKg + 2.5),
                            onTapValue: () async {
                              final v = await promptNumber(context, title: 'Weight', initial: focusSet.weightKg, suffix: 'kg');
                              if (v != null) notifier.updateSet(we.id, focus, weightKg: v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: NumberStepper(
                          label: ex.isTimed ? 'SECONDS' : 'REPS',
                          value: '${focusSet.reps}',
                          onMinus: () => notifier.updateSet(we.id, focus, reps: focusSet.reps - (ex.isTimed ? 5 : 1)),
                          onPlus: () => notifier.updateSet(we.id, focus, reps: focusSet.reps + (ex.isTimed ? 5 : 1)),
                          onTapValue: () async {
                            final v = await promptNumber(
                              context,
                              title: ex.isTimed ? 'Seconds' : 'Reps',
                              initial: focusSet.reps.toDouble(),
                              decimal: false,
                            );
                            if (v != null) notifier.updateSet(we.id, focus, reps: v.round());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 40, child: Text('SET', style: AppTypography.labelSmall)),
              Expanded(child: Text(ex.usesWeight ? 'KG x REPS' : (ex.isTimed ? 'DURATION' : 'REPS'), style: AppTypography.labelSmall)),
              Text('DONE', style: AppTypography.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(sets.length, (i) {
            final set = sets[i];
            final isFocus = i == focus;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _focusExercise = we.id;
                _focusSet = i;
              }),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: set.isCompleted
                      ? AppColors.accentGreenLight.withValues(alpha: 0.45)
                      : (isFocus ? AppColors.primaryCoralLight.withValues(alpha: 0.5) : AppColors.surfaceContainerLow),
                  borderRadius: BorderRadius.circular(12),
                  border: isFocus ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.5)) : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text('${i + 1}', style: AppTypography.monoNumber(fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(
                        ex.usesWeight
                            ? '${MetricFormatter.formatWeight(set.weightKg)} x ${set.reps}'
                            : (ex.isTimed ? MetricFormatter.formatTimer(set.reps) : '${set.reps} reps'),
                        style: AppTypography.monoNumber(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: set.isCompleted ? 'Mark not done' : 'Mark done',
                      icon: Icon(
                        set.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: set.isCompleted ? AppColors.accentGreen : AppColors.textMuted,
                      ),
                      onPressed: () {
                        HapticUtil.medium();
                        if (set.isCompleted) {
                          notifier.uncompleteSet(we.id, i);
                        } else {
                          notifier.completeSet(we.id, i);
                          _focusSet = null;
                          _focusExercise = null;
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => notifier.addSet(we.id),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add set'),
              ),
              const Spacer(),
              if (sets.length > 1 && !sets.last.isCompleted)
                TextButton.icon(
                  onPressed: () => notifier.removeLastSet(we.id),
                  icon: const Icon(Icons.remove, size: 16, color: AppColors.textBody),
                  label: const Text('Remove set', style: TextStyle(color: AppColors.textBody)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routineItem(ActiveWorkoutState s, int index, WorkoutExercise we, ActiveWorkoutNotifier notifier) {
    final sets = s.setsFor(we);
    final done = sets.where((x) => x.isCompleted).length;
    final isCurrent = index == s.currentExerciseIndex;
    final complete = done == sets.length && sets.isNotEmpty;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: () {
        notifier.selectExercise(index);
        setState(() {
          _focusSet = null;
          _focusExercise = null;
        });
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: complete
                  ? AppColors.accentGreenLight
                  : (isCurrent ? AppColors.primaryCoralLight : AppColors.surfaceContainerHigh),
              shape: BoxShape.circle,
            ),
            child: complete
                ? const Icon(Icons.check, size: 14, color: AppColors.onSecondaryContainer)
                : Text(
                    '${index + 1}',
                    style: AppTypography.monoNumber(
                      fontSize: 11,
                      color: isCurrent ? AppColors.primaryCoral : AppColors.textBody,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(we.exercise.name, style: AppTypography.titleMedium.copyWith(fontSize: 12)),
                Text('${we.targetLabel} - $done/${sets.length} sets done', style: AppTypography.labelSmall),
              ],
            ),
          ),
          if (isCurrent)
            const Pill(label: 'Active', background: AppColors.primaryCoral, foreground: Colors.white)
          else if (complete)
            const Pill(label: 'Done', background: AppColors.accentGreenLight, foreground: AppColors.onSecondaryContainer),
        ],
      ),
    );
  }

  Widget _bottomBar(
    ActiveWorkoutState s,
    WorkoutExercise we,
    List<WorkoutSetLog> sets,
    int focus,
    bool allDone,
    ActiveWorkoutNotifier notifier,
  ) {
    final canLog = sets.isNotEmpty && !sets[focus].isCompleted;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.35))),
      ),
      child: Row(
        children: [
          Expanded(
            child: allDone || !canLog
                ? ElevatedButton.icon(
                    onPressed: _finishing ? null : () => _finish(s),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                    icon: const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
                    label: Text(allDone ? 'Finish workout' : 'Finish early'),
                  )
                : ElevatedButton.icon(
                    onPressed: s.isPaused
                        ? null
                        : () {
                            HapticUtil.medium();
                            notifier.completeSet(we.id, focus);
                            setState(() {
                              _focusSet = null;
                              _focusExercise = null;
                            });
                          },
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: Text('Log set ${focus + 1} of ${sets.length}'),
                  ),
          ),
          if (!allDone && canLog) ...[
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _finishing ? null : () => _finish(s),
              child: const Text('Finish'),
            ),
          ],
        ],
      ),
    );
  }
}
