import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_keys.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/models/user_settings.dart';
import '../../common_widgets/fittrackr_header.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import 'food_search_modal.dart';
import 'widgets/daily_calorie_card.dart';
import 'widgets/diet_suggestions_view.dart';

/// Diet tab: meal logging by day and nutrition guidance.
class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  int _tab = 0;
  final Set<String> _hidden = {};

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final day = ref.watch(dietDateProvider);
    final mealsAsync = ref.watch(mealsForDateProvider(day));
    final meals = (mealsAsync.value ?? const <NutritionItem>[]).where((m) => !_hidden.contains(m.id)).toList();

    double sum(double Function(NutritionItem) f) => meals.fold(0.0, (a, m) => a + f(m));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      floatingActionButton: _tab == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: FloatingActionButton.extended(
                heroTag: 'add_food',
                backgroundColor: AppColors.primaryCoral,
                foregroundColor: Colors.white,
                onPressed: () => showFoodSearch(context, ref, day),
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add food'),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const FitTrackrHeader(subtitle: 'Nutrition'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _tabBtn(0, 'Track Meals', LucideIcons.utensils),
                  _tabBtn(1, 'Diet Suggestions', LucideIcons.sparkles),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_tab == 0) ...[
              _dateSwitcher(day),
              const SizedBox(height: 12),
              DailyCalorieCard(
                targets: settings.macroTargets,
                totalCalories: sum((m) => m.calories),
                totalProtein: sum((m) => m.proteinGrams),
                totalCarbs: sum((m) => m.carbsGrams),
                totalFat: sum((m) => m.fatGrams),
                goalLabel: settings.goal.label,
              ),
              const SizedBox(height: 16),
              mealsAsync.when(
                data: (_) => meals.isEmpty
                    ? EmptyState(
                        icon: LucideIcons.utensilsCrossed,
                        title: DateKeys.isToday(day) ? 'No meals logged today' : 'No meals logged on this day',
                        message: 'Pick from common foods, your recent foods or search Open Food Facts.',
                        actionLabel: 'Log a meal',
                        onAction: () => showFoodSearch(context, ref, day),
                      )
                    : Column(children: _mealGroups(meals)),
                loading: () => const LoadingBlock(),
                error: (e, _) => ErrorCard(
                  message: 'Could not load meals.',
                  onRetry: () => ref.invalidate(mealsForDateProvider(day)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Targets: BMR ${settings.bmr.round()} kcal x ${settings.activityLevel.multiplier} activity '
                '= TDEE ${settings.tdee.round()} kcal, ${settings.goal.calorieAdjustment >= 0 ? '+' : ''}'
                '${settings.goal.calorieAdjustment} kcal for "${settings.goal.label}".',
                style: AppTypography.labelSmall,
              ),
            ] else
              DietSuggestionsView(
                goal: settings.goal,
                onAddFoodQuery: (food) {
                  setState(() => _tab = 0);
                  showFoodSearch(context, ref, DateKeys.today(), initialQuery: food);
                },
              ),
            const SizedBox(height: 170),
          ],
        ),
      ),
    );
  }

  List<Widget> _mealGroups(List<NutritionItem> meals) {
    final widgets = <Widget>[];
    for (final type in NutritionItem.mealTypes) {
      final items = meals.where((m) => m.mealType.toLowerCase() == type.toLowerCase()).toList();
      if (items.isEmpty) continue;
      final kcal = items.fold<double>(0, (a, m) => a + m.calories);
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Row(
          children: [
            Expanded(child: Text(type, style: AppTypography.titleLarge)),
            Text('${kcal.round()} kcal', style: AppTypography.monoNumber(fontSize: 12, color: AppColors.primaryCoral)),
          ],
        ),
      ));
      widgets.addAll(items.map(_foodTile));
    }
    final others = meals
        .where((m) => !NutritionItem.mealTypes.any((t) => t.toLowerCase() == m.mealType.toLowerCase()))
        .toList();
    if (others.isNotEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Text('Other', style: AppTypography.titleLarge),
      ));
      widgets.addAll(others.map(_foodTile));
    }
    return widgets;
  }

  Widget _foodTile(NutritionItem f) {
    return Dismissible(
      key: ValueKey(f.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.accentPinkLight, borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.delete_outline, color: AppColors.accentPink),
      ),
      onDismissed: (_) => _delete(f),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name, style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(
                    '${MetricFormatter.formatWeight(double.parse(f.servingSize.toStringAsFixed(1)))} ${f.servingUnit} - '
                    'P ${f.proteinGrams.round()}g - C ${f.carbsGrams.round()}g - F ${f.fatGrams.round()}g',
                    style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text('${f.calories.round()} kcal', style: AppTypography.monoNumber(fontSize: 13)),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMuted),
              onPressed: () => _delete(f),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(NutritionItem f) async {
    final day = ref.read(dietDateProvider);
    setState(() => _hidden.add(f.id));
    await ref.read(nutritionControllerProvider).deleteMeal(f.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${f.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primaryFixedDim,
          onPressed: () {
            _hidden.remove(f.id);
            ref.read(nutritionControllerProvider).addMeal(f, day);
          },
        ),
      ));
  }

  Widget _dateSwitcher(String day) {
    final isToday = DateKeys.isToday(day);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
            onPressed: () => ref.read(dietDateProvider.notifier).shift(-1),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(dietDateProvider.notifier).reset(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.calendar, size: 15, color: AppColors.primaryCoral),
                  const SizedBox(width: 6),
                  Text(DateKeys.relativeLabel(day), style: AppTypography.titleMedium),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            icon: Icon(LucideIcons.chevronRight, size: 18, color: isToday ? AppColors.surfaceContainerHighest : null),
            onPressed: isToday ? null : () => ref.read(dietDateProvider.notifier).shift(1),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, String title, IconData icon) {
    final isSel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryCoral : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSel ? Colors.white : AppColors.textBody),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontSize: 13, color: isSel ? Colors.white : AppColors.textHeadline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
