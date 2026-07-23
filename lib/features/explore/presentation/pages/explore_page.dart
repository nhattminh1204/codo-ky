import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/explore/presentation/providers/explore_provider.dart';
import 'package:codoky/features/explore/presentation/widgets/place_list_item.dart';
import 'package:codoky/shared/widgets/custom_search_bar.dart';
import 'package:codoky/shared/widgets/empty_state_widget.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadPlaces();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final categories = ['all', 'restaurant', 'attraction', 'temple', 'tomb'];
    final selectedId = categories[_tabController.index];
    ref.read(exploreProvider.notifier).selectCategory(selectedId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);
    final places = state.places;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            const Icon(Icons.explore, color: Color(0xFF9B1B30)),
            const SizedBox(width: 8),
            Text(
              'Khám phá Huế',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9B1B30),
                  ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF9B1B30),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF9B1B30),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Quán ăn'),
            Tab(text: 'Địa điểm'),
            Tab(text: 'Chùa chiền'),
            Tab(text: 'Lăng tẩm'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(exploreProvider.notifier).refresh();
        },
        color: const Color(0xFF9B1B30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Tìm kiếm địa điểm, lăng tẩm, món ngon ở Huế...',
                onChanged: (query) {
                  ref.read(exploreProvider.notifier).searchPlaces(query);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Tìm thấy ${places.length} địa điểm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF9B1B30)),
                    )
                  : places.isEmpty
                      ? EmptyStateWidget(
                          title: 'Không tìm thấy địa điểm',
                          message: 'Thử tìm kiếm với từ khóa khác hoặc chuyển sang danh mục khác.',
                          actionLabel: 'Tải lại danh sách',
                          onAction: () {
                            _searchController.clear();
                            ref.read(exploreProvider.notifier).searchPlaces('');
                            ref.read(exploreProvider.notifier).refresh();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            return PlaceListItem(
                              place: places[index],
                              onTap: () {
                                _showPlaceDetailBottomSheet(context, places[index]);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceDetailBottomSheet(BuildContext context, dynamic place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final name = place['name'] as String? ?? '';
        final address = place['address'] as String? ?? 'Thừa Thiên Huế';

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B1B30),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Đóng'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Open Map Navigation
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Xem trên bản đồ'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9B1B30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}