import 'dart:async';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'data/services/notification_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/shell/main_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.scaffoldBase,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final settingsRepo = SettingsRepository();
  final onboardingDone = await settingsRepo.isOnboardingDone();
  final settings = await settingsRepo.load();

  if (onboardingDone) {
    unawaited(NotificationService.instance.applySettings(settings));
  }
  unawaited(WorkoutRepository().purgeAbandoned().catchError((Object e) {
    debugPrint('Session cleanup failed: $e');
  }));

  runApp(
    ProviderScope(
      overrides: [initialSettingsProvider.overrideWithValue(settings)],
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
      themeMode: ThemeMode.light,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: initialOnboardingDone ? const MainShellScreen() : const OnboardingScreen(),
    );
  }
}
