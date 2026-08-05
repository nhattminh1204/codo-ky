import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

class FilterCategorySheet extends ConsumerStatefulWidget {
  const FilterCategorySheet({super.key});

  @override
  ConsumerState<FilterCategorySheet> createState() => _FilterCategorySheetState();
}

class _FilterCategorySheetState extends ConsumerState<FilterCategorySheet> {
  final Set<String> _selectedCategories = {};

  List<Map<String, dynamic>> _categories(AppLocalizations l10n) => [
        {
          'id': 'saved',
          'label': l10n.savedCategory,
          'icon': Icons.bookmark_rounded,
          'color': Color(0xFFE11D48),
        },
        {
          'id': 'attraction',
          'label': l10n.attractionCategory,
          'icon': Icons.account_balance_rounded,
          'color': Color(0xFFFF5E62),
        },
        {
          'id': 'restaurant',
          'label': l10n.restaurantCategory,
          'icon': Icons.restaurant_rounded,
          'color': Color(0xFFFF7A00),
        },
        {
          'id': 'temple',
          'label': l10n.templeCategory,
          'icon': Icons.temple_buddhist_rounded,
          'color': Color(0xFF9333EA),
        },
        {
          'id': 'tomb',
          'label': l10n.tombCategory,
          'icon': Icons.castle_rounded,
          'color': Color(0xFFD97706),
        },
        {
          'id': 'cafe',
          'label': l10n.cafeCategory,
          'icon': Icons.coffee_rounded,
          'color': Color(0xFF0284C7),
        },
        {
          'id': 'shopping',
          'label': l10n.shoppingCategory,
          'icon': Icons.shopping_bag_rounded,
          'color': Color(0xFF16A34A),
        },
        {
          'id': 'culture',
          'label': l10n.cultureCategory,
          'icon': Icons.music_note_rounded,
          'color': Color(0xFFE11D48),
        },
      ];

  @override
  void initState() {
    super.initState();
    final currentCat = ref.read(mapProvider).selectedCategory;
    final currentCats = ref.read(mapProvider).selectedCategories;

    if (currentCats.isNotEmpty) {
      _selectedCategories.addAll(currentCats);
    } else if (currentCat != null && currentCat != 'all') {
      _selectedCategories.add(currentCat);
    }
  }

  void _toggleCategory(String catId) {
    setState(() {
      if (_selectedCategories.contains(catId)) {
        _selectedCategories.remove(catId);
      } else {
        _selectedCategories.add(catId);
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedCategories.clear();
    });
    ref.read(mapProvider.notifier).filterByCategories({});
    Navigator.pop(context);
  }

  void _apply() {
    ref.read(mapProvider.notifier).filterByCategories(_selectedCategories);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = _categories(l10n);
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      expand: false,
      snap: true,
      snapSizes: const [0.40, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 36),
            children: [
              // Visual Drag Handle Pill (Kéo lên / kéo xuống để mở rộng/thu gọn)
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.filterTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.filterSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: categories.map((cat) {
                  final catId = cat['id'] as String;
                  final label = cat['label'] as String;
                  final icon = cat['icon'] as IconData;
                  final color = cat['color'] as Color;
                  final isSelected = _selectedCategories.contains(catId);

                  return FilterChip(
                    showCheckmark: true,
                    avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : color),
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: color,
                    backgroundColor: color.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? color : color.withValues(alpha: 0.3),
                      ),
                    ),
                    onSelected: (_) => _toggleCategory(catId),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(l10n.reset, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(l10n.apply, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
