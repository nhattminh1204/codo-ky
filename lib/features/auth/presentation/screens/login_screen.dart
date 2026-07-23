import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/buttons/social_auth_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (success) {
      if (authState.isNewUser) {
        context.go('/onboarding-profile');
      } else {
        context.go('/map');
      }
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (success) {
      if (authState.isNewUser) {
        context.go('/onboarding-profile');
      } else {
        context.go('/map');
      }
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập Apple trên Android cần cấu hình Service ID trên Apple Developer Portal.'),
        ),
      );
      return;
    }
    final success = await ref.read(authProvider.notifier).loginWithApple();
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (success) {
      if (authState.isNewUser) {
        context.go('/onboarding-profile');
      } else {
        context.go('/map');
      }
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
        title: const Text('Đăng nhập'),
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
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B1B30),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B1B30).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chào mừng tới CodoKy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9B1B30),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Khám phá di sản & văn hóa Cố đô Huế',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 32),

                // Email
                TextInput(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Nhập địa chỉ email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password
                TextInput(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu (tối thiểu 8 ký tự)',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) => Validators.password(v, minLength: 8),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                PrimaryButton(
                  text: 'Đăng nhập',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                  backgroundColor: const Color(0xFF9B1B30),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hoặc đăng nhập với',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Buttons
                SocialAuthButton(
                  type: SocialType.google,
                  isLoading: authState.isLoading,
                  onPressed: _handleGoogleLogin,
                ),
                const SizedBox(height: 12),
                SocialAuthButton(
                  type: SocialType.apple,
                  isLoading: authState.isLoading,
                  onPressed: _handleAppleLogin,
                ),
                const SizedBox(height: 28),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Color(0xFF9B1B30),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
