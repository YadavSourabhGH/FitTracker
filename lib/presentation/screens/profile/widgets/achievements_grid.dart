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
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) => _badgeTile(ctx, sorted[i]),
            ),
          ),
        ),
      ],
    );
  }

  void _showAll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('Achievements', style: AppTypography.headlineMedium),
              const SizedBox(height: 14),
              ...achievements.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _icon(a, 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(a.title, style: AppTypography.titleMedium),
                                  ),
                                  if (a.isUnlocked)
                                    const Pill(
                                      label: 'Unlocked',
                                      background: AppColors.primaryCoralLight,
                                      foreground: AppColors.primaryCoralDark,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(a.description, style: AppTypography.bodyMedium),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: a.progress,
                                  minHeight: 5,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation(
                                    a.isUnlocked ? AppColors.accentAmber : AppColors.primaryCoral,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(a.progressLabel, style: AppTypography.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    ),
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
        shape: BoxShape.circle,
        border: Border.all(
          color: a.isUnlocked ? AppColors.primaryCoral.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Icon(
        iconForName(a.iconName),
        color: a.isUnlocked ? AppColors.primaryCoral : AppColors.textMuted,
        size: size * 0.44,
      ),
    );
  }

  Widget _badgeTile(BuildContext context, Achievement a) {
    return GestureDetector(
      onTap: () => _showAll(context),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: a.isUnlocked
                          ? AppColors.accentAmber
                          : AppColors.surfaceContainerHigh,
                      width: a.isUnlocked ? 2.5 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: a.isUnlocked
                            ? AppColors.primaryCoralLight
                            : AppColors.surfaceContainer,
                        border: Border.all(
                          color: a.isUnlocked
                              ? AppColors.primaryCoral.withValues(alpha: 0.5)
                              : AppColors.cardBorder.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        iconForName(a.iconName),
                        color: a.isUnlocked
                            ? AppColors.primaryCoral
                            : AppColors.textMuted.withValues(alpha: 0.45),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (!a.isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        size: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              a.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: a.isUnlocked ? FontWeight.w700 : FontWeight.w500,
                color: a.isUnlocked ? AppColors.textHeadline : AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
