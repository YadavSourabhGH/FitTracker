import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real Hardware Pedometer Service listening to Android Sensor.TYPE_STEP_COUNTER.
class PedometerService {
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  int _baseMidnightSteps = -1;
  int _currentStepsToday = 0;
  String _pedestrianStatus = 'stopped';
  final _stepController = StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepController.stream;
  int get currentStepsToday => _currentStepsToday;
  String get pedestrianStatus => _pedestrianStatus;

  /// Requests Android ACTIVITY_RECOGNITION permission and initializes sensor
  Future<bool> initialize() async {
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _baseMidnightSteps = prefs.getInt('base_steps_$today') ?? -1;

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (event) => _onStepCount(event, today, prefs),
        onError: (error) => _stepController.addError(error),
      );

      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        (event) => _pedestrianStatus = event.status,
        onError: (_) {},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void _onStepCount(StepCount event, String today, SharedPreferences prefs) {
    final rawSteps = event.steps;

    if (_baseMidnightSteps == -1) {
      _baseMidnightSteps = rawSteps;
      prefs.setInt('base_steps_$today', _baseMidnightSteps);
    }

    // Handles phone reboot (when raw steps count drops below midnight baseline)
    if (rawSteps < _baseMidnightSteps) {
      _baseMidnightSteps = rawSteps;
      prefs.setInt('base_steps_$today', _baseMidnightSteps);
    }

    _currentStepsToday = rawSteps - _baseMidnightSteps;
    if (_currentStepsToday < 0) _currentStepsToday = 0;
    _stepController.add(_currentStepsToday);
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _stepController.close();
  }
}
