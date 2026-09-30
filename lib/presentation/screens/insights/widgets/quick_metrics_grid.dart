import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 4-card metric strip matching Stitch: Steps, Kcal, km, Active.
class QuickMetricsGrid extends StatelessWidget {
  final String stepsText;
  final String kcalText;
  final String distanceText;
  final String activeTimeText;

  const QuickMetricsGrid({
    super.key,
    required this.stepsText,
    required this.kcalText,
    required this.distanceText,
    required this.activeTimeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _metricTile(LucideIcons.footprints, stepsText, 'Steps', AppColors.primaryCoral),
        const SizedBox(width: 8),
        _metricTile(LucideIcons.flame, kcalText, 'Kcal', AppColors.primaryCoral),
        const SizedBox(width: 8),
        _metricTile(LucideIcons.mapPin, distanceText, 'km', AppColors.textBody),
        const SizedBox(width: 8),
        _metricTile(LucideIcons.timer, activeTimeText, 'Active', AppColors.primaryCoralDark),
      ],
    );
  }

  Widget _metricTile(IconData icon, String value, String label, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14B89988),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryCoralLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.monoNumber(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

