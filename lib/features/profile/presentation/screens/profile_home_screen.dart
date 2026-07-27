import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Dynamic membership tier logic (Gold vs Standard Member)
    final bool isGoldMember = user?.isGold ?? true; // Default to true for design preview
    final int userPoints = user?.rewardPoints ?? (isGoldMember ? 350 : 120);

    // Fallback user values matching the design mockup when user data is empty or loading
    final userName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : 'Nguyễn Văn Minh Nhật';
    final userEmail = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : 'nhattminh1204@gmail.com';
    final userPhone = user?.phone ?? '';
    final joinedDate = user != null
        ? '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}'
        : '25/07/2026';

    final userPreferences = (user?.preferences != null && user!.preferences.isNotEmpty)
        ? user.preferences.map((p) => '${_getPreferenceEmoji(p)} $p').toList()
        : ['✈️ Du lịch bụi', '☕ Cà phê đẹp', '📸 Nhiếp ảnh', '⛰️ Dã ngoại'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140),
        child: Stack(
          children: [
            // 1. HERO GRADIENT BACKGROUND BANNER (SOFT SUNSET AMBER GRADIENT)
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative glowing circle right
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Decorative glowing circle left
                  Positioned(
                    left: 20,
                    top: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TOP APP BAR OVERLAY
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button (Dark Translucent Circle)
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/map');
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),

                    // Screen Title
                    const Text(
                      'Hồ sơ cá nhân',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1)),
                        ],
                      ),
                    ),

                    // Settings Button with Online Status Badge
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // MAIN CONTENT BODY (STACKED BELOW TOP BANNER)
            Padding(
              padding: const EdgeInsets.only(top: 110),
              child: Column(
                children: [
                  // 2. AVATAR & DYNAMIC LEVEL BADGE SECTION (GOLD VS STANDARD MEMBER)
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Avatar Outer Container (Gold Gradient Glow for Gold, Silver Slate for Standard)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isGoldMember
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isGoldMember
                                        ? const Color(0xFFFF5E62).withValues(alpha: 0.35)
                                        : Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: Colors.white,
                                backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 48,
                                        color: isGoldMember ? const Color(0xFFFF5E62) : const Color(0xFF64748B),
                                      )
                                    : null,
                              ),
                            ),

                            // Dynamic Level Badge Top Center (Gold vs Standard Member)
                            Positioned(
                              top: -12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: OverflowBox(
                                  maxWidth: double.infinity,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: isGoldMember ? const Color(0xFFFFB800) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isGoldMember ? Colors.white : const Color(0xFFCBD5E1),
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isGoldMember ? Icons.workspace_premium_rounded : Icons.shield_outlined,
                                          size: 13,
                                          color: isGoldMember ? Colors.black87 : const Color(0xFF475569),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          isGoldMember ? 'Thành viên Vàng' : 'Thành viên Thường',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: isGoldMember ? Colors.black87 : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Camera Edit Overlay Button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => context.push('/profile/edit'),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1C22),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Name & Verified Checkmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: isGoldMember ? const Color(0xFF2196F3) : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. QUICK STATS BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: '12',
                              label: 'Lịch trình',
                              valueColor: const Color(0xFFFF7A00),
                            ),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFF1F5F9)),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: '4.9 ★',
                              label: '48 Đánh giá',
                              valueColor: const Color(0xFFFFB800),
                            ),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFF1F5F9)),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              value: '$userPoints',
                              label: 'Điểm thưởng',
                              valueColor: isGoldMember ? const Color(0xFF00B87C) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic Gold Member Upgrade Banner (Only shown if Standard Member)
                  if (!isGoldMember) ...[
                    const SizedBox(height: AppSpacing.sm + 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nâng hạng Thành viên Vàng',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                  ),
                                  Text(
                                    'Tích thêm ${300 - userPoints > 0 ? 300 - userPoints : 0} điểm để nhận ưu đãi VIP cá nhân.',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/explore'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Khám phá >',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // SECTION 1: HÀNH TRÌNH & ĐÁNH GIÁ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.explore_outlined, size: 18, color: Color(0xFFFF7A00)),
                            SizedBox(width: 8),
                            Text(
                              'HÀNH TRÌNH & ĐÁNH GIÁ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Menu item 1: Lịch trình
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4EB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.map_outlined, color: Color(0xFFFF7A00), size: 20),
                                ),
                                title: const Text(
                                  'Lịch trình của tôi',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
                                ),
                                subtitle: const Text(
                                  'Xem danh sách các chuyến đi đã lưu',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEAD8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '12 chuyến',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                                  ],
                                ),
                                onTap: () => context.push('/itinerary/saved'),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

                              // Menu item 2: Đánh giá
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.rate_review_outlined, color: Color(0xFFFF5E62), size: 20),
                                ),
                                title: const Text(
                                  'Đánh giá của tôi',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
                                ),
                                subtitle: const Text(
                                  'Quản lý nhận xét & review địa điểm',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                                onTap: () => context.push('/reviews/my'),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

                              // Menu item 3: Địa điểm đã lưu
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.bookmark_outline_rounded, color: Color(0xFF00B87C), size: 20),
                                ),
                                title: const Text(
                                  'Địa điểm đã lưu',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
                                ),
                                subtitle: const Text(
                                  '24 quán cà phê & điểm check-in',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                                onTap: () => context.push('/search'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // SECTION 2: THÔNG TIN CHI TIẾT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_outline, size: 18, color: Color(0xFFFF7A00)),
                            SizedBox(width: 8),
                            Text(
                              'THÔNG TIN CHI TIẾT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Số điện thoại
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.phone_outlined, color: Color(0xFF475569), size: 18),
                                ),
                                title: const Text('Số điện thoại', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                subtitle: userPhone.isNotEmpty
                                    ? Text(
                                        userPhone,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      )
                                    : const Text(
                                        'Chưa cập nhật',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                                      ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4EB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () => context.push('/profile/edit'),
                                    child: const Text(
                                      '+ Thêm',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

                              // Ngày tham gia
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF475569), size: 18),
                                ),
                                title: const Text('Ngày tham gia', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                subtitle: Text(
                                  joinedDate,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF00B87C).withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'Đã xác thực',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF00B87C)),
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

                              // Sở thích cá nhân
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.favorite_outline, color: Color(0xFFFF5E62), size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Sở thích cá nhân',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push('/profile/edit'),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.add, size: 14, color: Color(0xFFFF7A00)),
                                              SizedBox(width: 2),
                                              Text(
                                                'Chỉnh sửa',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm + 2),
                                    _buildMockupPastelChips(userPreferences),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ACTION BUTTONS (PRIMARY SUNSET GRADIENT EDIT + MINIMAL NEUTRAL LOGOUT)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        // Nút Chỉnh sửa hồ sơ Gradient Sunset
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5E62).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => context.push('/profile/edit'),
                              borderRadius: BorderRadius.circular(16),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 22, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chỉnh sửa hồ sơ',
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
                        const SizedBox(height: AppSpacing.sm + 4),

                        // Nút Đăng xuất dạng Minimalist
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Text('Xác nhận đăng xuất'),
                                    content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Đăng xuất',
                                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref.read(authProvider.notifier).logout();
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 18, color: Color(0xFF64748B)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng xuất tài khoản',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),
                        // Delete Account (App Store Compliance)
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Text('Xác nhận xóa tài khoản'),
                                      content: const Text(
                                        'CẢNH BÁO: Hành động này sẽ xóa toàn bộ dữ liệu cá nhân của bạn trên ứng dụng CodoKy và không thể khôi phục.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text(
                                            'Xóa vĩnh viễn',
                                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    final success = await ref.read(authProvider.notifier).deleteAccount();
                                    if (context.mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Tài khoản của bạn đã được xóa thành công.'),
                                          ),
                                        );
                                        context.go('/login');
                                      } else {
                                        final err = ref.read(authProvider).error;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(err ?? 'Không thể xóa tài khoản. Vui lòng thử lại.'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          child: const Text(
                            'Xóa tài khoản cá nhân',
                            style: TextStyle(color: AppColors.error, fontSize: 12),
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

  Widget _buildStatItem(BuildContext context, {required String value, required String label, required Color valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildMockupPastelChips(List<String> labels) {
    final List<Map<String, Color>> chipStyles = [
      {
        'bg': const Color(0xFFFFF8E7),
        'border': const Color(0xFFFDE68A),
        'text': const Color(0xFFD97706),
      },
      {
        'bg': const Color(0xFFF3E8FF),
        'border': const Color(0xFFE9D5FF),
        'text': const Color(0xFF9333EA),
      },
      {
        'bg': const Color(0xFFE0F2FE),
        'border': const Color(0xFFBAE6FD),
        'text': const Color(0xFF0284C7),
      },
      {
        'bg': const Color(0xFFDCFCE7),
        'border': const Color(0xFFBBF7D0),
        'text': const Color(0xFF16A34A),
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final style = chipStyles[index % chipStyles.length];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: style['bg'],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: style['border']!,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: style['text'],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPreferenceEmoji(String pref) {
    final lower = pref.toLowerCase();
    if (lower.contains('ẩm thực') || lower.contains('food')) return '🍜';
    if (lower.contains('lịch sử') || lower.contains('di sản') || lower.contains('history')) return '🏰';
    if (lower.contains('tâm linh') || lower.contains('chùa') || lower.contains('temple')) return '⛩️';
    if (lower.contains('thiên nhiên') || lower.contains('nature')) return '🌿';
    if (lower.contains('cafe') || lower.contains('cà phê')) return '☕';
    if (lower.contains('mua sắm') || lower.contains('shopping')) return '🛍️';
    if (lower.contains('nghệ thuật') || lower.contains('nhạc')) return '🎶';
    if (lower.contains('nhiếp ảnh') || lower.contains('ảnh')) return '📸';
    if (lower.contains('dã ngoại')) return '⛰️';
    return '✈️';
  }
}
