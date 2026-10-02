import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fittrackr/core/utils/date_keys.dart';
import 'package:fittrackr/data/local/database_helper.dart';
import 'package:fittrackr/data/models/nutrition_model.dart';
import 'package:fittrackr/data/models/workout_model.dart';
import 'package:fittrackr/data/repositories/hydration_repository.dart';
import 'package:fittrackr/data/repositories/nutrition_repository.dart';
import 'package:fittrackr/data/repositories/step_repository.dart';
import 'package:fittrackr/data/repositories/workout_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
  });

  tearDownAll(() => DatabaseHelper.instance.close());

  test('seeded library has exercises for every workout', () async {
    final workouts = await WorkoutRepository().getAllWorkouts();
    expect(workouts.length, greaterThanOrEqualTo(8));
    for (final w in workouts) {
      expect(w.exercises, isNotEmpty, reason: w.title);
    }
  });

  test('session volume, PRs and history', () async {
    final repo = WorkoutRepository();
    final workout = (await repo.getAllWorkouts()).firstWhere((w) => w.id == 'plan_push');
    final sessionId = await repo.startSession(workout);
    final bench = workout.exercises.first;
    await repo.upsertSet(
      sessionId,
      WorkoutSetLog(id: 's1', exerciseId: bench.exercise.id, setNumber: 1, weightKg: 60, reps: 8, isCompleted: true),
    );
    await repo.upsertSet(
      sessionId,
      WorkoutSetLog(id: 's2', exerciseId: bench.exercise.id, setNumber: 2, weightKg: 62.5, reps: 6, isCompleted: true),
    );
    final session = await repo.finishSession(sessionId: sessionId, durationSeconds: 1800, caloriesBurned: 200);
    expect(session.totalVolumeKg, closeTo(60 * 8 + 62.5 * 6, 0.01));
    expect(session.setsCompleted, 2);
    expect(session.isCompleted, isTrue);

    final prs = await repo.personalRecords();
    expect(prs.first.exerciseId, bench.exercise.id);
    expect((await repo.completedSessions()).length, 1);
    expect((await repo.setsForSession(sessionId)).length, 2);
  });

  test('steps, hourly buckets, meals and water persist', () async {
    final steps = StepRepository();
    final today = DateKeys.today();
    await steps.addHourly(today, 9, 120);
    await steps.addHourly(today, 9, 30);
    final hourly = await steps.getHourly(today);
    expect(hourly[9].steps, 150);

    final nutrition = NutritionRepository();
    await nutrition.addMeal(
      const NutritionItem(
        id: 'm1',
        name: 'Oats',
        brand: '',
        servingSize: 40,
        servingUnit: 'g',
        calories: 152,
        proteinGrams: 5.3,
        carbsGrams: 27.2,
        fatGrams: 2.6,
        mealType: 'Breakfast',
      ),
      today,
    );
    expect((await nutrition.getLoggedMeals(today)).single.name, 'Oats');
    expect((await nutrition.calorieTotals([today]))[today], closeTo(152, 0.01));

    final water = HydrationRepository();
    await water.setGlasses(today, 5);
    expect(await water.getGlasses(today), 5);
  });
}
