import 'package:flutter_test/flutter_test.dart';
import 'package:fittrackr/core/utils/date_keys.dart';
import 'package:fittrackr/core/utils/fitness_calc.dart';
import 'package:fittrackr/core/utils/metric_formatter.dart';
import 'package:fittrackr/data/models/step_record_model.dart';
import 'package:fittrackr/data/models/user_settings.dart';
import 'package:fittrackr/data/repositories/step_repository.dart';

void main() {
  group('FitnessCalc', () {
    test('Mifflin-St Jeor BMR', () {
      expect(FitnessCalc.bmr(weightKg: 70, heightCm: 170, age: 25, isMale: true), closeTo(1642.5, 0.01));
      expect(FitnessCalc.bmr(weightKg: 60, heightCm: 165, age: 30, isMale: false), closeTo(1320.25, 0.01));
    });

    test('Epley 1RM', () {
      expect(FitnessCalc.epley1Rm(100, 1), 100);
      expect(FitnessCalc.epley1Rm(100, 10), closeTo(133.33, 0.01));
      expect(FitnessCalc.epley1Rm(0, 5), 0);
    });

    test('parses targets', () {
      expect(FitnessCalc.parseLeadingInt('6-8'), 6);
      expect(FitnessCalc.parseLeadingInt('30s'), 30);
      expect(FitnessCalc.parseLeadingInt('max', fallback: 9), 9);
    });

    test('distance scales with height', () {
      expect(FitnessCalc.distanceMeters(1000, 180), greaterThan(FitnessCalc.distanceMeters(1000, 160)));
    });
  });

  group('DateKeys', () {
    test('format and shift across months', () {
      expect(DateKeys.of(DateTime(2026, 1, 5)), '2026-01-05');
      expect(DateKeys.shift('2026-03-01', -1), '2026-02-28');
      expect(DateKeys.shift('2024-12-31', 1), '2025-01-01');
    });

    test('lastNDays ends today', () {
      final days = DateKeys.lastNDays(7);
      expect(days.length, 7);
      expect(days.last, DateKeys.today());
    });
  });

  group('UserSettings', () {
    test('macro targets add up to the calorie target', () {
      final s = UserSettings.defaults().copyWith(weightKg: 80, goal: FitnessGoal.gain);
      final m = s.macroTargets;
      final kcal = m.targetProteinGrams * 4 + m.targetCarbsGrams * 4 + m.targetFatGrams * 9;
      expect(kcal, closeTo(m.targetCalories, 1));
      expect(m.targetProteinGrams, closeTo(160, 0.01));
    });

    test('calorie target never drops below the safety floor', () {
      final s = UserSettings.defaults().copyWith(weightKg: 40, heightCm: 140, age: 80, goal: FitnessGoal.lose);
      expect(s.calorieTarget, greaterThanOrEqualTo(1500));
    });
  });

  test('longest streak counts consecutive goal days', () {
    DailyStepRecord r(String d, int s) => DailyStepRecord(
          dateString: d,
          stepCount: s,
          distanceMeters: 0,
          activeCalories: 0,
          source: 'HARDWARE_SENSOR',
          syncedAt: DateTime(2026),
        );
    final days = [
      r('2026-01-01', 9000),
      r('2026-01-02', 9000),
      r('2026-01-03', 100),
      r('2026-01-04', 9000),
      r('2026-01-05', 9000),
      r('2026-01-06', 9000),
      r('2026-01-08', 9000),
    ];
    expect(StepRepository.longestStreak(days, 8000), 3);
  });

  test('metric formatting', () {
    expect(MetricFormatter.formatSteps(12345), '12,345');
    expect(MetricFormatter.formatClock(3725), '1:02:05');
    expect(MetricFormatter.formatWeight(62.5), '62.5');
    expect(MetricFormatter.formatWeight(60), '60');
    expect(MetricFormatter.compact(12500), '12.5k');
  });
}
