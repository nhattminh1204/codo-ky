import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/widgets/animations/staggered_item.dart';
import 'package:codoky/features/map/presentation/screens/place_detail_screen.dart';


class ExploreHomeScreen extends ConsumerStatefulWidget {
  const ExploreHomeScreen({super.key});

  @override
  ConsumerState<ExploreHomeScreen> createState() => _ExploreHomeScreenState();
}

class _ExploreHomeScreenState extends ConsumerState<ExploreHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _categories(AppLocalizations l10n) => [
        {
          'id': 'attraction',
          'title': l10n.categoryHeritageTitle,
          'subtitle': l10n.categoryHeritageSubtitle,
          'icon': Icons.account_balance_rounded,
          'emoji': '🏰',
          'count': l10n.placeCount(48),
          'colors': [Color(0xFFFF5E62), Color(0xFFFF9966)],
        },
        {
          'id': 'food',
          'title': l10n.categoryFoodTitle,
          'subtitle': l10n.categoryFoodSubtitle,
          'icon': Icons.restaurant_rounded,
          'emoji': '🍜',
          'count': l10n.placeCount(120),
          'colors': [Color(0xFFFF7A00), Color(0xFFFFB800)],
        },
        {
          'id': 'temple',
          'title': l10n.categorySpiritualTitle,
          'subtitle': l10n.categorySpiritualSubtitle,
          'icon': Icons.church_rounded,
          'emoji': '⛩️',
          'count': l10n.placeCount(35),
          'colors': [Color(0xFF9333EA), Color(0xFFC084FC)],
        },
        {
          'id': 'cafe',
          'title': l10n.categoryCafeTitle,
          'subtitle': l10n.categoryCafeSubtitle,
          'icon': Icons.coffee_rounded,
          'emoji': '☕',
          'count': l10n.placeCount(85),
          'colors': [Color(0xFF0284C7), Color(0xFF38BDF8)],
        },
        {
          'id': 'shopping',
          'title': l10n.categoryShoppingTitle,
          'subtitle': l10n.categoryShoppingSubtitle,
          'icon': Icons.shopping_bag_rounded,
          'emoji': '🛍️',
          'count': l10n.placeCount(26),
          'colors': [Color(0xFF16A34A), Color(0xFF4ADE80)],
        },
        {
          'id': 'culture',
          'title': l10n.categoryCultureTitle,
          'subtitle': l10n.categoryCultureSubtitle,
          'icon': Icons.music_note_rounded,
          'emoji': '🎶',
          'count': l10n.placeCount(19),
          'colors': [Color(0xFFE11D48), Color(0xFFFB7185)],
        },
      ];

  final List<Map<String, dynamic>> _featuredPlaces = const [
    {
      'id': '1',
      'name': 'Đại Nội Huế (Hoàng Thành)',
      'category': 'Di sản Lịch sử',
      'rating': 4.9,
      'review_count': 342,
      'address': 'Thuận Thành, TP. Huế',
      'image_url': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80',
      'tag': '🏰 Di sản UNESCO',
    },
    {
      'id': '2',
      'name': 'Chùa Thiên Mụ',
      'category': 'Tâm linh & Chùa',
      'rating': 4.8,
      'review_count': 210,
      'address': 'Hương Long, TP. Huế',
      'image_url': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&auto=format&fit=crop&q=80',
      'tag': '⛩️ Danh thắng tâm linh',
    },
    {
      'id': '3',
      'name': 'Quán Cơm Hến Hoa Đông',
      'category': 'Ẩm thực Cố đô',
      'rating': 4.7,
      'review_count': 185,
      'address': 'Vĩ Dạ, TP. Huế',
      'image_url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      'tag': '🍜 Món ngon Huế',
    },
    {
      'id': '4',
      'name': 'Cafe Muối Gốc Cố Đô',
      'category': 'Đời sống & Cafe',
      'rating': 4.8,
      'review_count': 156,
      'address': '10 Nguyễn Lương Bằng, Huế',
      'image_url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
      'tag': '☕ Đặc sản Cafe Huế',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = _categories(l10n);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO TOP BANNER WITH SEARCH
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.exploreHeroTitle,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 2)),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  l10n.exploreHeroSubtitle,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search Bar Card (Solid Clean Bar, Black Icon & Text)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onSubmitted: (query) {
                              if (query.trim().isNotEmpty) {
                                context.push('/search');
                              }
                            },
                            decoration: InputDecoration(
                              hintText: l10n.exploreSearchHint,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: 20,
                                ),
                                onPressed: () => context.push('/search'),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. CHỦ ĐỀ KHÁM PHÁ (CATEGORIES GRID)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.featuredCategories,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    l10n.themesCount(categories.length),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.45,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final List<Color> colors = cat['colors'];

                  return StaggeredItem(
                    index: index,
                    child: GestureDetector(
                      onTap: () => context.push('/explore/category/${cat['id']}'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colors.first.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat['emoji'] as String, style: const TextStyle(fontSize: 24)),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cat['count'] as String,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. ĐỊA ĐIỂM NỔI BẬT NHẤT (FEATURED HORIZONTAL SCROLL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hotPlaces,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/explore/category/attraction'),
                    child: Text(
                      l10n.seeAll,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _featuredPlaces.length,
                itemBuilder: (context, index) {
                  final item = _featuredPlaces[index];
                  final placeId = item['id'] as String;

                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: OpenContainer(
                      transitionDuration: AppMotion.emphasized,
                      transitionType: ContainerTransitionType.fade,
                      closedElevation: 0,
                      openElevation: 0,
                      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      closedColor: Colors.transparent,
                      openColor: const Color(0xFFF8FAFC),
                      openBuilder: (context, _) => PlaceDetailScreen(id: placeId),
                      closedBuilder: (context, openContainer) {
                        return GestureDetector(
                          onTap: openContainer,
                          child: Container(
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        item['image_url'] as String,
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB800)),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${item['rating']}',
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Info Body
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item['address'] as String,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF4EB),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['tag'] as String,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 4. BỘ SỰC TẬP TRẢI NGHIỆM ĐẶC SẮC (EXPERIENCE CARDS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.experiences,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Experience Card 1
                  _buildExperienceCard(
                    context,
                    title: l10n.experienceTeaTitle,
                    subtitle: l10n.experienceTeaSubtitle,
                    emoji: '🍵',
                    bgGradient: const [Color(0xFFFFF8E7), Color(0xFFFFF1C2)],
                    borderColor: const Color(0xFFFDE68A),
                    tagColor: const Color(0xFFD97706),
                    tag: l10n.experienceChill,
                    onTap: () => context.push('/explore/category/culture'),
                  ),
                  const SizedBox(height: 10),

                  // Experience Card 2
                  _buildExperienceCard(
                    context,
                    title: l10n.experienceHatTitle,
                    subtitle: l10n.experienceHatSubtitle,
                    emoji: '👒',
                    bgGradient: const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                    borderColor: const Color(0xFFDDD6FE),
                    tagColor: const Color(0xFF9333EA),
                    tag: l10n.checkinHot,
                    onTap: () => context.push('/explore/category/culture'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
    required List<Color> bgGradient,
    required Color borderColor,
    required Color tagColor,
    required String tag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: tagColor),
          ],
        ),
      ),
    );
  }
}
