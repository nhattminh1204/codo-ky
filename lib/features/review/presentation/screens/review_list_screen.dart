import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/core/widgets/animations/staggered_item.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';
import 'package:codoky/features/review/presentation/widgets/review_card.dart';
import 'package:codoky/features/review/presentation/widgets/write_review_bottom_sheet.dart';

class ReviewListScreen extends ConsumerStatefulWidget {
  final String? placeId;

  const ReviewListScreen({
    super.key,
    this.placeId,
  });

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewProvider.notifier).loadAllReviews(placeId: widget.placeId, refresh: true);
    });
  }

  void _openWriteReviewSheet() {
    showAppBottomSheet(
      context: context,
      vsync: this,
      builder: (context) => WriteReviewBottomSheet(
        initialPlaceId: widget.placeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đánh giá từ du khách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWriteReviewSheet,
        backgroundColor: const Color(0xFFFF7A00),
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text('Viết đánh giá', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reviewProvider.notifier).loadAllReviews(placeId: widget.placeId, refresh: true),
        color: const Color(0xFFFF7A00),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // 1. RATING SUMMARY OVERVIEW CARD
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
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
                  child: Row(
                    children: [
                      Column(
                        children: [
                          const Text(
                            '4.9',
                            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E)),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reviewState.allReviews.length} đánh giá',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(width: 1, height: 60, color: const Color(0xFFE2E8F0)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar('5 ⭐', 0.85),
                            _buildRatingBar('4 ⭐', 0.10),
                            _buildRatingBar('3 ⭐', 0.03),
                            _buildRatingBar('2 ⭐', 0.01),
                            _buildRatingBar('1 ⭐', 0.01),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. REVIEWS LIST VIEW
              if (reviewState.isLoadingAll && reviewState.allReviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF7A00))),
                )
              else if (reviewState.allReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 56, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có đánh giá nào cho địa điểm này.',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hãy là người đầu tiên chia sẻ cảm nhận của bạn!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _openWriteReviewSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Viết Đánh Giá Ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviewState.allReviews.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviewState.allReviews[index];
                      return StaggeredItem(
                        index: index,
                        child: ReviewCard(
                          review: review,
                          onDelete: () => ref.read(reviewProvider.notifier).deleteReview(review.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF7A00)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
