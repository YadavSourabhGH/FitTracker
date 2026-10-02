import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/metric_formatter.dart';
import '../../../common_widgets/ui_kit.dart';

/// Dual-ring gauge: outer = steps vs goal, inner = active kcal vs 400 kcal.
class StepHeroGaugeCard extends StatelessWidget {
  final int steps;
  final int goal;
  final double activeKcal;
  final String caption;

  const StepHeroGaugeCard({
    super.key,
    required this.steps,
    required this.goal,
    required this.activeKcal,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final pct = goal <= 0 ? 0.0 : (steps / goal).clamp(0.0, 1.0).toDouble();
    final remaining = goal - steps;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.footprints, size: 16, color: AppColors.primaryCoral),
              const SizedBox(width: 6),
              Expanded(child: Text('Daily Activity Goal', style: AppTypography.titleMedium)),
              Text(
                '${(pct * 100).toInt()}% completed',
                style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral, fontSize: 13),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CustomPaint(
                    size: const Size(190, 190),
                    painter: _DualRingPainter(
                      outerProgress: value,
                      innerProgress: (activeKcal / 400).clamp(0.0, 1.0).toDouble(),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconBadge(icon: LucideIcons.footprints, size: 38, iconSize: 20),
                    const SizedBox(height: 6),
                    Text(
                      MetricFormatter.formatSteps(steps),
                      style: AppTypography.monoNumber(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'STEPS',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: ${MetricFormatter.formatSteps(goal)}',
                      style: AppTypography.labelSmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Pill(
            icon: remaining > 0 ? LucideIcons.flag : Icons.check,
            label: remaining > 0
                ? '${MetricFormatter.formatSteps(remaining)} steps to go - $caption'
                : 'Goal reached - $caption',
            background: remaining > 0 ? AppColors.primaryCoralLight : AppColors.accentGreenLight,
            foreground: remaining > 0 ? AppColors.primaryCoralDark : AppColors.onSecondaryContainer,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppColors.primaryCoral, 'Steps'),
              const SizedBox(width: 16),
              _legend(AppColors.accentGreen, 'Active kcal (of 400)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String t) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(t, style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
        ],
      );
}

class _DualRingPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  _DualRingPainter({required this.outerProgress, required this.innerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 80, bgPaint);

    final outerPaint = Paint()
      ..shader = const LinearGradient(colors: [AppColors.primaryCoral, AppColors.primaryCoralDark])
          .createShader(Rect.fromCircle(center: center, radius: 80))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (outerProgress > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: 80), -pi / 2, 2 * pi * outerProgress, false, outerPaint);
    }

    final innerBgPaint = Paint()
      ..color = AppColors.surfaceContainer
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 64, innerBgPaint);

    final innerPaint = Paint()
      ..color = AppColors.accentGreen
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (innerProgress > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: 64), -pi / 2, 2 * pi * innerProgress, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DualRingPainter oldDelegate) =>
      oldDelegate.outerProgress != outerProgress || oldDelegate.innerProgress != innerProgress;
}
