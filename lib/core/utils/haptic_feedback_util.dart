import 'package:flutter/services.dart';

/// Tactile native haptic feedback utility based on mobile-native guidelines.
class HapticUtil {
  HapticUtil._();

  /// Triggered on light taps, stepper buttons, and day selector bubbles
  static void light() => HapticFeedback.lightImpact();

  /// Triggered on set completion checkmark and goal achievements
  static void medium() => HapticFeedback.mediumImpact();

  /// Triggered on rest timer expiration and workout completion
  static void heavy() => HapticFeedback.heavyImpact();

  /// Double impulse pattern for PR notifications
  static void successPattern() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }
}
