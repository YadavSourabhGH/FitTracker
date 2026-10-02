import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../providers/app_providers.dart';

/// Bottom sheet with a slider to edit an integer goal.
Future<void> _showSliderSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required int initial,
  required int min,
  required int max,
  required int step,
  required String Function(int) format,
  required Future<void> Function(int) onSave,
}) {
  var value = initial.clamp(min, max);
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.bodyMedium),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  format(value),
                  style: AppTypography.monoNumber(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primaryCoral),
                ),
              ),
              Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min) ~/ step,
                onChanged: (v) => setSheet(() => value = ((v / step).round() * step).clamp(min, max)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await onSave(value);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showStepGoalSheet(BuildContext context, WidgetRef ref) {
  final s = ref.read(settingsProvider);
  return _showSliderSheet(
    context: context,
    title: 'Daily step goal',
    subtitle: '7,000-10,000 steps a day is associated with substantial health benefits.',
    initial: s.stepGoal,
    min: 2000,
    max: 30000,
    step: 500,
    format: (v) => MetricFormatter.formatSteps(v),
    onSave: (v) => ref.read(settingsProvider.notifier).save(ref.read(settingsProvider).copyWith(stepGoal: v)),
  );
}

Future<void> showWaterGoalSheet(BuildContext context, WidgetRef ref) {
  final s = ref.read(settingsProvider);
  return _showSliderSheet(
    context: context,
    title: 'Daily water goal',
    subtitle: 'Glasses of 250 ml. Most adults need about 2-3 litres of fluid per day.',
    initial: s.waterGoalGlasses,
    min: 4,
    max: 16,
    step: 1,
    format: (v) => '$v glasses',
    onSave: (v) =>
        ref.read(settingsProvider.notifier).save(ref.read(settingsProvider).copyWith(waterGoalGlasses: v)),
  );
}
