import 'package:flutter/material.dart';

class ItineraryStopDetailScreen extends StatelessWidget {
  final String id;

  const ItineraryStopDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết điểm dừng'),
      ),
      body: Center(
        child: Text('TODO: Chi tiết điểm dừng (Stop ID: $id)'),
      ),
    );
  }
}
