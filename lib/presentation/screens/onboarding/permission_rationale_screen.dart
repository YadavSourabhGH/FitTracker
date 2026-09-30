import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../shell/main_shell_screen.dart';

/// Permission Rationale Screen for Health Connect and Activity Recognition.
class PermissionRationaleScreen extends StatelessWidget {
  const PermissionRationaleScreen({super.key});

  Future<void> _requestAndEnter(BuildContext context) async {
    // Request Android hardware activity recognition
    await Permission.activityRecognition.request();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryCoralLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.heartPulse, color: AppColors.primaryCoral, size: 32),
              ),
              const SizedBox(height: 24),
              Text('Real Health Integration', style: AppTypography.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'FitTrackr strictly uses real Android APIs with zero fake or simulated data. We connect to your device hardware and Health Connect.',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 32),

              _featureItem(
                LucideIcons.footprints,
                'Hardware Step Counter',
                'Reads real step counts directly from your phone pedometer chip with sub-2% battery footprint.',
              ),
              const SizedBox(height: 20),

              _featureItem(
                LucideIcons.refreshCw,
                'Health Connect & Samsung Health',
                'Synchronizes steps, active calories, and distance recorded by your Samsung Galaxy Watch or Google Pixel Watch.',
              ),
              const SizedBox(height: 20),

              _featureItem(
                LucideIcons.shieldCheck,
                '100% On-Device Privacy',
                'All workout records and telemetry are stored securely in your local SQLite database without cloud tracking.',
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () => _requestAndEnter(context),
                child: const Text('Connect & Open FitTrackr'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Icon(icon, color: AppColors.primaryCoral, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium),
              const SizedBox(height: 3),
              Text(description, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
