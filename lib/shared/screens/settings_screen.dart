import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/localization/locale_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final selectedLanguage = currentLocale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
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
                            user.name.isNotEmpty ? user.name : l10n.defaultUserName,
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
                      child: Text(l10n.edit, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // SECTION 1: Cấu hình ứng dụng
            Text(
              l10n.appConfigSection,
              style: const TextStyle(
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
                    title: Text(l10n.displayLanguage, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'vi', child: Text('${l10n.vietnamese} 🇻🇳', style: const TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'en', child: Text('${l10n.english} 🇬🇧', style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(localeProvider.notifier).setLocale(Locale(val));
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
                    title: Text(l10n.notificationsTitle, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    subtitle: Text(l10n.notificationsSubtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
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
                    title: Text(l10n.gpsAccess, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    subtitle: Text(l10n.gpsSubtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
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
                    title: Text(l10n.darkModeToggle, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    activeThumbColor: const Color(0xFF9333EA),
                    value: _enableDarkMode,
                    onChanged: (val) => setState(() => _enableDarkMode = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // SECTION 2: Thông tin & Trợ giúp
            Text(
              l10n.infoHelpSection,
              style: const TextStyle(
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
                    title: Text(l10n.privacyPolicy, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.privacyPolicyMessage)),
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
                    title: Text(l10n.appVersion, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
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
