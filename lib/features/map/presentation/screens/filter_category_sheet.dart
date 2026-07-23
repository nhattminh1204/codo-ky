import 'package:flutter/material.dart';

class FilterCategorySheet extends StatelessWidget {
  const FilterCategorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Bộ lọc danh mục',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('TODO: Bộ lọc danh mục (Filter Category Sheet)'),
        ],
      ),
    );
  }
}
