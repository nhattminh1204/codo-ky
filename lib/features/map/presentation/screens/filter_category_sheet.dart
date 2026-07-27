import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

class FilterCategorySheet extends ConsumerStatefulWidget {
  const FilterCategorySheet({super.key});

  @override
  ConsumerState<FilterCategorySheet> createState() => _FilterCategorySheetState();
}

class _FilterCategorySheetState extends ConsumerState<FilterCategorySheet> {
  final Set<String> _selectedCategories = {};

  final List<Map<String, dynamic>> _categories = const [
    {
      'id': 'attraction',
      'label': 'Địa điểm & Di tích',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFFFF5E62),
    },
    {
      'id': 'restaurant',
      'label': 'Nhà hàng & Ẩm thực',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFFF7A00),
    },
    {
      'id': 'temple',
      'label': 'Chùa & Tâm linh',
      'icon': Icons.temple_buddhist_rounded,
      'color': Color(0xFF9333EA),
    },
    {
      'id': 'tomb',
      'label': 'Lăng tẩm Triều Nguyễn',
      'icon': Icons.castle_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'id': 'cafe',
      'label': 'Cafe & Trà Huế',
      'icon': Icons.coffee_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'id': 'shopping',
      'label': 'Chợ & Mua sắm',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF16A34A),
    },
    {
      'id': 'culture',
      'label': 'Nghệ thuật & Văn hóa',
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bộ lọc danh mục',
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
          const SizedBox(height: 8),
          Text(
            'Chọn một hoặc nhiều danh mục để lọc marker trên bản đồ:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _categories.map((cat) {
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
                  child: const Text('Đặt lại', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B1B30),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
