import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mất kết nối'),
      ),
      body: const Center(
        child: Text('TODO: Mất kết nối (Offline)'),
      ),
    );
  }
}
