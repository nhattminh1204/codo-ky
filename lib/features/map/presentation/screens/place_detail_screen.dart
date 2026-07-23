import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {
  final String id;

  const PlaceDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết địa điểm'),
      ),
      body: Center(
        child: Text('TODO: Chi tiết địa điểm (ID: $id)'),
      ),
    );
  }
}
