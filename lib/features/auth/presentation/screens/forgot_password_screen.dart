import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).forgotPassword(_emailController.text);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hộp thư của bạn!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
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
        title: const Text('Quên mật khẩu'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Đặt lại mật khẩu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9B1B30),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập email đã đăng ký tài khoản CodoKy của bạn để nhận liên kết khôi phục mật khẩu.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 28),

                TextInput(
                  controller: _emailController,
                  label: 'Email đăng ký',
                  hint: 'Nhập địa chỉ email của bạn',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Gửi yêu cầu khôi phục',
                  isLoading: authState.isLoading,
                  onPressed: _handleResetPassword,
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
