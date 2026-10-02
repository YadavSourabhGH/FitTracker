import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/metric_formatter.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/services/food_catalog.dart';
import '../../../data/services/nutrition_api_service.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/nutrition_providers.dart';

/// Opens the food picker and logs the chosen food on [day].
Future<void> showFoodSearch(BuildContext context, WidgetRef ref, String day, {String? initialQuery}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FoodSearchSheet(day: day, initialQuery: initialQuery),
  );
}

class FoodSearchSheet extends ConsumerStatefulWidget {
  final String day;
  final String? initialQuery;

  const FoodSearchSheet({super.key, required this.day, this.initialQuery});

  @override
  ConsumerState<FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends ConsumerState<FoodSearchSheet> {
  late final TextEditingController _controller;
  final _api = NutritionApiService();
  List<NutritionItem> _online = const [];
  bool _loading = false;
  String? _error;
  bool _searchedOnline = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if ((widget.initialQuery ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchOnline());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchOnline() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _searchedOnline = true;
    });
    try {
      final items = await _api.searchFood(q);
      if (!mounted) return;
      setState(() {
        _online = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _online = const [];
        _loading = false;
        _error = e is TimeoutException
            ? 'The food database took too long to respond. Check your connection.'
            : 'Could not reach the food database. Showing offline foods only.';
      });
    }
  }

  Future<void> _pick(NutritionItem item) async {
    final added = await showAddFoodDialog(context, ref, item, widget.day);
    if (added && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final recent = ref.watch(recentFoodsProvider).value ?? const <NutritionItem>[];
    final recentFiltered = query.isEmpty
        ? recent
        : recent.where((f) => f.name.toLowerCase().contains(query.toLowerCase())).toList();
    final catalog = FoodCatalog.search(query);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Add food', style: AppTypography.headlineMedium)),
                  TextButton.icon(
                    onPressed: () async {
                      final added = await showCustomFoodDialog(context, ref, widget.day);
                      if (added && context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Custom'),
                  ),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchOnline(),
                onChanged: (_) => setState(() {
                  _searchedOnline = false;
                  _online = const [];
                  _error = null;
                }),
                decoration: InputDecoration(
                  hintText: 'Search foods (e.g. paneer, oats, protein bar)',
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.primaryCoral, size: 20),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() {
                            _controller.clear();
                            _online = const [];
                            _searchedOnline = false;
                          }),
                        ),
                  fillColor: AppColors.scaffoldBase,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  if (query.isNotEmpty && !_searchedOnline)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: OutlinedButton.icon(
                        onPressed: _searchOnline,
                        icon: const Icon(Icons.public, size: 18),
                        label: Text('Search "$query" in Open Food Facts'),
                      ),
                    ),
                  if (_loading) const LoadingBlock(height: 80),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.accentPink)),
                    ),
                  if (_searchedOnline && !_loading && _error == null) ...[
                    _header('Open Food Facts (${_online.length})', 'Values per 100 g'),
                    if (_online.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('No products found online.', style: AppTypography.bodyMedium),
                      ),
                    ..._online.map(_tile),
                  ],
                  if (recentFiltered.isNotEmpty) ...[
                    _header('Recent', 'Last logged serving'),
                    ...recentFiltered.map(_tile),
                  ],
                  _header('Common foods', 'USDA reference values'),
                  if (catalog.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No offline matches. Try an online search.', style: AppTypography.bodyMedium),
                    ),
                  ...catalog.map(_tile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Text(sub, style: AppTypography.labelSmall),
        ],
      ),
    );
  }

  Widget _tile(NutritionItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(item.name, style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${item.brand.isEmpty ? '' : '${item.brand} - '}${MetricFormatter.formatWeight(item.servingSize)} ${item.servingUnit} - '
        '${item.calories.round()} kcal - P ${item.proteinGrams.toStringAsFixed(1)} C ${item.carbsGrams.toStringAsFixed(1)} F ${item.fatGrams.toStringAsFixed(1)}',
        style: AppTypography.bodyMedium.copyWith(fontSize: 11),
      ),
      trailing: const IconBadge(icon: LucideIcons.plus, size: 30, iconSize: 16),
      onTap: () => _pick(item),
    );
  }
}

/// Serving and meal picker; returns true when the food was logged.
Future<bool> showAddFoodDialog(BuildContext context, WidgetRef ref, NutritionItem item, String day) async {
  var servings = 1.0;
  var meal = NutritionItem.mealTypeForNow();
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final scaled = item.scaled(servings, id: 'preview', mealType: meal);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTypography.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  '1 serving = ${MetricFormatter.formatWeight(item.servingSize)} ${item.servingUnit}',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: NutritionItem.mealTypes
                      .map((m) => ChoiceChip(
                            label: Text(m),
                            selected: m == meal,
                            showCheckmark: false,
                            selectedColor: AppColors.primaryCoral,
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: m == meal ? Colors.white : AppColors.textHeadline,
                              fontSize: 11,
                            ),
                            onSelected: (_) => setSheet(() => meal = m),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                NumberStepper(
                  label: 'SERVINGS',
                  value: servings.toStringAsFixed(servings == servings.roundToDouble() ? 0 : 2),
                  onMinus: () => setSheet(() => servings = (servings - 0.5).clamp(0.25, 20.0).toDouble()),
                  onPlus: () => setSheet(() => servings = (servings + 0.5).clamp(0.25, 20.0).toDouble()),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macro('kcal', scaled.calories),
                    _macro('Protein', scaled.proteinGrams, unit: 'g'),
                    _macro('Carbs', scaled.carbsGrams, unit: 'g'),
                    _macro('Fat', scaled.fatGrams, unit: 'g'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final entry = item.scaled(
                        servings,
                        id: 'meal_${DateTime.now().microsecondsSinceEpoch}',
                        mealType: meal,
                      );
                      await ref.read(nutritionControllerProvider).addMeal(entry, day);
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    },
                    child: Text('Add to $meal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  return result ?? false;
}

Widget _macro(String label, double value, {String unit = ''}) {
  return Column(
    children: [
      Text('${value.round()}$unit', style: AppTypography.monoNumber(fontSize: 16, fontWeight: FontWeight.w800)),
      Text(label, style: AppTypography.labelSmall),
    ],
  );
}

/// Manual entry for foods not in any database.
Future<bool> showCustomFoodDialog(BuildContext context, WidgetRef ref, String day) async {
  final name = TextEditingController();
  final kcal = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();
  var meal = NutritionItem.mealTypeForNow();

  double parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: const Text('Custom food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(
                controller: kcal,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: protein,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Protein g'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: carbs,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Carbs g'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: fat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Fat g'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: meal,
                items: NutritionItem.mealTypes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setD(() => meal = v ?? meal),
                decoration: const InputDecoration(labelText: 'Meal'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (name.text.trim().isEmpty || parse(kcal) <= 0) {
                showAppSnack(ctx, 'Enter a name and calories');
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );

  if (ok != true) return false;
  final item = NutritionItem(
    id: 'meal_${DateTime.now().microsecondsSinceEpoch}',
    name: name.text.trim(),
    brand: 'Custom',
    servingSize: 1,
    servingUnit: 'serving',
    calories: parse(kcal),
    proteinGrams: parse(protein),
    carbsGrams: parse(carbs),
    fatGrams: parse(fat),
    mealType: meal,
  );
  await ref.read(nutritionControllerProvider).addMeal(item, day);
  return true;
}
