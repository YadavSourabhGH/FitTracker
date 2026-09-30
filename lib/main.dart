import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/shell/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    ProviderScope(
      child: FitTrackrApp(initialOnboardingDone: onboardingDone),
    ),
  );
}

class FitTrackrApp extends StatelessWidget {
  final bool initialOnboardingDone;

  const FitTrackrApp({super.key, required this.initialOnboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrackr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialOnboardingDone ? const MainShellScreen() : const OnboardingScreen(),
    );
  }
}
