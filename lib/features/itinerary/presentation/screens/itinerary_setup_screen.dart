import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';

class ItinerarySetupScreen extends ConsumerStatefulWidget {
  const ItinerarySetupScreen({super.key});

  @override
  ConsumerState<ItinerarySetupScreen> createState() => _ItinerarySetupScreenState();
}

class _ItinerarySetupScreenState extends ConsumerState<ItinerarySetupScreen> {
  String _selectedDuration = '3d2n';
  String _selectedCompanion = 'couple';
  String _selectedBudget = 'standard';
  final List<String> _selectedStyles = ['heritage', 'food', 'photo'];
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _durations = const [
    {'id': '1d', 'label': '1 Ngày (Nhanh)'},
    {'id': '2d1n', 'label': '2 Ngày 1 Đêm'},
    {'id': '3d2n', 'label': '3 Ngày 2 Đêm (Khuyên dùng)'},
    {'id': '4d3n', 'label': '4 Ngày 3 Đêm (Trọn vẹn)'},
  ];

  final List<Map<String, dynamic>> _companions = const [
    {'id': 'solo', 'label': 'Một mình 🎒'},
    {'id': 'couple', 'label': 'Cặp đôi 👩‍❤️‍👨'},
    {'id': 'family', 'label': 'Gia đình 👨‍👩‍👧‍👦'},
    {'id': 'friends', 'label': 'Nhóm bạn 🚗'},
  ];

  final List<Map<String, dynamic>> _styles = const [
    {'id': 'heritage', 'label': '🏰 Di sản & Lịch sử'},
    {'id': 'food', 'label': '🍜 Ẩm thực Cố đô'},
    {'id': 'chill', 'label': '☕ Chill & Cafe muối'},
    {'id': 'temple', 'label': '⛩️ Tâm linh & Chùa cổ'},
    {'id': 'photo', 'label': '📸 Check-in sống ảo'},
    {'id': 'nature', 'label': '🌿 Sông Hương & Thiên nhiên'},
  ];

  final List<Map<String, dynamic>> _budgets = const [
    {'id': 'saver', 'label': 'Tiết kiệm 💡', 'desc': '~ 300k - 500k/ngày'},
    {'id': 'standard', 'label': 'Tiêu chuẩn ⭐', 'desc': '~ 600k - 1tr/ngày'},
    {'id': 'luxury', 'label': 'Thoải mái VIP 💎', 'desc': '> 1.2tr/ngày'},
  ];

  void _toggleStyle(String id) {
    setState(() {
      if (_selectedStyles.contains(id)) {
        if (_selectedStyles.length > 1) _selectedStyles.remove(id);
      } else {
        _selectedStyles.add(id);
      }
    });
  }

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);

    int days = 3;
    if (_selectedDuration == '1d') days = 1;
    if (_selectedDuration == '2d1n') days = 2;
    if (_selectedDuration == '3d2n') days = 3;
    if (_selectedDuration == '4d3n') days = 4;

    double budgetPerDay = 800000;
    if (_selectedBudget == 'saver') budgetPerDay = 400000;
    if (_selectedBudget == 'standard') budgetPerDay = 800000;
    if (_selectedBudget == 'luxury') budgetPerDay = 1500000;
    final totalBudget = budgetPerDay * days;

    try {
      await ref.read(itineraryProvider.notifier).generateAISuggestion(
            durationDays: days,
            budget: totalBudget,
            interests: _selectedStyles,
            companion: _selectedCompanion,
          );

      if (!mounted) return;
      setState(() => _isGenerating = false);
      
      final currentQuota = ref.read(aiRemoteServiceProvider).currentQuota;
      if (currentQuota >= 900) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Cảnh báo: Lượt tạo AI của hệ thống sắp hết ($currentQuota/1000)'),
            backgroundColor: const Color(0xFFF59E0B),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
      context.push('/itinerary/result');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Thiết lập lịch trình AI',
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // 1. HERO PROMPT BANNER
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CodoKy AI Travel Planner',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chỉ mất 5 giây để AI thiết kế chuyến đi Huế hoàn hảo dựa trên thời gian, ngân sách và sở thích riêng của bạn.',
                    style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                  ),
                ],
              ),
            ),

            // 2. CONFIG OPTIONS FORM
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option 1: Thời lượng
                  const Text(
                    '1. BẠN SẼ NGHỈ DƯỠNG Ở HUẾ BAO LÂU?',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = d['id']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF7A00) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            d['label']!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Option 2: Đi cùng ai
                  const Text(
                    '2. BẠN CHUYẾN ĐI NÀY CÙNG AI?',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _companions.map((c) {
                      final isSelected = _selectedCompanion == c['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCompanion = c['id']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFEAD8) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            c['label']!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Option 3: Phong cách du lịch
                  const Text(
                    '3. PHONG CÁCH DU LỊCH YÊU THÍCH (CHỌN NHIỀU)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _styles.map((s) {
                      final isSelected = _selectedStyles.contains(s['id']);
                      return GestureDetector(
                        onTap: () => _toggleStyle(s['id']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFF4EB) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            s['label']!,
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

                  // Option 4: Ngân sách
                  const Text(
                    '4. DỰ TRÙ NGÂN SÁCH CHI TIÊU',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _budgets.map((b) {
                      final isSelected = _selectedBudget == b['id'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedBudget = b['id']!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFF4EB) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFF1F5F9),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b['label']!,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      ),
                                      Text(
                                        b['desc']!,
                                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 54,
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
                        onTap: _isGenerating ? null : _handleGenerate,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _isGenerating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    ),
                                    SizedBox(width: 10),
                                    Text('AI đang lập lịch trình...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tạo Lịch Trình Tự Động AI',
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
