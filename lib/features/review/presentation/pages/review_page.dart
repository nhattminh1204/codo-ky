import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';
import 'package:codoky/features/review/presentation/widgets/review_card.dart';
import 'package:codoky/features/review/presentation/widgets/write_review_bottom_sheet.dart';
import 'package:codoky/shared/widgets/empty_state_widget.dart';

class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadReviews();
      ref.read(reviewProvider.notifier).loadMyReviews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            const Icon(Icons.rate_review, color: Color(0xFF9B1B30)),
            const SizedBox(width: 8),
            Text(
              'Đánh giá địa điểm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9B1B30),
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showWriteReviewSheet(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Viết đánh giá'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9B1B30),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9B1B30),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF9B1B30),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tất cả đánh giá'),
            Tab(text: 'Của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllReviewsTab(
            reviews: state.allReviews,
            isLoading: state.isLoadingAll,
            onLoadMore: () => ref.read(reviewProvider.notifier).loadMoreReviews(),
            hasMore: state.hasMoreAll,
          ),
          _MyReviewsTab(
            reviews: state.myReviews,
            isLoading: state.isLoadingMine,
            onLoadMore: () => ref.read(reviewProvider.notifier).loadMoreMyReviews(),
            hasMore: state.hasMoreMine,
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WriteReviewBottomSheet(),
    );
  }
}

class _AllReviewsTab extends StatelessWidget {
  final List<dynamic> reviews;
  final bool isLoading;
  final VoidCallback onLoadMore;
  final bool hasMore;

  const _AllReviewsTab({
    required this.reviews,
    required this.isLoading,
    required this.onLoadMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B1B30)));
    }

    if (reviews.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.rate_review_outlined,
        title: 'Chưa có đánh giá nào',
        message: 'Hãy là người đầu tiên chia sẻ trải nghiệm của bạn tại Huế!',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF9B1B30),
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == reviews.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: OutlinedButton(
                  onPressed: onLoadMore,
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF9B1B30)),
                  child: const Text('Tải thêm đánh giá'),
                ),
              ),
            );
          }
          return ReviewCard(
            review: reviews[index],
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _MyReviewsTab extends StatelessWidget {
  final List<dynamic> reviews;
  final bool isLoading;
  final VoidCallback onLoadMore;
  final bool hasMore;

  const _MyReviewsTab({
    required this.reviews,
    required this.isLoading,
    required this.onLoadMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B1B30)));
    }

    if (reviews.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.edit_note_rounded,
        title: 'Bạn chưa có đánh giá nào',
        message: 'Hãy viết đánh giá để chia sẻ trải nghiệm du lịch Huế của bạn!',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF9B1B30),
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == reviews.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: OutlinedButton(
                  onPressed: onLoadMore,
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF9B1B30)),
                  child: const Text('Tải thêm'),
                ),
              ),
            );
          }
          return ReviewCard(
            review: reviews[index],
            isMyReview: true,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }
}