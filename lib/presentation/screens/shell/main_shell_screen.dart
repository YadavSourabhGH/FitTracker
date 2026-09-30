import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../common_widgets/floating_nav_bar.dart';
import '../insights/insights_screen.dart';
import '../workouts/workout_plans_screen.dart';
import '../steps/step_telemetry_screen.dart';
import '../diet/diet_screen.dart';
import '../../providers/step_providers.dart';

/// Main Shell Scaffold hosting the persistent FloatingNavBar and screen tabs.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0; // Default to Dashboard (Tab 0) matching Stitch

  final _screens = const [
    InsightsScreen(),
    WorkoutPlansScreen(),
    StepTelemetryScreen(),
    DietScreen(),
  ];

  void _openQuickActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Action', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            _actionTile(LucideIcons.dumbbell, 'Start Workout Session', () {
              Navigator.pop(ctx);
              setState(() => _currentIndex = 1);
            }),
            _actionTile(LucideIcons.utensils, 'Log Meal & Nutrition', () {
              Navigator.pop(ctx);
              setState(() => _currentIndex = 3);
            }),
            _actionTile(LucideIcons.refreshCw, 'Sync Health Connect', () {
              Navigator.pop(ctx);
              ref.read(todayStepProvider.notifier).syncHealthConnect();
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: AppColors.primaryCoralLight, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primaryCoral, size: 20),
      ),
      title: Text(title, style: AppTypography.titleMedium),
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onItemSelected: (idx) => setState(() => _currentIndex = idx),
              onActionTap: _openQuickActionSheet,
            ),
          ),
        ],
      ),
    );
  }
}

