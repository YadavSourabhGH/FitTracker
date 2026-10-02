import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/user_settings.dart';

/// Local reminder scheduling (workout, hydration, evening step check-in).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _workoutId = 100;
  static const _stepNudgeId = 300;
  static const _waterBaseId = 200;
  static const _waterHours = [9, 11, 13, 15, 17, 19];

  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'fittrackr_reminders',
      'Reminders',
      channelDescription: 'Workout, hydration and step goal reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_stat_notify',
    ),
  );

  static const _activityDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'fittrackr_activity',
      'Activity',
      channelDescription: 'Workout completion and goal achievements',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notify',
    ),
  );

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notify'),
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<bool> requestPermission() async {
    await init();
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Notification permission failed: $e');
      return false;
    }
  }

  Future<bool> areEnabled() async {
    await init();
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = DateTime.now();
    var local = DateTime(now.year, now.month, now.day, hour, minute);
    if (!local.isAfter(now)) local = local.add(const Duration(days: 1));
    return tz.TZDateTime.from(local, tz.UTC);
  }

  Future<void> _daily(int id, String title, String body, int hour, int minute) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Re-applies every reminder from the user's settings.
  Future<void> applySettings(UserSettings s) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _workoutId);
      await _plugin.cancel(id: _stepNudgeId);
      for (var i = 0; i < _waterHours.length; i++) {
        await _plugin.cancel(id: _waterBaseId + i);
      }

      if (s.workoutReminderEnabled) {
        await _daily(
          _workoutId,
          'Time to train, ${s.firstName}',
          "Your workout for today is ready in FitTrackr.",
          s.workoutReminderHour,
          s.workoutReminderMinute,
        );
      }
      if (s.waterReminderEnabled) {
        for (var i = 0; i < _waterHours.length; i++) {
          await _daily(
            _waterBaseId + i,
            'Hydration check',
            'Have a glass of water and log it to reach ${s.waterGoalGlasses} glasses today.',
            _waterHours[i],
            0,
          );
        }
      }
      if (s.stepNudgeEnabled) {
        await _daily(
          _stepNudgeId,
          'Evening step check-in',
          'Open FitTrackr to see how close you are to ${s.stepGoal} steps.',
          20,
          0,
        );
      }
    } catch (e) {
      debugPrint('Scheduling reminders failed: $e');
    }
  }

  Future<void> showNow(int id, String title, String body) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.show(id: id, title: title, body: body, notificationDetails: _activityDetails);
    } catch (e) {
      debugPrint('Notification failed: $e');
    }
  }
}
