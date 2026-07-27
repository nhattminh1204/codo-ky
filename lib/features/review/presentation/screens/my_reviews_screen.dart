import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';
import 'package:codoky/features/review/presentation/widgets/review_card.dart';

class MyReviewsScreen extends ConsumerStatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  ConsumerState<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends ConsumerState<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewProvider.notifier).loadMyReviews(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final myReviews = reviewState.myReviews;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đánh giá của tôi',
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
              context.go('/profile');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reviewProvider.notifier).loadMyReviews(refresh: true),
        color: const Color(0xFFFF7A00),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // 1. STATS SUMMARY CARD
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5E62).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('${myReviews.length}', 'Đánh giá đã viết'),
                      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                      _buildStatItem(
                        '${myReviews.fold<int>(0, (sum, r) => sum + r.likeCount)}',
                        'Lượt thích nhận được',
                      ),
                    ],
                  ),
                ),
              ),

              // 2. MY REVIEWS LIST VIEW
              if (reviewState.isLoadingMine && myReviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF7A00))),
                )
              else if (myReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 56, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Bạn chưa đóng góp đánh giá nào.',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hãy chia sẻ trải nghiệm về địa điểm Huế bạn đã ghé thăm!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        textAlign: TextAlign.center,
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
                    itemCount: myReviews.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = myReviews[index];
                      return ReviewCard(
                        review: review,
                        isMyReview: true,
                        onDelete: () => ref.read(reviewProvider.notifier).deleteReview(review.id),
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

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}
