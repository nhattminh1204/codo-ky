import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/buttons/social_auth_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (success) {
      context.go('/onboarding-profile');
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
        SnackBar(
          content: Text(context.l10n.appleAndroidWarning),
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerAppBar),
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
                Text(
                  l10n.createNewAccount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.registerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),

                // Name
                TextInput(
                  controller: _nameController,
                  label: l10n.fullName,
                  hint: l10n.fullNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => Validators.required(v, fieldName: l10n.fullName, l10n: l10n),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email
                TextInput(
                  controller: _emailController,
                  label: l10n.email,
                  hint: l10n.emailAddressHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) => Validators.email(v, l10n),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Phone
                TextInput(
                  controller: _phoneController,
                  label: l10n.phoneNumber,
                  hint: l10n.phoneHint,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) => Validators.phone(v, l10n),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password
                TextInput(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) => Validators.password(v, minLength: 8, l10n: l10n),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextInput(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  hint: l10n.confirmPasswordHint,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text, l10n),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                PrimaryButton(
                  text: l10n.signUp,
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orRegisterWith,
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

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        l10n.loginNow,
                        style: const TextStyle(
                          color: AppColors.primary,
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
