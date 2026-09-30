import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../screens/profile/profile_screen.dart';

/// Top header matching the FitTrackr brand and design.
class FitTrackrHeader extends StatelessWidget {
  final String subtitle;
  final bool showBack;

  const FitTrackrHeader({
    super.key,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textHeadline),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
          ],
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primaryCoralLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.flame,
              color: AppColors.primaryCoral,
              size: 20,
            ),
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
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textBody,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20, color: AppColors.textBody),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCoralLight,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1EB89988),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.user,
                size: 18,
                color: AppColors.primaryCoral,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
