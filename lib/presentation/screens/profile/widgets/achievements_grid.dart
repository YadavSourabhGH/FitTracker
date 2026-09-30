import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_profile_model.dart';

/// Achievements row displaying badge icons matching the UI reference.
class AchievementsGrid extends StatelessWidget {
  final List<AchievementBadge> achievements;

  const AchievementsGrid({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements', style: AppTypography.titleLarge),
            GestureDetector(
              onTap: () {},
              child: Text('View All', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: achievements.map((badge) => _badgeTile(badge)).toList(),
        ),
        const SizedBox(height: 20),

        // Personal Bests Tile
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Personal Bests', style: AppTypography.titleMedium),
                  Text('View All', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _prMetric('Bench Press', '100 kg'),
                  Container(width: 1, height: 28, color: AppColors.cardBorder),
                  _prMetric('Back Squat', '140 kg'),
                  Container(width: 1, height: 28, color: AppColors.cardBorder),
                  _prMetric('Deadlift', '180 kg'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeTile(AchievementBadge badge) {
    final isUnlocked = badge.isUnlocked;
    Color iconColor;
    Color bgColor;

    switch (badge.iconName) {
      case 'flame':
        iconColor = AppColors.primaryCoral;
        bgColor = AppColors.primaryCoralLight;
        break;
      case 'shoe':
        iconColor = AppColors.accentGreen;
        bgColor = AppColors.accentGreenLight;
        break;
      case 'droplet':
        iconColor = AppColors.accentBlue;
        bgColor = AppColors.accentBlueLight;
        break;
      case 'target':
        iconColor = AppColors.accentPurple;
        bgColor = AppColors.accentPurpleLight;
        break;
      default:
        iconColor = AppColors.textMuted;
        bgColor = const Color(0xFFF3EFEA);
    }

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked ? iconColor.withValues(alpha: 0.3) : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Icon(
            isUnlocked ? _resolveIcon(badge.iconName) : LucideIcons.lock,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(badge.title, style: AppTypography.monoNumber(fontSize: 10, fontWeight: FontWeight.w700)),
        Text(badge.subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 8)),
      ],
    );
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'flame': return LucideIcons.flame;
      case 'shoe': return LucideIcons.footprints;
      case 'droplet': return LucideIcons.droplets;
      case 'target': return LucideIcons.target;
      default: return LucideIcons.award;
    }
  }

  Widget _prMetric(String lift, String weight) {
    return Column(
      children: [
        Text(lift, style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(weight, style: AppTypography.monoNumber(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
