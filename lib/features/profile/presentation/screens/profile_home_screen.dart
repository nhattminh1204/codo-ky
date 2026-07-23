import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa đăng nhập',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Đăng nhập để xem thông tin hồ sơ & lưu lịch trình cá nhân.'),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Đăng nhập ngay',
                    width: 200,
                    backgroundColor: const Color(0xFF9B1B30),
                    onPressed: () => context.push('/login'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Avatar & Name Card
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFF9B1B30),
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Info Tiles Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: Color(0xFF9B1B30)),
                          title: const Text('Số điện thoại'),
                          subtitle: Text(user.phone.isNotEmpty ? user.phone : 'Chưa cập nhật'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF9B1B30)),
                          title: const Text('Ngày tham gia'),
                          subtitle: Text(
                            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.favorite_outline, color: Color(0xFF9B1B30)),
                          title: const Text('Sở thích cá nhân'),
                          subtitle: Text(
                            user.preferences.isNotEmpty
                                ? user.preferences.join(', ')
                                : 'Chưa chọn sở thích',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit Profile Button
                  PrimaryButton(
                    text: 'Chỉnh sửa hồ sơ',
                    icon: Icons.edit_outlined,
                    isOutlined: true,
                    foregroundColor: const Color(0xFF9B1B30),
                    backgroundColor: const Color(0xFF9B1B30),
                    onPressed: () => context.push('/profile/edit'),
                  ),
                  const SizedBox(height: 12),

                  // Logout Button
                  PrimaryButton(
                    text: 'Đăng xuất',
                    icon: Icons.logout,
                    backgroundColor: Colors.red.shade700,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
