import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableGpsLocation = true;
  bool _enableDarkMode = false;
  String _selectedLanguage = 'vi';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt ứng dụng',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER ACCOUNT HEADER CARD
            if (user != null) ...[
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFFF4EB),
                      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person_rounded, color: Color(0xFFFF7A00))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isNotEmpty ? user.name : 'Người dùng CodoKy',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/profile/edit'),
                      child: const Text('Sửa', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // SECTION 1: Cấu hình ứng dụng
            const Text(
              'CẤU HÌNH ỨNG DỤNG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
                  // Ngôn ngữ
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.language_rounded, color: Color(0xFF0284C7), size: 18),
                    ),
                    title: const Text('Ngôn ngữ hiển thị', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt 🇻🇳', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'en', child: Text('English 🇬🇧', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),

                  // Thông báo
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFF4EB), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFF7A00), size: 18),
                    ),
                    title: const Text('Thông báo nhắc nhở', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    subtitle: const Text('Nhận gợi ý địa điểm & nhắc lịch trình', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    activeThumbColor: const Color(0xFFFF7A00),
                    value: _enableNotifications,
                    onChanged: (val) => setState(() => _enableNotifications = val),
                  ),
                  const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),

                  // Định vị GPS
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFE6F9F3), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.my_location_rounded, color: Color(0xFF00B87C), size: 18),
                    ),
                    title: const Text('Quyền truy cập GPS', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    subtitle: const Text('Tự động xác định vị trí trên bản đồ Huế', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    activeThumbColor: const Color(0xFF00B87C),
                    value: _enableGpsLocation,
                    onChanged: (val) => setState(() => _enableGpsLocation = val),
                  ),
                  const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),

                  // Giao diện Dark Mode
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF9333EA), size: 18),
                    ),
                    title: const Text('Chế độ Tối (Dark Mode)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    activeThumbColor: const Color(0xFF9333EA),
                    value: _enableDarkMode,
                    onChanged: (val) => setState(() => _enableDarkMode = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // SECTION 2: Thông tin & Trợ giúp
            const Text(
              'THÔNG TIN & TRỢ GIÚP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF475569), size: 18),
                    ),
                    title: const Text('Chính sách bảo mật', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ứng dụng CodoKy tuân thủ chính sách bảo mật thông tin người dùng.')),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),

                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 18),
                    ),
                    title: const Text('Phiên bản ứng dụng', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    trailing: const Text('v1.0.0 (2026)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
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
