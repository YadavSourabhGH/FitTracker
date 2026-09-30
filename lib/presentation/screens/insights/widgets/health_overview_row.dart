import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import 'health_metric_painters.dart';

/// Health Overview 2x2 grid with honest telemetry markers.
class HealthOverviewRow extends StatelessWidget {
  const HealthOverviewRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Health Overview', style: AppTypography.titleLarge),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'Sensors',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryCoral,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primaryCoral),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _card(
                icon: LucideIcons.heart, iconColor: AppColors.accentPink, bgColor: AppColors.accentPinkLight,
                badge: 'No Sensor', badgeBg: AppColors.surfaceContainer, badgeColor: AppColors.textBody,
                title: 'Heart Rate', value: '-', unit: 'bpm', bottomWidget: _sparkline(AppColors.accentPink.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _card(
                icon: LucideIcons.moon, iconColor: AppColors.accentPurple, bgColor: AppColors.accentPurpleLight,
                badge: 'Unmeasured', badgeBg: AppColors.surfaceContainer, badgeColor: AppColors.textBody,
                title: 'Avg. Sleep', value: '-', unit: '', bottomWidget: _sleepBars(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _card(
                icon: LucideIcons.droplets, iconColor: AppColors.accentGreen, bgColor: AppColors.accentGreenLight,
                badge: 'Goal 8', badgeBg: AppColors.accentGreenLight, badgeColor: AppColors.onSecondaryContainer,
                title: 'Hydration', value: '-', unit: 'Glasses', bottomWidget: _hydrationSegments(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _card(
                icon: LucideIcons.wind, iconColor: AppColors.accentGreen, bgColor: AppColors.accentGreenLight,
                badge: 'No Sensor', badgeBg: AppColors.surfaceContainer, badgeColor: AppColors.textBody,
                title: 'SpO2 Level', value: '-', unit: '', bottomWidget: _ecgWave(AppColors.accentGreen.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String title,
    required String value,
    required String unit,
    required Widget bottomWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  badge,
                  style: AppTypography.labelSmall.copyWith(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.monoNumber(fontSize: 18, fontWeight: FontWeight.w800)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: AppTypography.bodyMedium.copyWith(fontSize: 11, color: AppColors.textBody)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _sparkline(Color color) {
    return SizedBox(
      height: 16,
      width: double.infinity,
      child: CustomPaint(painter: SparklinePainter(color)),
    );
  }

  Widget _ecgWave(Color color) {
    return SizedBox(
      height: 16,
      width: double.infinity,
      child: CustomPaint(painter: EcgPainter(color)),
    );
  }

  Widget _sleepBars() {
    return Row(
      children: [
        Expanded(flex: 1, child: Container(height: 6, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(3)))),
        const SizedBox(width: 3),
        Expanded(flex: 2, child: Container(height: 6, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(3)))),
        const SizedBox(width: 3),
        Expanded(flex: 1, child: Container(height: 6, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(3)))),
      ],
    );
  }

  Widget _hydrationSegments() {
    return Row(
      children: List.generate(5, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
