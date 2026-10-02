import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

/// Persists the athlete profile, goals and preferences.
class SettingsRepository {
  static const _kOnboarding = 'onboarding_completed';

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarding) ?? false;
  }

  Future<void> setOnboardingDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, done);
  }

  Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final d = UserSettings.defaults();
    final goalRaw = prefs.getString('user_goal') ?? d.goal.name;
    final goal = FitnessGoal.values.firstWhere(
      (g) => g.name == goalRaw,
      orElse: () => FitnessGoal.maintain,
    );
    final sinceRaw = prefs.getString('member_since');
    var since = sinceRaw == null ? null : DateTime.tryParse(sinceRaw);
    if (since == null) {
      since = DateTime.now();
      await prefs.setString('member_since', since.toIso8601String());
    }

    return UserSettings(
      name: prefs.getString('user_name') ?? d.name,
      // 'user_gender' is the v1.0 key.
      sex: prefs.getString('user_sex') ?? prefs.getString('user_gender') ?? d.sex,
      age: prefs.getInt('user_age') ?? d.age,
      heightCm: prefs.getDouble('user_height_cm') ?? d.heightCm,
      weightKg: prefs.getDouble('user_weight') ?? d.weightKg,
      stepGoal: prefs.getInt('user_step_goal') ?? d.stepGoal,
      waterGoalGlasses: prefs.getInt('user_water_goal') ?? d.waterGoalGlasses,
      goal: goal,
      activityLevelId: prefs.getString('user_activity') ?? d.activityLevelId,
      memberSince: since,
      healthConnectEnabled: prefs.getBool('health_connect_enabled') ?? false,
      workoutReminderEnabled: prefs.getBool('rem_workout_enabled') ?? false,
      workoutReminderHour: prefs.getInt('rem_workout_hour') ?? 18,
      workoutReminderMinute: prefs.getInt('rem_workout_minute') ?? 0,
      waterReminderEnabled: prefs.getBool('rem_water_enabled') ?? false,
      stepNudgeEnabled: prefs.getBool('rem_steps_enabled') ?? false,
    );
  }

  Future<void> save(UserSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', s.name);
    await prefs.setString('user_sex', s.sex);
    await prefs.setInt('user_age', s.age);
    await prefs.setDouble('user_height_cm', s.heightCm);
    await prefs.setDouble('user_weight', s.weightKg);
    await prefs.setInt('user_step_goal', s.stepGoal);
    await prefs.setInt('user_water_goal', s.waterGoalGlasses);
    await prefs.setString('user_goal', s.goal.name);
    await prefs.setString('user_activity', s.activityLevelId);
    await prefs.setString('member_since', s.memberSince.toIso8601String());
    await prefs.setBool('health_connect_enabled', s.healthConnectEnabled);
    await prefs.setBool('rem_workout_enabled', s.workoutReminderEnabled);
    await prefs.setInt('rem_workout_hour', s.workoutReminderHour);
    await prefs.setInt('rem_workout_minute', s.workoutReminderMinute);
    await prefs.setBool('rem_water_enabled', s.waterReminderEnabled);
    await prefs.setBool('rem_steps_enabled', s.stepNudgeEnabled);
  }

  /// Weekly plan: weekday (1 = Monday) -> workout id, or 'rest'.
  static const Map<int, String> defaultSchedule = {
    1: 'plan_push',
    2: 'plan_hiit',
    3: 'plan_legs',
    4: 'plan_mobility',
    5: 'plan_pull',
    6: 'plan_c25k',
    7: 'rest',
  };

  Future<Map<int, String>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (var d = 1; d <= 7; d++) d: prefs.getString('schedule_$d') ?? defaultSchedule[d]!,
    };
  }

  Future<void> saveScheduleDay(int weekday, String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schedule_$weekday', workoutId);
  }

  /// Wipes profile and preferences (used by "Reset all data").
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
