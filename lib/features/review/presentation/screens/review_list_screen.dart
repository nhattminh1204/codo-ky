import 'package:flutter/material.dart';

class ReviewListScreen extends StatelessWidget {
  final String? placeId;

  const ReviewListScreen({
    super.key,
    this.placeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đánh giá'),
      ),
      body: Center(
        child: Text('TODO: Danh sách đánh giá ${placeId != null ? "(Place ID: $placeId)" : ""}'),
      ),
    );
  }
}
