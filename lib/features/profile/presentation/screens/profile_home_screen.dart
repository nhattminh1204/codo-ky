import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';

class ProfileHomeScreen extends ConsumerStatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  ConsumerState<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends ConsumerState<ProfileHomeScreen> {
  int? _pressedButtonId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 1. STATE (a): LOADING STATE - Skeleton Shimmer UI
    if (authState.isLoading) {
      return _buildLoadingState(context);
    }

    // 2. STATE (c): UNAUTHENTICATED GUEST STATE
    if (!authState.isAuthenticated || authState.user == null) {
      return _buildGuestState(context);
    }

    // 3. STATE (b): AUTHENTICATED USER STATE
    final user = authState.user!;
    return _buildAuthenticatedProfile(context, ref, authState, user);
  }

  // ==========================================
  // STATE (a): LOADING SKELETON / SHIMMER UI
  // ==========================================
  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 180,
              color: AppColors.primary,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    Text(
                      'Hồ sơ cá nhân',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                    ),
                    const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 16, right: 16, bottom: 40),
              child: Shimmer.fromColors(
                baseColor: const Color(0xFFE2E8F0),
                highlightColor: Colors.white,
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 140,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 68,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STATE (c): UNAUTHENTICATED GUEST STATE UI
  // ==========================================
  Widget _buildGuestState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 190,
              color: AppColors.primary,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/map');
                        }
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                    Text(
                      'Hồ sơ cá nhân',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 120),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const CircleAvatar(
                            radius: 42,
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 42,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Khách ghé thăm',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Chưa đăng nhập tài khoản CodoKy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tính năng khi đăng nhập',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildGuestFeatureItem(Icons.auto_awesome_rounded, 'Tạo lộ trình du lịch thông minh bằng AI Gemini'),
                        _buildGuestFeatureItem(Icons.rate_review_outlined, 'Đăng bài đánh giá & nhận xét địa điểm'),
                        _buildGuestFeatureItem(Icons.bookmark_outline_rounded, 'Lưu trữ các chuyến đi yêu thích'),
                        _buildGuestFeatureItem(Icons.workspace_premium_rounded, 'Nâng hạng Thành viên VIP'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // CTA Login Button with Press Scale 0.96
                  GestureDetector(
                    onTapDown: (_) => setState(() => _pressedButtonId = 1),
                    onTapUp: (_) => setState(() => _pressedButtonId = null),
                    onTapCancel: () => setState(() => _pressedButtonId = null),
                    onTap: () => context.push('/login'),
                    child: AnimatedScale(
                      scale: _pressedButtonId == 1 ? AppMotion.pressScale : 1.0,
                      duration: AppMotion.snappy,
                      curve: AppMotion.standardCurve,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.button,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Register Button
                  GestureDetector(
                    onTapDown: (_) => setState(() => _pressedButtonId = 2),
                    onTapUp: (_) => setState(() => _pressedButtonId = null),
                    onTapCancel: () => setState(() => _pressedButtonId = null),
                    onTap: () => context.push('/register'),
                    child: AnimatedScale(
                      scale: _pressedButtonId == 2 ? AppMotion.pressScale : 1.0,
                      duration: AppMotion.snappy,
                      curve: AppMotion.standardCurve,
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.button,
                          border: Border.all(color: AppColors.primary, width: 1.2),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Tạo tài khoản mới',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STATE (b): AUTHENTICATED USER STATE UI
  // ==========================================
  Widget _buildAuthenticatedProfile(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    UserModel user,
  ) {
    final bool isGoldMember = user.isGold;
    final int userPoints = user.rewardPoints;

    final userName = user.name.trim().isNotEmpty ? user.name : 'Người dùng CodoKy';
    final userEmail = user.email.trim().isNotEmpty ? user.email : 'Chưa cập nhật email';
    final userPhone = user.phone;
    final joinedDate = '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140),
        child: Stack(
          children: [
            // 1. HERO FLAT Header Background
            Container(
              height: 180,
              color: AppColors.primary,
            ),

            // TOP APP BAR OVERLAY
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/map');
                        }
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                    Text(
                      'Hồ sơ cá nhân',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // MAIN CONTENT BODY
            Padding(
              padding: const EdgeInsets.only(top: 110),
              child: Column(
                children: [
                  // 2. AVATAR & LEVEL BADGE
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: AppColors.bgLight,
                                backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 44,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ),
                            // Level Badge Chip
                            Positioned(
                              top: -10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isGoldMember ? const Color(0xFFFFB800) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isGoldMember ? Colors.white : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isGoldMember ? Icons.workspace_premium_rounded : Icons.shield_outlined,
                                      size: 12,
                                      color: isGoldMember ? Colors.black87 : const Color(0xFF475569),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      isGoldMember ? 'Thành viên Vàng' : 'Thành viên Thường',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isGoldMember ? Colors.black87 : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => context.push('/profile/edit'),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. QUICK STATS BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppShadows.card,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: 'Lịch trình',
                              label: 'Đã lưu',
                              valueColor: AppColors.primary,
                              onTap: () => context.push('/itinerary/saved'),
                            ),
                          ),
                          Container(height: 24, width: 1, color: AppColors.borderLight),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: 'Đánh giá',
                              label: 'Của tôi',
                              valueColor: AppColors.secondary,
                              onTap: () => context.push('/reviews/my'),
                            ),
                          ),
                          Container(height: 24, width: 1, color: AppColors.borderLight),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: '$userPoints',
                              label: 'Điểm thưởng',
                              valueColor: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // SECTION 1: HÀNH TRÌNH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HÀNH TRÌNH & DỮ LIỆU',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.white,
                          borderRadius: AppRadius.card,
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.card,
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              children: [
                                _buildActionTile(
                                  icon: Icons.map_outlined,
                                  title: 'Lịch trình của tôi',
                                  subtitle: 'Các chuyến đi đã lưu trữ',
                                  onTap: () => context.push('/itinerary/saved'),
                                ),
                                const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: AppColors.borderLight),
                                _buildActionTile(
                                  icon: Icons.rate_review_outlined,
                                  title: 'Đánh giá của tôi',
                                  subtitle: 'Nhận xét & review địa điểm',
                                  onTap: () => context.push('/reviews/my'),
                                ),
                                const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: AppColors.borderLight),
                                _buildActionTile(
                                  icon: Icons.bookmark_outline_rounded,
                                  title: 'Địa điểm đã lưu',
                                  subtitle: 'Xem lại các điểm check-in yêu thích',
                                  onTap: () => context.push('/search'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // SECTION 2: THÔNG TIN CHI TIẾT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THÔNG TIN CÁ NHÂN',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.white,
                          borderRadius: AppRadius.card,
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.card,
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  leading: const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20),
                                  title: const Text('Số điện thoại', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  subtitle: Text(
                                    userPhone.isNotEmpty ? userPhone : 'Chưa cập nhật',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: userPhone.isNotEmpty ? AppColors.textPrimary : AppColors.textLight,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () => context.push('/profile/edit'),
                                    child: const Text(
                                      'Sửa',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: AppColors.borderLight),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  leading: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                                  title: const Text('Ngày tham gia', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  subtitle: Text(
                                    joinedDate,
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // BUTTONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTapDown: (_) => setState(() => _pressedButtonId = 3),
                          onTapUp: (_) => setState(() => _pressedButtonId = null),
                          onTapCancel: () => setState(() => _pressedButtonId = null),
                          onTap: () => context.push('/profile/edit'),
                          child: AnimatedScale(
                            scale: _pressedButtonId == 3 ? AppMotion.pressScale : 1.0,
                            duration: AppMotion.snappy,
                            curve: AppMotion.standardCurve,
                            child: Container(
                              width: double.infinity,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.button,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chỉnh sửa hồ sơ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTapDown: (_) => setState(() => _pressedButtonId = 4),
                          onTapUp: (_) => setState(() => _pressedButtonId = null),
                          onTapCancel: () => setState(() => _pressedButtonId = null),
                          onTap: () => _confirmSignOut(context, ref),
                          child: AnimatedScale(
                            scale: _pressedButtonId == 4 ? AppMotion.pressScale : 1.0,
                            duration: AppMotion.snappy,
                            curve: AppMotion.standardCurve,
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.button,
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng xuất',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required Color valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textLight),
      onTap: onTap,
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: const Text('Đăng xuất tài khoản?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng CodoKy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
