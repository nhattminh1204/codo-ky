import 'package:flutter/material.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class TravelCategorySelector extends StatelessWidget {
  final String selectedCategoryId;
  final Function(String) onSelectCategory;

  const TravelCategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  static const List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.explore_rounded},
    {'id': 'attraction', 'name': 'Di tích', 'icon': Icons.account_balance_rounded},
    {'id': 'food', 'name': 'Ẩm thực', 'icon': Icons.restaurant_rounded},
    {'id': 'cafe', 'name': 'Cà phê', 'icon': Icons.local_cafe_rounded},
    {'id': 'stay', 'name': 'Lưu trú', 'icon': Icons.hotel_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final id = cat['id'] as String;
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = id == selectedCategoryId;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectCategory(id),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
