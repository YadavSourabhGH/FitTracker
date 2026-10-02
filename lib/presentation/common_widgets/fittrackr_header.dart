import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/app_providers.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/reminders_screen.dart';

/// Top header with brand mark, reminders and profile shortcuts.
class FitTrackrHeader extends ConsumerWidget {
  final String subtitle;

  const FitTrackrHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final remindersOn = settings.workoutReminderEnabled ||
        settings.waterReminderEnabled ||
        settings.stepNudgeEnabled;
    final initial = settings.firstName.isNotEmpty ? settings.firstName[0].toUpperCase() : 'A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/branding/logo.png', width: 34, height: 34),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FitTrackr',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primaryCoral,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Reminders',
            icon: Icon(
              remindersOn ? Icons.notifications_active_outlined : LucideIcons.bell,
              size: 20,
              color: remindersOn ? AppColors.primaryCoral : AppColors.textBody,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: 'Profile',
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCoralLight,
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                ),
                child: Text(
                  initial,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryCoral,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
