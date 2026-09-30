import 'package:intl/intl.dart';

/// Formatter for fitness telemetry metrics.
class MetricFormatter {
  MetricFormatter._();

  static final _numberFormat = NumberFormat('#,###');

  /// Formats step count (e.g. 8432 -> "8,432")
  static String formatSteps(int steps) => _numberFormat.format(steps);

  /// Formats calories (e.g. 2420 -> "2,420")
  static String formatKcal(double kcal) => _numberFormat.format(kcal.round());

  /// Formats distance in km (e.g. 6.24 -> "6.2 km")
  static String formatDistanceKm(double meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formats active duration in hours and minutes (e.g. 405 mins -> "6h 45m")
  static String formatDurationMins(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}m';
    return '${hours}h ${mins}m';
  }

  /// Formats seconds to mm:ss for rest timers
  static String formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
