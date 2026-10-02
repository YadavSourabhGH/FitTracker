import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/diet_suggestion_model.dart';
import '../../../../data/models/user_settings.dart';
import '../../../../data/services/diet_suggestion_service.dart';
import '../../../common_widgets/icon_map.dart';
import '../../../common_widgets/ui_kit.dart';

/// Evidence-based nutrition guidance filtered by category.
class DietSuggestionsView extends StatefulWidget {
  final FitnessGoal goal;
  final ValueChanged<String>? onAddFoodQuery;

  const DietSuggestionsView({super.key, this.goal = FitnessGoal.maintain, this.onAddFoodQuery});

  @override
  State<DietSuggestionsView> createState() => _DietSuggestionsViewState();
}

class _DietSuggestionsViewState extends State<DietSuggestionsView> {
  final _service = DietSuggestionService();
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Muscle Gain', 'Fat Loss', 'Recovery', 'Energy'];

  String get _goalCategory {
    switch (widget.goal) {
      case FitnessGoal.lose:
        return 'Fat Loss';
      case FitnessGoal.gain:
        return 'Muscle Gain';
      case FitnessGoal.maintain:
        return 'Recovery';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _service.getByCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const IconBadge(icon: LucideIcons.target),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your goal is "${widget.goal.label}". Suggestions tagged $_goalCategory are most relevant. '
                  'Tap a food to look it up and log it.',
                  style: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSel = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSel ? Colors.white : AppColors.textHeadline,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                  selectedColor: AppColors.primaryCoral,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSel ? AppColors.primaryCoral : AppColors.cardBorder),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        ...list.map(_buildCard),
      ],
    );
  }

  Widget _buildCard(DietSuggestion item) {
    final relevant = item.category == _goalCategory;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: iconForName(item.iconName), size: 30, iconSize: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.title, style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Pill(label: item.timing, background: AppColors.accentBlueLight, foreground: AppColors.accentBlue),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Pill(label: item.category, background: AppColors.surfaceContainer, foreground: AppColors.textBody),
              if (relevant) ...[
                const SizedBox(width: 6),
                const Pill(
                  label: 'Matches your goal',
                  background: AppColors.accentGreenLight,
                  foreground: AppColors.onSecondaryContainer,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(item.recommendation, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
          const SizedBox(height: 12),
          Text('Recommended foods', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.foods
                .map((food) => ActionChip(
                      avatar: const Icon(LucideIcons.plus, size: 12, color: AppColors.primaryCoral),
                      label: Text(food, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                      backgroundColor: AppColors.scaffoldBase,
                      side: const BorderSide(color: AppColors.cardBorder),
                      onPressed: () => widget.onAddFoodQuery?.call(food),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
