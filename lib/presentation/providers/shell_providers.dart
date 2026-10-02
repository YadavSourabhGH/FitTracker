import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected bottom-navigation tab (0 Home, 1 Workouts, 2 Progress, 3 Diet).
class ShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final shellTabProvider = NotifierProvider<ShellTabNotifier, int>(ShellTabNotifier.new);
