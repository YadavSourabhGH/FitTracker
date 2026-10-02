import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_feedback_util.dart';

/// Floating bottom navigation bar matching the FitTrackr dock.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onActionTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 18),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2EB89988),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, LucideIcons.layoutGrid, 'Home'),
                _navItem(1, LucideIcons.dumbbell, 'Workouts'),
                const SizedBox(width: 52), // Gap for center FAB
                _navItem(2, LucideIcons.activity, 'Progress'),
                _navItem(3, LucideIcons.apple, 'Diet'),
              ],
            ),
          ),

          // Elevated Center '+' Floating Action Button
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: () {
                HapticUtil.medium();
                onActionTap();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryCoral, AppColors.primaryCoralDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66FF5F25),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryCoral : AppColors.textMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticUtil.light();
        onItemSelected(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

