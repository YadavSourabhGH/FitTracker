import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/app_providers.dart';
import '../settings/profile_editor.dart';
import 'permission_rationale_screen.dart';

/// First-run profile setup used to personalise targets.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/branding/logo.png', width: 56, height: 56),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to', style: AppTypography.bodyLarge),
                        Text(
                          'FitTrackr',
                          style: AppTypography.displayLarge.copyWith(color: AppColors.primaryCoral, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tell us a little about yourself. We use this to calculate your calorie and protein targets, '
                'walking distance and energy burned. Everything stays on your phone.',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 24),
              ProfileEditor(
                initial: settings,
                submitLabel: 'Continue',
                onSubmit: (next) async {
                  await ref.read(settingsProvider.notifier).save(next.copyWith(memberSince: DateTime.now()));
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PermissionRationaleScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
