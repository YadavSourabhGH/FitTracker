import 'package:intl/intl.dart';

/// Formatter for fitness telemetry metrics.
class MetricFormatter {
  MetricFormatter._();

  static final _numberFormat = NumberFormat('#,##0');

  static String formatSteps(int steps) => _numberFormat.format(steps);

  static String formatInt(num value) => _numberFormat.format(value.round());

  static String formatKcal(double kcal) => _numberFormat.format(kcal.round());

  /// Formats distance in km (e.g. 6240 m -> "6.2 km").
  static String formatDistanceKm(double meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(km >= 10 ? 1 : 2)} km';
  }

  /// Formats minutes (e.g. 405 -> "6h 45m").
  static String formatDurationMins(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}m';
    return '${hours}h ${mins}m';
  }

  /// Formats seconds to mm:ss.
  static String formatTimer(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  /// Formats seconds to h:mm:ss or mm:ss.
  static String formatClock(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final h = s ~/ 3600;
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$r' : '$m:$r';
  }

  /// Weight with no trailing ".0" (e.g. 60 -> "60", 62.5 -> "62.5").
  static String formatWeight(double kg) {
    if (kg == kg.roundToDouble()) return kg.toInt().toString();
    return kg.toStringAsFixed(1);
  }

  /// Compact thousands (e.g. 12500 -> "12.5k").
  static String compact(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.round().toString();
  }
}
