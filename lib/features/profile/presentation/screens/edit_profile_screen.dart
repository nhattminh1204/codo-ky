import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin hồ sơ thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'Cập nhật hồ sơ thất bại.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextInput(
                  controller: _nameController,
                  label: 'Họ và tên',
                  hint: 'Nhập họ và tên mới',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => Validators.required(v, fieldName: 'Họ và tên'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextInput(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  hint: 'Nhập số điện thoại mới',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: Validators.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSave(),
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'Lưu thay đổi',
                  isLoading: authState.isLoading,
                  onPressed: _handleSave,
                  backgroundColor: const Color(0xFF9B1B30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
