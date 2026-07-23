import 'package:flutter/material.dart';

class OnboardingProfileScreen extends StatelessWidget {
  const OnboardingProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn sở thích'),
      ),
      body: const Center(
        child: Text('TODO: Chọn sở thích lần đầu (Onboarding Profile)'),
      ),
    );
  }
}
