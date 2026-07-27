import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _recentSearches = const [
    'Bún bò Huế Mụ Rớt',
    'Đại Nội Huế',
    'Cafe muối Cố đô',
    'Chùa Thiên Mụ',
    'Lăng Khải Định',
  ];

  final List<Map<String, String>> _popularTags = const [
    {'label': '🏰 Đại Nội & Lăng tẩm', 'query': 'lăng'},
    {'label': '🍜 Cơm hến & Bún bò', 'query': 'bún'},
    {'label': '☕ Cafe muối Huế', 'query': 'cafe'},
    {'label': '⛩️ Chùa cổ Huế', 'query': 'chùa'},
    {'label': '🛍️ Chợ Đông Ba', 'query': 'chợ'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final allPlaces = mapState.allPlaces;

    final query = _searchController.text.trim().toLowerCase();

    final searchResults = query.isEmpty
        ? <Map<String, dynamic>>[]
        : allPlaces.whereType<Map<String, dynamic>>().where((p) {
            final name = p['name']?.toString().toLowerCase() ?? '';
            final address = p['address']?.toString().toLowerCase() ?? '';
            final cat = p['category']?.toString().toLowerCase() ?? '';
            return name.contains(query) || address.contains(query) || cat.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/map');
            }
          },
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm địa điểm, quán ăn, di tích Huế...',
            hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: Color(0xFF94A3B8), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
      body: query.isNotEmpty
          ? (searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(
                        'Không tìm thấy địa điểm nào khớp với "$query"',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final id = item['id']?.toString() ?? '$index';
                    final name = item['name']?.toString() ?? 'Địa điểm Huế';
                    final address = item['address']?.toString() ?? 'Thừa Thiên Huế';
                    final rating = double.tryParse(item['rating']?.toString() ?? '4.8') ?? 4.8;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.place_rounded, color: Color(0xFFFF7A00), size: 20),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
                          ),
                          subtitle: Text(
                            address,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                              const SizedBox(width: 2),
                              Text(
                                '$rating',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              ),
                            ],
                          ),
                          onTap: () => context.push('/place/$id'),
                        ),
                      ),
                    );
                  },
                ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lịch sử tìm kiếm gần đây
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TÌM KIẾM GẦN ĐÂY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa lịch sử tìm kiếm.')),
                          );
                        },
                        child: const Text(
                          'Xóa tất cả',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: _recentSearches.map((item) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history_rounded, size: 18, color: Color(0xFF94A3B8)),
                        title: Text(item, style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155))),
                        trailing: const Icon(Icons.north_west_rounded, size: 14, color: Color(0xFFCBD5E1)),
                        onTap: () {
                          _searchController.text = item;
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Từ khóa Hot được tìm nhiều
                  const Text(
                    'TỪ KHÓA ĐƯỢC TÌM NHIỀU 🔥',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularTags.map((tag) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = tag['query']!;
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            tag['label']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
