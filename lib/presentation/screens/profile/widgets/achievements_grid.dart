import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/achievement.dart';
import '../../../common_widgets/icon_map.dart';
import '../../../common_widgets/ui_kit.dart';

/// Horizontal strip of achievement badges with a "view all" sheet.
class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsGrid({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final sorted = [...achievements]..sort((a, b) => b.progress.compareTo(a.progress));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Achievements',
          trailing: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Pill(label: '$unlocked/${achievements.length}'),
          ),
          actionLabel: 'View all',
          onAction: () => _showAll(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _badgeTile(sorted[i]),
          ),
        ),
      ],
    );
  }

  void _showAll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text('Achievements', style: AppTypography.headlineMedium),
              const SizedBox(height: 12),
              ...achievements.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      _icon(a, 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: AppTypography.titleMedium),
                            Text(a.description, style: AppTypography.bodyMedium),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: a.progress,
                                minHeight: 5,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation(
                                  a.isUnlocked ? AppColors.accentGreen : AppColors.primaryCoral,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(a.progressLabel, style: AppTypography.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(Achievement a, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: a.isUnlocked ? AppColors.primaryCoralLight : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: a.isUnlocked ? AppColors.primaryCoral.withValues(alpha: 0.4) : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Icon(
        a.isUnlocked ? iconForName(a.iconName) : LucideIcons.lock,
        color: a.isUnlocked ? AppColors.primaryCoral : AppColors.textMuted,
        size: size * 0.42,
      ),
    );
  }

  Widget _badgeTile(Achievement a) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: a.progress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(a.isUnlocked ? AppColors.accentGreen : AppColors.primaryCoral),
                ),
              ),
              _icon(a, 44),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            a.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textHeadline),
          ),
        ],
      ),
    );
  }
}
