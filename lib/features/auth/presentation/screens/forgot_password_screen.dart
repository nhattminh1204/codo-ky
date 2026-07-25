import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/cards/app_card.dart';
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
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Nhập email đã đăng ký tài khoản CodoKy của bạn để nhận liên kết khôi phục mật khẩu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.lg),

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
                  const SizedBox(height: AppSpacing.lg),

                  PrimaryButton(
                    text: 'Gửi yêu cầu khôi phục',
                    useGradient: true,
                    isLoading: authState.isLoading,
                    onPressed: _handleResetPassword,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
