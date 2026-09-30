import 'package:sqflite/sqflite.dart';

/// Pre-seeded scientific workout plans and verified exercise mechanics.
class WorkoutSeedData {
  static Future<void> seed(Database db) async {
    // 1. Insert Pre-made Programs
    await db.rawInsert('''
      INSERT INTO workouts (id, title, description, category, difficulty, estimatedMinutes) VALUES
      ('plan_ppl', 'Push / Pull / Legs (PPL)', 'High-volume hypertrophy split focused on progressive overload.', 'Hypertrophy', 'Intermediate', 60),
      ('plan_upper_lower', 'Upper / Lower Power', '4-day split emphasizing compound strength and recovery balance.', 'Strength', 'Intermediate', 55),
      ('plan_fullbody', 'Full Body Foundation', '3-day routine focusing on core compound movement mastery.', 'Strength', 'Beginner', 45),
      ('plan_c25k', 'Couch to 5K Endurance', 'Aerobic conditioning and running intervals.', 'Cardio', 'Beginner', 30),
      ('plan_hiit', 'Kettlebell & Bodyweight HIIT', 'High-intensity functional circuit for metabolic conditioning.', 'HIIT', 'Intermediate', 35);
    ''');

    // 2. Insert Core Exercises with Biomechanics
    await db.rawInsert('''
      INSERT INTO exercises (id, name, muscleGroup, secondaryMuscles, equipment, mechanicsType, setupInstructions, executionInstructions, commonMistakes, defaultRestSeconds) VALUES
      ('ex_bench', 'Barbell Bench Press', 'Chest', 'Triceps, Front Delts', 'Barbell', 'compound', 
       'Retract scapulae into bench, 5 points of contact, grip slightly wider than shoulders.', 
       'Lower under control to sternum with 45-deg elbow tuck; press explosively back.', 
       'Bouncing bar off ribcage, flaring elbows 90 degrees.', 120),
      ('ex_deadlift', 'Conventional Deadlift', 'Back', 'Hamstrings, Glutes', 'Barbell', 'compound', 
       'Bar over mid-foot, hinge hips back, grip outside shins, pack lats.', 
       'Push floor away, drive hips through at top without hyperextending.', 
       'Rounding lower back, letting bar drift away from shins.', 180),
      ('ex_squat', 'Barbell Back Squat', 'Quadriceps', 'Glutes, Hamstrings', 'Barbell', 'compound', 
       'Bar on upper traps, shoulder-width stance, toes 20-deg out, brace 360.', 
       'Break hips and knees, track knees over toes, hit depth below parallel.', 
       'Knees caving in, shifting weight to toes.', 180),
      ('ex_ohp', 'Overhead Barbell Press', 'Shoulders', 'Triceps, Upper Chest', 'Barbell', 'compound', 
       'Bar at collarbone, elbows slightly forward, squeeze glutes and abs.', 
       'Press vertically in straight path, move head through window at top.', 
       'Excessive backward lumbar hyperextension.', 120),
      ('ex_row', 'Barbell Bent-Over Row', 'Back', 'Biceps, Rear Delts', 'Barbell', 'compound', 
       'Hinge torso to 45 degrees, neutral spine, overhand grip.', 
       'Drive elbows back to ceiling, pull bar to belly button.', 
       'Jerking torso upward to heave weight.', 90),
      ('ex_incline_db', 'Incline Dumbbell Press', 'Chest', 'Anterior Deltoids, Triceps', 'Dumbbells', 'compound',
       'Set bench to 30 degrees, retract scapulae, plant feet.',
       'Lower dumbbells until upper arms parallel to floor, press upward.',
       'Arching back to change press angle.', 90),
      ('ex_lat_pulldown', 'Lat Pulldown', 'Back', 'Biceps, Forearms', 'Cable', 'compound',
       'Sit with thighs anchored, wide overhand grip on bar.',
       'Pull bar down to upper chest while depressing scapulae.',
       'Swinging torso excessively backward.', 90),
      ('ex_leg_press', '45-Degree Leg Press', 'Quadriceps', 'Glutes, Calves', 'Machine', 'compound',
       'Feet shoulder-width on platform, back pressed against seat.',
       'Lower weight until knees reach 90 degrees, press through heels.',
       'Locking knees forcefully at extension.', 90);
    ''');

    // 3. Link Exercises to Workouts
    await db.rawInsert('''
      INSERT INTO workout_exercises (id, workoutId, exerciseId, sortOrder, targetSets, targetReps, targetRpe, restSeconds) VALUES
      ('we_1', 'plan_ppl', 'ex_bench', 1, 4, '6-8', 8.0, 120),
      ('we_2', 'plan_ppl', 'ex_incline_db', 2, 3, '8-10', 8.5, 90),
      ('we_3', 'plan_ppl', 'ex_ohp', 3, 3, '8-10', 8.5, 90),
      ('we_4', 'plan_upper_lower', 'ex_bench', 1, 4, '5', 8.0, 150),
      ('we_5', 'plan_upper_lower', 'ex_row', 2, 4, '6', 8.0, 120),
      ('we_6', 'plan_upper_lower', 'ex_lat_pulldown', 3, 3, '10', 8.5, 90),
      ('we_7', 'plan_fullbody', 'ex_squat', 1, 3, '8', 8.0, 150),
      ('we_8', 'plan_fullbody', 'ex_bench', 2, 3, '8', 8.0, 120),
      ('we_9', 'plan_fullbody', 'ex_deadlift', 3, 3, '5', 8.0, 180);
    ''');
  }
}
