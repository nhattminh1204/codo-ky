import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: const Center(
        child: Text('TODO: Chỉnh sửa hồ sơ (Edit Profile)'),
      ),
    );
  }
}
