import 'package:flutter/material.dart';

class CategoryListScreen extends StatelessWidget {
  final String categoryId;

  const CategoryListScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục địa điểm'),
      ),
      body: Center(
        child: Text('TODO: Danh mục địa điểm (Category ID: $categoryId)'),
      ),
    );
  }
}
