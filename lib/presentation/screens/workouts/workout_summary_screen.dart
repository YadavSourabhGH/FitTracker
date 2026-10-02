import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/workout_model.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/workout_providers.dart';

/// Post-workout recap with stats, records and share.
class WorkoutSummaryScreen extends ConsumerWidget {
  final WorkoutSummary summary;

  const WorkoutSummaryScreen({super.key, required this.summary});

  String _shareText(List<LoggedSet> sets) {
    final s = summary.session;
    final buffer = StringBuffer()
      ..writeln('Workout complete: ${s.title}')
      ..writeln('Duration ${MetricFormatter.formatClock(s.durationSeconds)} - ${s.setsCompleted} sets'
          '${s.totalVolumeKg > 0 ? ' - ${MetricFormatter.formatInt(s.totalVolumeKg)} kg volume' : ''}'
          ' - ~${s.caloriesBurned.round()} kcal');
    if (summary.newRecords.isNotEmpty) {
      buffer.writeln('New personal records: ${summary.newRecords.join(', ')}');
    }
    buffer.writeln('Tracked with FitTrackr');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = summary.session;
    final sets = ref.watch(sessionSetsProvider(s.id)).value ?? const <LoggedSet>[];
    final grouped = <String, List<LoggedSet>>{};
    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout complete'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => SharePlus.instance.share(ShareParams(text: _shareText(sets), subject: s.title)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(color: AppColors.accentGreenLight, shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events_outlined, size: 44, color: AppColors.accentGreen),
              ),
            ),
            const SizedBox(height: 12),
            Text(s.title, textAlign: TextAlign.center, style: AppTypography.headlineLarge),
            Text(
              'Great work! +${summary.xpEarned} XP',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _stat('Duration', MetricFormatter.formatClock(s.durationSeconds), LucideIcons.timer),
                const SizedBox(width: 8),
                _stat('Sets', '${s.setsCompleted}', LucideIcons.dumbbell),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _stat('Volume', '${MetricFormatter.formatInt(s.totalVolumeKg)} kg', LucideIcons.barChart2),
                const SizedBox(width: 8),
                _stat('Energy', '~${s.caloriesBurned.round()} kcal', LucideIcons.flame),
              ],
            ),
            if (summary.newRecords.isNotEmpty) ...[
              const SizedBox(height: 14),
              AppCard(
                child: Row(
                  children: [
                    const IconBadge(
                      icon: Icons.emoji_events_outlined,
                      color: AppColors.accentAmber,
                      background: Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New personal record${summary.newRecords.length > 1 ? 's' : ''}', style: AppTypography.titleMedium),
                          Text(summary.newRecords.join(', '), style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (grouped.isNotEmpty) Text('Sets logged', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            ...grouped.entries.map(
              (e) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: AppTypography.titleMedium),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: e.value.map((set) => Pill(label: _setLabel(set), background: AppColors.surfaceContainer, foreground: AppColors.textHeadline)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            ),
          ],
        ),
      ),
    );
  }

  static String _setLabel(LoggedSet set) {
    switch (set.trackingType) {
      case TrackingType.weightReps:
        return '${MetricFormatter.formatWeight(set.weightKg)} kg x ${set.reps}';
      case TrackingType.reps:
        return '${set.reps} reps';
      case TrackingType.time:
        return MetricFormatter.formatTimer(set.reps);
    }
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconBadge(icon: icon, size: 34, iconSize: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelSmall),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: AppTypography.monoNumber(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
