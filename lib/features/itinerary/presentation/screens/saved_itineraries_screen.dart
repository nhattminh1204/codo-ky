import 'package:flutter/material.dart';

class SavedItinerariesScreen extends StatelessWidget {
  const SavedItinerariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình đã lưu'),
      ),
      body: const Center(
        child: Text('TODO: Lịch trình đã lưu (Saved Itineraries)'),
      ),
    );
  }
}
