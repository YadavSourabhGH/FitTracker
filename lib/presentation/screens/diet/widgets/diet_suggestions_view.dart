import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/diet_suggestion_model.dart';
import '../../../../data/services/diet_suggestion_service.dart';

/// View presenting interactive evidence-based diet suggestions with category filters.
class DietSuggestionsView extends StatefulWidget {
  final ValueChanged<String>? onAddFoodQuery;

  const DietSuggestionsView({super.key, this.onAddFoodQuery});

  @override
  State<DietSuggestionsView> createState() => _DietSuggestionsViewState();
}

class _DietSuggestionsViewState extends State<DietSuggestionsView> {
  final _service = DietSuggestionService();
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Muscle Gain', 'Fat Loss', 'Recovery', 'Energy'];

  @override
  Widget build(BuildContext context) {
    final list = _service.getByCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Row
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

        // List of Suggestion Cards
        ...list.map((item) => _buildCard(item)),
      ],
    );
  }

  Widget _buildCard(DietSuggestion item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primaryCoralLight, shape: BoxShape.circle),
                child: Icon(_getIcon(item.iconName), size: 16, color: AppColors.primaryCoral),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accentBlueLight, borderRadius: BorderRadius.circular(10)),
                child: Text(item.timing, style: AppTypography.labelSmall.copyWith(color: AppColors.accentBlue, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.recommendation, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
          const SizedBox(height: 12),

          Text('Recommended Foods:', style: AppTypography.labelSmall.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.foods.map((food) => ActionChip(
              avatar: const Icon(LucideIcons.plus, size: 12, color: AppColors.primaryCoral),
              label: Text(food, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
              backgroundColor: AppColors.scaffoldBase,
              side: const BorderSide(color: AppColors.cardBorder),
              onPressed: () => widget.onAddFoodQuery?.call(food),
            )).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'dumbbell': return LucideIcons.dumbbell;
      case 'zap': return LucideIcons.zap;
      case 'scale': return LucideIcons.scale;
      case 'moon': return LucideIcons.moon;
      case 'droplets': return LucideIcons.droplets;
      default: return LucideIcons.sparkles;
    }
  }
}
