import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/cards/app_card.dart';
import 'package:codoky/core/widgets/chips/app_chip.dart';
import 'package:codoky/core/widgets/headers/section_header.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarController;
  late List<String> _selectedPreferences;

  final List<Map<String, String>> _categories = const [
    {'id': 'food', 'label': 'Ẩm thực Huế', 'icon': '🍜'},
    {'id': 'history', 'label': 'Lịch sử & Di sản', 'icon': '🏰'},
    {'id': 'temple', 'label': 'Tâm linh & Chùa', 'icon': '⛩️'},
    {'id': 'nature', 'label': 'Thiên nhiên & Cảnh quan', 'icon': '🌿'},
    {'id': 'cafe', 'label': 'Đời sống & Cafe', 'icon': '☕'},
    {'id': 'shopping', 'label': 'Mua sắm & Phố đêm', 'icon': '🛍️'},
    {'id': 'culture', 'label': 'Nghệ thuật & Nhã nhạc', 'icon': '🎶'},
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _avatarController = TextEditingController(text: user?.avatarUrl ?? '');
    _selectedPreferences = user?.preferences.where((p) => p.isNotEmpty).toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

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
    if (!_formKey.currentState!.validate()) return;

    final avatarText = _avatarController.text.trim();
    final profileSuccess = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarUrl: avatarText.isNotEmpty ? avatarText : null,
        );

    final prefSuccess = await ref.read(authProvider.notifier).savePreferences(_selectedPreferences);

    if (!mounted) return;

    if (profileSuccess && prefSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin hồ sơ và sở thích thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'Cập nhật hồ sơ thất bại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Avatar Preview
                Center(
                  child: Hero(
                    tag: 'user-avatar-ring',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5E62).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _avatarController.text.trim().isNotEmpty
                              ? NetworkImage(_avatarController.text.trim())
                              : (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null),
                          child: (_avatarController.text.trim().isEmpty && (user?.avatarUrl == null || user!.avatarUrl!.isEmpty))
                              ? const Icon(Icons.person_rounded, size: 40, color: Color(0xFFFF5E62))
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Thông tin cá nhân Card
                AppCard(
                  child: Column(
                    children: [
                      const SectionHeader(
                        title: 'Thông tin cá nhân',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextInput(
                        controller: _nameController,
                        label: 'Họ và tên',
                        hint: 'Nhập họ và tên mới',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => Validators.required(v, fieldName: 'Họ và tên'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextInput(
                        controller: _phoneController,
                        label: 'Số điện thoại',
                        hint: 'Nhập số điện thoại mới',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: Validators.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextInput(
                        controller: _avatarController,
                        label: 'Đường dẫn ảnh đại diện (Avatar URL)',
                        hint: 'https://example.com/avatar.jpg',
                        keyboardType: TextInputType.url,
                        prefixIcon: const Icon(Icons.image_outlined),
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sở thích du lịch Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Sở thích du lịch cá nhân',
                        subtitle: 'Chọn các chủ đề để AI gợi ý lịch trình chính xác:',
                        icon: Icons.favorite_outline,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final id = cat['id']!;
                          final isSelected = _selectedPreferences.contains(id);
                          return AppChip(
                            label: '${cat['icon']} ${cat['label']}',
                            isSelected: isSelected,
                            onTap: () => _togglePreference(id),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  text: 'Lưu thay đổi',
                  useGradient: true,
                  isLoading: authState.isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
