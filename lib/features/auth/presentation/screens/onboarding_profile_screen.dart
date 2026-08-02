import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  final List<String> _selectedPreferences = [];

  final List<Map<String, String>> _categories = const [
    {'id': 'food', 'label': 'Ẩm thực Huế', 'icon': '🍜', 'desc': 'Cơm hến, Bún bò, Bánh lọc, Trà cung đình'},
    {'id': 'history', 'label': 'Lịch sử & Di sản', 'icon': '🏰', 'desc': 'Đại Nội, Lăng tẩm các vua Nguyễn'},
    {'id': 'temple', 'label': 'Tâm linh & Chùa', 'icon': '⛩️', 'desc': 'Chùa Thiên Mụ, Chùa Từ Đàm, Thiền viện'},
    {'id': 'nature', 'label': 'Thiên nhiên & Cảnh quan', 'icon': '🌿', 'desc': 'Sông Hương, Núi Ngự Bình, Đồi Vọng Cảnh'},
    {'id': 'cafe', 'label': 'Đời sống & Cafe', 'icon': '☕', 'desc': 'Quán cafe góc phố, Trà chiều Huế'},
    {'id': 'shopping', 'label': 'Mua sắm & Phố đêm', 'icon': '🛍️', 'desc': 'Chợ Đông Ba, Phố đi bộ Nguyễn Đình Chiểu'},
    {'id': 'culture', 'label': 'Nghệ thuật & Nhã nhạc', 'icon': '🎶', 'desc': 'Ca Huế trên sông Hương, Làng nghề truyền thống'},
  ];

  void _togglePreference(String id) {
    setState(() {
      if (_selectedPreferences.contains(id)) {
        _selectedPreferences.remove(id);
      } else {
        _selectedPreferences.add(id);
      }
    });
  }

  Future<void> _handleSave() async {
    if (_selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 sở thích để AI gợi ý lịch trình tốt nhất cho bạn!'),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).savePreferences(_selectedPreferences);
    if (!mounted) return;

    if (success) {
      context.go('/map');
    } else {
      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'Không thể lưu sở thích.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sở thích du lịch'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/map'),
            child: const Text('Bỏ qua'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn yêu thích trải nghiệm nào ở Huế?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chọn các chủ đề bạn quan tâm để CodoKy AI cá nhân hóa lịch trình cho riêng bạn.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedPreferences.contains(cat['id']);

                        return InkWell(
                          onTap: () => _togglePreference(cat['id']!),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer.withValues(alpha: 0.50)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  cat['icon']!,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat['label']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cat['desc']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) => _togglePreference(cat['id']!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: 'Lưu & Khám phá ngay (${_selectedPreferences.length})',
                isLoading: authState.isLoading,
                onPressed: _handleSave,
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
