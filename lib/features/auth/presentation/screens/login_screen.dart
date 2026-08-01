import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:codoky/core/widgets/buttons/social_auth_button.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/auth/presentation/widgets/hue_background_art.dart';
import 'package:codoky/features/auth/presentation/widgets/hue_brand_logo.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _titleFadeAnim;
  late Animation<Offset> _titleSlideAnim;
  late Animation<double> _subtitleFadeAnim;
  late Animation<Offset> _subtitleSlideAnim;
  late Animation<double> _buttonsFadeAnim;
  late Animation<Offset> _buttonsSlideAnim;
  bool _isInitialized = false;
  String _currentLang = 'VI';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animController?.forward();
  }

  void _setupAnimations() {
    _animController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _logoScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );
    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _titleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
      ),
    );
    _subtitleSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _buttonsFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonsSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _isInitialized = true;
  }

  @override
  void reassemble() {
    super.reassemble();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
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
          backgroundColor: const Color(0xFF8B1522),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng nhập Apple trên Android cần cấu hình Service ID trên Apple Developer Portal.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          backgroundColor: const Color(0xFF8B1522),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == 'VI' ? 'EN' : 'VI';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _setupAnimations();
      _animController?.forward();
    }

    final authState = ref.watch(authProvider);

    return GlassScaffold(
      background: const HueBackgroundArt(),
      backgroundColor: const Color(0xFFF9F5EF), // Fallback color
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Language Switcher Bar (VI | EN)
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: _toggleLanguage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC89B3C).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFC89B3C).withValues(alpha: 0.38),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.language,
                                  size: 14,
                                  color: Color(0xFF8B1522),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'VI',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _currentLang == 'VI'
                                        ? const Color(0xFF8B1522)
                                        : const Color(0xFF756E65),
                                  ),
                                ),
                                const Text(
                                  ' | ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFC89B3C),
                                  ),
                                ),
                                Text(
                                  'EN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _currentLang == 'EN'
                                        ? const Color(0xFF8B1522)
                                        : const Color(0xFF756E65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Wrap main content in a GlassCard
                      GlassCard(
                        shape: const LiquidRoundedRectangle(borderRadius: 36),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo with Golden Halo Ring Background
                            FadeTransition(
                              opacity: _logoFadeAnim,
                              child: ScaleTransition(
                                scale: _logoScaleAnim,
                                child: const HueBrandLogo(size: 104),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Title ("Chào mừng tới CodoKy")
                            SlideTransition(
                              position: _titleSlideAnim,
                              child: FadeTransition(
                                opacity: _titleFadeAnim,
                                child: Text(
                                  'Chào mừng tới CodoKy',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                    color: const Color(0xFF8B1522),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Gold Floral Ornament Divider Line
                            SlideTransition(
                              position: _subtitleSlideAnim,
                              child: FadeTransition(
                                opacity: _subtitleFadeAnim,
                                child: SizedBox(
                                  width: 170,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 1.2,
                                        color: const Color(0xFFC89B3C).withValues(alpha: 0.65),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Icon(
                                          Icons.filter_vintage_outlined,
                                          size: 20,
                                          color: Color(0xFFC89B3C),
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 1.2,
                                        color: const Color(0xFFC89B3C).withValues(alpha: 0.65),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Subtitle with High Contrast
                            SlideTransition(
                              position: _subtitleSlideAnim,
                              child: FadeTransition(
                                opacity: _subtitleFadeAnim,
                                child: const Text(
                                  'Khám phá di sản • Văn hóa • Ẩm thực Huế',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700, // Maximum legibility & contrast
                                    color: Color(0xFF6B1D28), // Dark Vermilion Crimson
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),

                            // Login Options Group
                            SlideTransition(
                              position: _buttonsSlideAnim,
                              child: FadeTransition(
                                opacity: _buttonsFadeAnim,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 32),

                                    // 1. Google Button
                                    SocialAuthButton(
                                      type: SocialType.google,
                                      isLoading: authState.isLoading,
                                      onPressed: _handleGoogleLogin,
                                    ),

                                    const SizedBox(height: 18),

                                    // 2. Apple Button
                                    SocialAuthButton(
                                      type: SocialType.apple,
                                      isLoading: authState.isLoading,
                                      onPressed: _handleAppleLogin,
                                    ),

                                    const SizedBox(height: 32),

                                    // Centered Footer Terms
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC89B3C).withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.verified_user_outlined,
                                            size: 16,
                                            color: Color(0xFFC89B3C),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text.rich(
                                            textAlign: TextAlign.center,
                                            TextSpan(
                                              text: 'Bằng việc tiếp tục, bạn đồng ý với ',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF3D352E),
                                                height: 1.45,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Điều khoản dịch vụ',
                                                  style: TextStyle(
                                                    color: const Color(0xFF8B1522),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const TextSpan(text: ' &\n'),
                                                TextSpan(
                                                  text: 'Chính sách bảo mật',
                                                  style: TextStyle(
                                                    color: const Color(0xFF8B1522),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const TextSpan(text: ' của CodoKy.'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
