import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _selectedAspects = [];
  bool _isSubmitting = false;

  final List<String> _aspectOptions = const [
    '🏰 Cảnh quan đẹp',
    '🍜 Món ăn ngon',
    '💰 Giá hợp lý',
    '🤝 Phục vụ chu đáo',
    '📸 Góc chụp check-in',
    '🌿 Yên tĩnh thư thái',
  ];

  final List<String> _ratingLabels = const [
    '',
    'Rất thất vọng 😡',
    'Chưa hài lòng 🙁',
    'Bình thường 😐',
    'Hài lòng 😊',
    'Rất tuyệt vời! 😍',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleAspect(String aspect) {
    setState(() {
      if (_selectedAspects.contains(aspect)) {
        _selectedAspects.remove(aspect);
      } else {
        _selectedAspects.add(aspect);
      }
    });
  }

  Future<void> _handleSubmit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng viết vài dòng chia sẻ nhận xét của bạn.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cảm ơn bạn! Đánh giá đã gửi thành công (+20 điểm thưởng VIP).'),
        backgroundColor: AppColors.success,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Viết đánh giá địa điểm',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PLACE SUMMARY PREVIEW CARD
            Container(
              padding: const EdgeInsets.all(14),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=200&auto=format&fit=crop&q=80',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đại Nội Huế (Hoàng Thành)',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Thuận Thành, Thành phố Huế',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. INTERACTIVE 5-STAR RATING BAR
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
                children: [
                  const Text(
                    'ĐÁNH GIÁ MỨC ĐỘ HÀI LÒNG',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),

                  // 5 Glowing Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          starVal <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: starVal <= _rating ? const Color(0xFFFFB800) : const Color(0xFFCBD5E1),
                        ),
                        onPressed: () => setState(() => _rating = starVal),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    _ratingLabels[_rating],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. ASPECT TAG CHIPS
            const Text(
              'TIÊU CHÍ NỔI BẬT KHUYÊN THÍCH',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _aspectOptions.map((asp) {
                final isSelected = _selectedAspects.contains(asp);
                return GestureDetector(
                  onTap: () => _toggleAspect(asp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFEAD8) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      asp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 4. COMMENT INPUT FIELD
            const Text(
              'NỘI DUNG NHẬN XÉT CHI TIẾT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ nhận xét thực tế về trải nghiệm, không gian, vị trí hoặc lưu ý khi ghé thăm...',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // SUBMIT BUTTON
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
                  onTap: _isSubmitting ? null : _handleSubmit,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Gửi đánh giá (+20 điểm)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
