import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/metric_formatter.dart';
import '../../../../core/utils/haptic_feedback_util.dart';

/// Floating rest countdown timer bar triggered upon set completion.
class RestTimerBanner extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onDismiss;

  const RestTimerBanner({
    super.key,
    required this.initialSeconds,
    required this.onDismiss,
  });

  @override
  State<RestTimerBanner> createState() => _RestTimerBannerState();
}

class _RestTimerBannerState extends State<RestTimerBanner> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > 0) {
        setState(() => _remaining--);
        if (_remaining == 3 || _remaining == 2 || _remaining == 1) {
          HapticUtil.light();
        }
      } else {
        HapticUtil.heavy();
        _timer?.cancel();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryCoral,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x66FF5E3A), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.timer, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            'Rest: ${MetricFormatter.formatTimer(_remaining)}',
            style: AppTypography.monoNumber(fontSize: 15, color: Colors.white),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _remaining += 30),
            child: Text('+30s', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
          ),
          IconButton(
            onPressed: widget.onDismiss,
            icon: const Icon(LucideIcons.x, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
