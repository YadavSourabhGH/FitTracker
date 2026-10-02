import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_keys.dart';
import '../../data/models/nutrition_model.dart';
import 'app_providers.dart';
import 'stats_providers.dart';

/// Day being viewed on the Diet screen.
class DietDateNotifier extends Notifier<String> {
  @override
  String build() => DateKeys.today();

  void shift(int days) {
    final next = DateKeys.shift(state, days);
    if (next.compareTo(DateKeys.today()) > 0) return;
    state = next;
  }

  void reset() => state = DateKeys.today();
}

final dietDateProvider = NotifierProvider<DietDateNotifier, String>(DietDateNotifier.new);

final mealsForDateProvider = FutureProvider.family<List<NutritionItem>, String>((ref, day) {
  return ref.watch(nutritionRepositoryProvider).getLoggedMeals(day);
});

final recentFoodsProvider = FutureProvider<List<NutritionItem>>((ref) {
  return ref.watch(nutritionRepositoryProvider).recentFoods();
});

final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final meals = await ref.watch(mealsForDateProvider(DateKeys.today()).future);
  return meals.fold<double>(0, (sum, m) => sum + m.calories);
});

/// Write operations for meals; invalidates dependent providers.
class NutritionController {
  final Ref ref;
  NutritionController(this.ref);

  Future<void> addMeal(NutritionItem item, String day) async {
    await ref.read(nutritionRepositoryProvider).addMeal(item, day);
    _refresh();
  }

  Future<void> deleteMeal(String id) async {
    await ref.read(nutritionRepositoryProvider).deleteMeal(id);
    _refresh();
  }

  void _refresh() {
    ref.invalidate(mealsForDateProvider);
    ref.invalidate(recentFoodsProvider);
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(userStatsProvider);
  }
}

final nutritionControllerProvider = Provider<NutritionController>((ref) => NutritionController(ref));

/// Today's water intake in glasses.
class WaterNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(hydrationRepositoryProvider).getGlasses(DateKeys.today());

  Future<void> add(int delta) async {
    final current = state.value ?? 0;
    final next = (current + delta).clamp(0, 40);
    state = AsyncValue.data(next);
    await ref.read(hydrationRepositoryProvider).setGlasses(DateKeys.today(), next);
    ref.invalidate(userStatsProvider);
  }
}

final waterTodayProvider = AsyncNotifierProvider<WaterNotifier, int>(WaterNotifier.new);

final weightHistoryProvider = FutureProvider<List<MapEntry<String, double>>>((ref) {
  return ref.watch(hydrationRepositoryProvider).weightHistory();
});
