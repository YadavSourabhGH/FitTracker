import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile_model.dart';
import '../../providers/profile_providers.dart';
import 'widgets/goal_overview_card.dart';
import 'widgets/achievements_grid.dart';

/// Flagship Athlete Profile & Achievements Screen matching the right UI reference mockup.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),

              profileAsync.when(
                data: (user) => Column(
                  children: [
                    _buildUserCard(user),
                    const SizedBox(height: 16),
                    _buildMembershipLevelCard(user),
                    const SizedBox(height: 16),
                    GoalOverviewCard(
                      streakDays: user.streakDays,
                      weekDots: user.weekActivityDots,
                      movePct: user.movePercentage,
                      exercisePct: user.exercisePercentage,
                      hydrationPct: user.hydrationPercentage,
                    ),
                    const SizedBox(height: 20),
                    AchievementsGrid(achievements: user.achievements),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primaryCoral),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 100), // Dock clearance
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(LucideIcons.settings),
        Text('Profile', style: AppTypography.headlineMedium),
        Row(children: [_iconBtn(LucideIcons.share2), const SizedBox(width: 8), _iconBtn(LucideIcons.bell)]),
      ],
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.cardBorder)),
      child: Icon(icon, size: 18, color: AppColors.textHeadline),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCoralLight,
                  boxShadow: [
                    BoxShadow(color: Color(0x33FF5E3A), blurRadius: 18, offset: Offset(0, 6)),
                  ],
                ),
                child: const Icon(LucideIcons.user, size: 44, color: AppColors.primaryCoral),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryCoral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.pencil, size: 12, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.name, style: AppTypography.titleLarge.copyWith(fontSize: 18)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primaryCoral),
            ],
          ),
          const SizedBox(height: 4),
          Text(user.bio, style: AppTypography.bodyMedium),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(user.location, style: AppTypography.labelSmall),
              const SizedBox(width: 8),
              Icon(
                user.gender == 'female' ? Icons.female : Icons.male,
                size: 14,
                color: AppColors.primaryCoral,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipLevelCard(UserProfile user) {
    final progress = user.currentXp / user.maxXp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.crown, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Member Since ${user.memberSince}', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${user.level}', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral)),
                    Text('${user.currentXp}/${user.maxXp} xp', style: AppTypography.monoNumber(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF3EFEA),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryCoral),
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
