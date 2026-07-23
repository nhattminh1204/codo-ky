import 'package:flutter/material.dart';

class ProfileHomeScreen extends StatelessWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: const Center(
        child: Text('TODO: Hồ sơ cá nhân (Profile Home)'),
      ),
    );
  }
}
