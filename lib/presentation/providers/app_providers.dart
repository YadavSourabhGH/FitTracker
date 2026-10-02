import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/step_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/services/notification_service.dart';

/// Settings loaded before `runApp` (overridden in main.dart).
final initialSettingsProvider = Provider<UserSettings>((ref) => UserSettings.defaults());

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository());
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) => WorkoutRepository());
final stepRepositoryProvider = Provider<StepRepository>((ref) => StepRepository());
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) => NutritionRepository());
final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) => HydrationRepository());

/// Current athlete profile and preferences.
class SettingsNotifier extends Notifier<UserSettings> {
  @override
  UserSettings build() => ref.watch(initialSettingsProvider);

  Future<void> save(UserSettings next) async {
    final previous = state;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
    final remindersChanged = previous.workoutReminderEnabled != next.workoutReminderEnabled ||
        previous.workoutReminderHour != next.workoutReminderHour ||
        previous.workoutReminderMinute != next.workoutReminderMinute ||
        previous.waterReminderEnabled != next.waterReminderEnabled ||
        previous.stepNudgeEnabled != next.stepNudgeEnabled ||
        previous.stepGoal != next.stepGoal ||
        previous.waterGoalGlasses != next.waterGoalGlasses ||
        previous.name != next.name;
    if (remindersChanged) {
      await NotificationService.instance.applySettings(next);
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);
