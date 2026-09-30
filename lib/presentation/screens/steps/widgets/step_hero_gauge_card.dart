import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/step_providers.dart';

/// Hero step radial dual-ring gauge card matching Stitch design.
class StepHeroGaugeCard extends StatelessWidget {
  final TodayStepState data;

  const StepHeroGaugeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.footprints, size: 16, color: AppColors.primaryCoral),
                  const SizedBox(width: 6),
                  Text('Daily Activity Goal', style: AppTypography.titleMedium),
                ],
              ),
              Text(
                '${data.progressPercentage.toInt()}% Completed',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryCoral,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(190, 190),
                  painter: _DualRingPainter(
                    outerProgress: (data.progressPercentage / 100).clamp(0.0, 1.0),
                    innerProgress: ((data.activeCalories / 500)).clamp(0.0, 1.0),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryCoralLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.footprints, color: AppColors.primaryCoral, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${data.stepCount}',
                      style: AppTypography.monoNumber(fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'STEPS WALKED',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${data.goalSteps}',
                      style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryCoralLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.flag, size: 13, color: AppColors.primaryCoral),
                const SizedBox(width: 6),
                Text(
                  '${data.remainingSteps} steps to reach daily goal',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryCoralDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  _DualRingPainter({required this.outerProgress, required this.innerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer Background Track
    final bgPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, 80, bgPaint);

    // Outer Active Steps Arc
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryCoral, AppColors.primaryCoralDark],
      ).createShader(Rect.fromCircle(center: center, radius: 80))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: 80), -pi / 2, 2 * pi * outerProgress, false, outerPaint);

    // Inner Background Track
    final innerBgPaint = Paint()
      ..color = AppColors.surfaceContainer
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, 64, innerBgPaint);

    // Inner Active Mint Arc
    final innerPaint = Paint()
      ..color = AppColors.accentGreen
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: 64), -pi / 2, 2 * pi * innerProgress, false, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _DualRingPainter oldDelegate) =>
      oldDelegate.outerProgress != outerProgress || oldDelegate.innerProgress != innerProgress;
}
