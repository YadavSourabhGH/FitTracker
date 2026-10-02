/// Helpers for the local `YYYY-MM-DD` day keys used as database partitions.
class DateKeys {
  DateKeys._();

  static String of(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String today() => of(DateTime.now());

  static DateTime parse(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return startOfDay(DateTime.now());
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
  }

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isToday(String key) => key == today();

  static String shift(String key, int days) {
    final d = parse(key);
    return of(DateTime(d.year, d.month, d.day + days));
  }

  /// Monday of the week containing [d].
  static DateTime startOfWeek(DateTime d) {
    final day = startOfDay(d);
    return DateTime(day.year, day.month, day.day - (day.weekday - 1));
  }

  /// List of day keys, oldest first, ending today.
  static List<String> lastNDays(int n) {
    final now = startOfDay(DateTime.now());
    return List.generate(n, (i) => of(DateTime(now.year, now.month, now.day - (n - 1 - i))));
  }

  static const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const weekdayLetter = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. "Fri, 2 Oct".
  static String pretty(DateTime d) =>
      '${weekdayShort[d.weekday - 1]}, ${d.day} ${monthShort[d.month - 1]}';

  /// "Today", "Yesterday" or the pretty date.
  static String relativeLabel(String key) {
    if (key == today()) return 'Today';
    if (key == shift(today(), -1)) return 'Yesterday';
    return pretty(parse(key));
  }
}
