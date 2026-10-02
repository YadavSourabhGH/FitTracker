/// Optional vitals read from Health Connect. Null fields mean "not measured".
class HealthSnapshot {
  final int? latestHeartRate;
  final int? avgHeartRate;
  final int? sleepMinutes;
  final double? spo2Percent;
  final DateTime fetchedAt;

  const HealthSnapshot({
    this.latestHeartRate,
    this.avgHeartRate,
    this.sleepMinutes,
    this.spo2Percent,
    required this.fetchedAt,
  });

  static HealthSnapshot empty() => HealthSnapshot(fetchedAt: DateTime.now());

  bool get hasAny =>
      latestHeartRate != null || sleepMinutes != null || spo2Percent != null;
}
