/// Step and activity telemetry models for Health Connect and Hardware Sensor.
class DailyStepRecord {
  final String dateString; // YYYY-MM-DD
  final int stepCount;
  final double distanceMeters;
  final double activeCalories;
  final String source; // HEALTH_CONNECT, SAMSUNG_HEALTH, HARDWARE_SENSOR
  final DateTime syncedAt;

  const DailyStepRecord({
    required this.dateString,
    required this.stepCount,
    required this.distanceMeters,
    required this.activeCalories,
    required this.source,
    required this.syncedAt,
  });

  Map<String, dynamic> toMap() => {
    'dateString': dateString,
    'stepCount': stepCount,
    'distanceMeters': distanceMeters,
    'activeCalories': activeCalories,
    'source': source,
    'syncedAt': syncedAt.toIso8601String(),
  };

  factory DailyStepRecord.fromMap(Map<String, dynamic> map) {
    return DailyStepRecord(
      dateString: map['dateString'] as String,
      stepCount: map['stepCount'] as int? ?? 0,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      activeCalories: (map['activeCalories'] as num?)?.toDouble() ?? 0.0,
      source: map['source'] as String? ?? 'HARDWARE_SENSOR',
      syncedAt: DateTime.tryParse(map['syncedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class HourlyStepBucket {
  final int hour; // 0 to 23
  final int steps;

  const HourlyStepBucket({required this.hour, required this.steps});
}
