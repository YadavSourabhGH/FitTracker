import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/icon_map.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/workout_providers.dart';

/// Chronological list of completed sessions with set details.
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: SafeArea(
        child: sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: EmptyState(
                  icon: LucideIcons.dumbbell,
                  title: 'No completed workouts yet',
                  message: 'Start a workout from the Workouts tab. Finished sessions are saved here.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: sessions.length,
              itemBuilder: (context, i) => _SessionTile(session: sessions[i]),
            );
          },
          loading: () => const LoadingBlock(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: ErrorCard(message: '$e', onRetry: () => ref.invalidate(recentSessionsProvider)),
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerStatefulWidget {
  final WorkoutSession session;
  const _SessionTile({required this.session});

  @override
  ConsumerState<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends ConsumerState<_SessionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final time = TimeOfDay.fromDateTime(s.startTime).format(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: iconForCategory(s.category), size: 40, circle: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: AppTypography.titleMedium),
                    Text(
                      '${DateKeys.relativeLabel(DateKeys.of(s.startTime))}, $time',
                      style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(label: MetricFormatter.formatClock(s.durationSeconds), icon: LucideIcons.timer),
              Pill(label: '${s.setsCompleted} sets', icon: LucideIcons.dumbbell),
              if (s.totalVolumeKg > 0) Pill(label: '${MetricFormatter.formatInt(s.totalVolumeKg)} kg', icon: LucideIcons.barChart2),
              Pill(label: '~${s.caloriesBurned.round()} kcal', icon: LucideIcons.flame),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _SetsList(sessionId: s.id),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Delete session?',
                    message: 'This removes the session and its sets from your history and statistics.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (!ok) return;
                  await ref.read(workoutRepositoryProvider).deleteSession(s.id);
                  ref.invalidate(recentSessionsProvider);
                  ref.invalidate(weekSessionsProvider);
                  ref.invalidate(personalRecordsProvider);
                  ref.invalidate(userStatsProvider);
                },
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.accentPink),
                label: const Text('Delete', style: TextStyle(color: AppColors.accentPink)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetsList extends ConsumerWidget {
  final String sessionId;
  const _SetsList({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(sessionSetsProvider(sessionId)).value;
    if (sets == null) return const LoadingBlock(height: 40);
    if (sets.isEmpty) return Text('No sets recorded.', style: AppTypography.bodyMedium);
    final grouped = <String, List<LoggedSet>>{};
    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((e) {
        final text = e.value.map((x) {
          switch (x.trackingType) {
            case TrackingType.weightReps:
              return '${MetricFormatter.formatWeight(x.weightKg)}x${x.reps}';
            case TrackingType.reps:
              return '${x.reps}';
            case TrackingType.time:
              return MetricFormatter.formatTimer(x.reps);
          }
        }).join('  ');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: Text(e.key, style: AppTypography.titleMedium.copyWith(fontSize: 12))),
              Expanded(flex: 3, child: Text(text, style: AppTypography.monoNumber(fontSize: 11, fontWeight: FontWeight.w500))),
            ],
          ),
        );
      }).toList(),
    );
  }
}
