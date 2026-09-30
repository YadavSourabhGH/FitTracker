import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

/// Reusable status capsule/pill badge matching the UI reference.
class MetricPill extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const MetricPill({
    super.key,
    required this.label,
    this.leadingIcon,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
