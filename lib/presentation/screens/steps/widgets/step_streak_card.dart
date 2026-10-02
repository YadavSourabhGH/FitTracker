import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../common_widgets/ui_kit.dart';

/// Current streak and this week's goal completion (Monday to Sunday).
class StepStreakCard extends StatelessWidget {
  final int streakDays;
  final List<bool?> weekHits; // null = future day
  final String sourceLabel;
  final DateTime? lastSync;
  final VoidCallback onSyncTap;

  const StepStreakCard({
    super.key,
    required this.streakDays,
    required this.weekHits,
    required this.sourceLabel,
    required this.lastSync,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final todayIdx = DateTime.now().weekday - 1;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final sync = lastSync;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(icon: LucideIcons.flame, size: 38, iconSize: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streakDays day streak', style: AppTypography.titleLarge),
                    Text(
                      streakDays > 0
                          ? 'Consecutive days at or above your step goal'
                          : 'Reach your step goal today to start a streak',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final hit = weekHits[i];
              final isToday = i == todayIdx;
              return Column(
                children: [
                  Text(
                    days[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isToday ? AppColors.primaryCoral : AppColors.textBody,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hit == true
                          ? AppColors.primaryCoral
                          : (isToday ? AppColors.primaryCoralLight : AppColors.surfaceContainerHigh),
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: AppColors.primaryCoral, width: 2) : null,
                    ),
                    child: hit == true
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : (hit == false && !isToday
                            ? const Icon(Icons.close, size: 14, color: AppColors.textMuted)
                            : null),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sync == null
                      ? 'Source: $sourceLabel'
                      : 'Source: $sourceLabel - synced ${TimeOfDay.fromDateTime(sync).format(context)}',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 10),
                ),
              ),
              InkWell(
                onTap: onSyncTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    'Sync now',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
