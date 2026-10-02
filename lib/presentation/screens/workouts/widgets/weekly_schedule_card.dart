import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_keys.dart';
import '../../../../data/models/workout_model.dart';
import '../../../common_widgets/ui_kit.dart';
import '../../../providers/workout_providers.dart';
import '../workout_detail_screen.dart';

enum _Status { completed, ready, upcoming, missed, rest }

/// Weekly plan (Monday to Sunday) with real completion status.
class WeeklyScheduleCard extends ConsumerWidget {
  const WeeklyScheduleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider).value ?? const <int, String>{};
    final workouts = ref.watch(allWorkoutsProvider).value ?? const <Workout>[];
    final sessions = ref.watch(weekSessionsProvider).value ?? const <WorkoutSession>[];
    final byId = {for (final w in workouts) w.id: w};
    final doneDays = sessions.map((s) => s.startTime.weekday).toSet();
    final today = DateTime.now().weekday;
    final monday = DateKeys.startOfWeek(DateTime.now());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Weekly Plan',
            icon: LucideIcons.calendar,
            actionLabel: 'Adjust plan',
            onAction: () => showScheduleEditor(context, ref),
          ),
          const SizedBox(height: 12),
          ...List.generate(7, (i) {
            final weekday = i + 1;
            final id = schedule[weekday] ?? 'rest';
            final w = byId[id];
            final date = DateTime(monday.year, monday.month, monday.day + i);
            final _Status status;
            if (doneDays.contains(weekday)) {
              status = _Status.completed;
            } else if (w == null) {
              status = _Status.rest;
            } else if (weekday == today) {
              status = _Status.ready;
            } else if (weekday < today) {
              status = _Status.missed;
            } else {
              status = _Status.upcoming;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _item(context, DateKeys.weekdayShort[i].toUpperCase(), date, w, status),
            );
          }),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String day, DateTime date, Workout? w, _Status status) {
    final isReady = status == _Status.ready;
    final isDone = status == _Status.completed;
    return Material(
      color: isReady ? AppColors.primaryCoralLight.withValues(alpha: 0.4) : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: w == null
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isReady ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isReady ? AppColors.primaryCoral : (isDone ? AppColors.accentGreenLight : AppColors.surfaceContainer),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day,
                      style: AppTypography.monoNumber(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isReady ? Colors.white : (isDone ? AppColors.onSecondaryContainer : AppColors.textBody),
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        color: isReady ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w?.title ?? 'Rest & recovery',
                      style: AppTypography.titleMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      w == null ? 'Light walk or stretching' : '${w.estimatedMinutes} min - ${w.category}',
                      style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              _badge(status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(_Status status) {
    switch (status) {
      case _Status.completed:
        return const Pill(
          label: 'Done',
          icon: Icons.check,
          background: AppColors.accentGreenLight,
          foreground: AppColors.onSecondaryContainer,
        );
      case _Status.ready:
        return const Pill(label: 'Today', icon: LucideIcons.play, background: Colors.white);
      case _Status.missed:
        return const Pill(label: 'Missed', background: AppColors.surfaceContainer, foreground: AppColors.textMuted);
      case _Status.rest:
        return const Pill(label: 'Rest', background: AppColors.surfaceContainer, foreground: AppColors.textBody);
      case _Status.upcoming:
        return const Pill(label: 'Upcoming', background: AppColors.surfaceContainerHigh, foreground: AppColors.textBody);
    }
  }
}

/// Lets the user assign a workout (or rest) to each weekday.
Future<void> showScheduleEditor(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final schedule = ref.watch(scheduleProvider).value ?? const <int, String>{};
        final workouts = ref.watch(allWorkoutsProvider).value ?? const <Workout>[];
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Text('Adjust weekly plan', style: AppTypography.headlineMedium),
                const SizedBox(height: 4),
                Text('Choose a workout or a rest day for each weekday.', style: AppTypography.bodyMedium),
                const SizedBox(height: 12),
                ...List.generate(7, (i) {
                  final weekday = i + 1;
                  final current = schedule[weekday] ?? 'rest';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(DateKeys.weekdayShort[i], style: AppTypography.titleMedium),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: workouts.any((w) => w.id == current) ? current : 'rest',
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem(value: 'rest', child: Text('Rest day')),
                              ...workouts.map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(w.title, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) ref.read(scheduleProvider.notifier).setDay(weekday, v);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
