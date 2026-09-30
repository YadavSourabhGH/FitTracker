import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Weekly routine schedule list card matching FitTrackr design.
class WeeklyScheduleCard extends StatelessWidget {
  const WeeklyScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon ... 7 = Sun
    final routineRosters = [
      {'day': 'MON', 'title': 'Upper Body Hypertrophy', 'sub': '40 min • Chest & Back', 'dayNum': 1},
      {'day': 'TUE', 'title': 'HIIT Core Blast', 'sub': '30 min • High Intensity', 'dayNum': 2},
      {'day': 'WED', 'title': 'Functional Leg Power', 'sub': '45 min • Quads & Glutes', 'dayNum': 3},
      {'day': 'THU', 'title': 'Active Recovery & Mobility', 'sub': '20 min • Gentle Flow', 'dayNum': 4},
      {'day': 'FRI', 'title': 'Full Body Metabolic Circuit', 'sub': '35 min • Strength & Cardio', 'dayNum': 5},
      {'day': 'SAT', 'title': 'Weekend Outdoor Trail', 'sub': '45 min • Cardio & Endurance', 'dayNum': 6},
      {'day': 'SUN', 'title': 'Rest & Bodyweight Stretch', 'sub': '20 min • Full Rest', 'dayNum': 7},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Text('Weekly Routine Schedule', style: AppTypography.titleMedium),
                ],
              ),
              Text(
                'Adjust Plan',
                style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCoral, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...routineRosters.map((r) {
            final dayNum = r['dayNum'] as int;
            final isToday = dayNum == todayWeekday;
            final isPast = dayNum < todayWeekday;
            final rawSub = r['sub'] as String;
            final day = r['day'] as String;
            final title = r['title'] as String;

            final status = isToday
                ? _Status.ready
                : (isPast ? _Status.rest : _Status.upcoming);

            final subText = isToday
                ? "Today's Focus • ${rawSub.split('•').first.trim()}"
                : (isPast ? "Rest • ${rawSub.split('•').last.trim()}" : rawSub);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _item(day, title, subText, status),
            );
          }),
        ],
      ),
    );
  }

  Widget _item(String day, String title, String sub, _Status status) {
    final isReady = status == _Status.ready;
    final isDone = status == _Status.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isReady ? AppColors.primaryCoralLight.withValues(alpha: 0.4) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: isReady ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isReady
                  ? AppColors.primaryCoral
                  : (isDone ? AppColors.accentGreenLight : AppColors.surfaceContainer),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: AppTypography.monoNumber(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isReady ? Colors.white : (isDone ? AppColors.onSecondaryContainer : AppColors.textBody),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textBody),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(_Status status) {
    if (status == _Status.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.accentGreenLight, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check, size: 12, color: AppColors.onSecondaryContainer),
          const SizedBox(width: 3),
          Text('Completed', style: AppTypography.labelSmall.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w700, fontSize: 10)),
        ]),
      );
    }
    if (status == _Status.ready) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x22FF5F25), blurRadius: 4, offset: Offset(0, 1))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.play, size: 10, color: AppColors.primaryCoral),
          const SizedBox(width: 4),
          Text('Ready to start', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.w800, fontSize: 10)),
        ]),
      );
    }
    final isRest = status == _Status.rest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: isRest ? AppColors.surfaceContainer : AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
      child: Text(isRest ? 'Rest' : 'Upcoming', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

enum _Status { completed, ready, upcoming, rest }
