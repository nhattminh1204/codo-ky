import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/providers/theme_provider.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ProfileHomeScreen extends ConsumerStatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  ConsumerState<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends ConsumerState<ProfileHomeScreen> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassScaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.profileTitle, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 40),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.4),
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
              const SizedBox(height: 40),
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
    );
  }

  // ==========================================
  // STATE (c): UNAUTHENTICATED GUEST STATE UI
  // ==========================================
  Widget _buildGuestState(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassScaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.profileTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showThemeSelectionSheet(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 120),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white54,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 42,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.guestWelcome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.guestSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGuestFeatureItem(Icons.bookmark_outline_rounded, l10n.guestFeature1),
                  _buildGuestFeatureItem(Icons.map_outlined, l10n.guestFeature2),
                  _buildGuestFeatureItem(Icons.workspace_premium_outlined, l10n.guestFeature3),
                  const SizedBox(height: 16),
                  GlassButton.custom(
                    width: double.infinity,
                    onTap: () => context.push('/login'),
                    child: Text(l10n.loginRegister, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
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
    final l10n = context.l10n;

    final userName = user.name.trim().isNotEmpty ? user.name : l10n.defaultUserName;
    final userEmail = user.email.trim().isNotEmpty ? user.email : l10n.noEmailYet;
    final userPhone = user.phone;
    final joinedDate = '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.profileTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showThemeSelectionSheet(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140),
        child: Column(
          children: [
            const SizedBox(height: 16),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white24 : Colors.white54,
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
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          shape: const LiquidRoundedRectangle(borderRadius: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGoldMember ? Icons.workspace_premium_rounded : Icons.shield_outlined,
                                size: 12,
                                color: isGoldMember ? const Color(0xFFC89B3C) : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isGoldMember ? l10n.goldMember : l10n.regularMember,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isGoldMember ? const Color(0xFFC89B3C) : const Color(0xFF475569),
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. QUICK STATS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        value: l10n.statItinerary,
                        label: l10n.statSaved,
                        valueColor: AppColors.primary,
                        onTap: () => context.push('/itinerary/saved'),
                      ),
                    ),
                    Container(height: 24, width: 1, color: AppColors.borderLight.withValues(alpha: 0.2)),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        value: l10n.statReviews,
                        label: l10n.statOfMine,
                        valueColor: AppColors.secondary,
                        onTap: () => context.push('/reviews/my'),
                      ),
                    ),
                    Container(height: 24, width: 1, color: AppColors.borderLight.withValues(alpha: 0.2)),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        value: '$userPoints',
                        label: l10n.statPoints,
                        valueColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 1: HÀNH TRÌNH
            GlassGroupedSection(
              header: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(l10n.journeyData, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              children: [
                GlassListTile(
                  leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                  title: Text(l10n.myItineraries, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.mySavedTripsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/itinerary/saved'),
                ),
                GlassListTile(
                  leading: const Icon(Icons.rate_review_outlined, color: AppColors.primary),
                  title: Text(l10n.myReviews, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.myReviewsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/reviews/my'),
                ),
                GlassListTile(
                  leading: const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary),
                  title: Text(l10n.savedPlaces, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.savedPlacesSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/search'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 2: THÔNG TIN CHI TIẾT
            GlassGroupedSection(
              header: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(l10n.personalInfoHeader, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              children: [
                GlassListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(l10n.phoneNumber),
                  subtitle: Text(userPhone.isNotEmpty ? userPhone : l10n.notUpdated, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: GestureDetector(
                    onTap: () => context.push('/profile/edit'),
                    child: Text(l10n.edit, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
                GlassListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(l10n.joinedDate),
                  subtitle: Text(joinedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 3: GIAO DIỆN & CÀI ĐẶT
            GlassGroupedSection(
              header: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(l10n.appearanceSettings, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final currentMode = ref.watch(themeProvider);
                    String modeLabel = l10n.systemMode;
                    if (currentMode == ThemeMode.light) {
                      modeLabel = l10n.lightMode;
                    } else if (currentMode == ThemeMode.dark) {
                      modeLabel = l10n.darkModeTheme;
                    }

                    return GlassListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(l10n.themeSheetTitle),
                      subtitle: Text(modeLabel),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showThemeSelectionSheet(context, ref),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GlassButton.custom(
                    width: double.infinity,
                    onTap: () => context.push('/profile/edit'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassButton.custom(
                    width: double.infinity,
                    onTap: () => _confirmSignOut(context, ref),
                    settings: LiquidGlassSettings(glassColor: AppColors.error.withValues(alpha: 0.2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
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
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentTheme = ref.read(themeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GlassCard(
          shape: const LiquidRoundedRectangle(
            borderRadius: 24,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.themeSheetTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildThemeOptionTile(
                ctx,
                ref,
                title: l10n.themeLightTitle,
                subtitle: l10n.themeLightSubtitle,
                icon: Icons.wb_sunny_outlined,
                mode: ThemeMode.light,
                isSelected: currentTheme == ThemeMode.light,
              ),
              _buildThemeOptionTile(
                ctx,
                ref,
                title: l10n.themeDarkTitle,
                subtitle: l10n.themeDarkSubtitle,
                icon: Icons.nightlight_round,
                mode: ThemeMode.dark,
                isSelected: currentTheme == ThemeMode.dark,
              ),
              _buildThemeOptionTile(
                ctx,
                ref,
                title: l10n.themeSystemTitle,
                subtitle: l10n.themeSystemSubtitle,
                icon: Icons.settings_brightness_outlined,
                mode: ThemeMode.system,
                isSelected: currentTheme == ThemeMode.system,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return GlassListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
