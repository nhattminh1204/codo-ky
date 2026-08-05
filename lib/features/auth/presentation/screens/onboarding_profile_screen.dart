import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  final List<String> _selectedPreferences = [];

  List<Map<String, String>> _categories(AppLocalizations l10n) => [
        {'id': 'food', 'label': l10n.onboardingCatFoodLabel, 'icon': '🍜', 'desc': l10n.onboardingCatFoodDesc},
        {'id': 'history', 'label': l10n.onboardingCatHistoryLabel, 'icon': '🏰', 'desc': l10n.onboardingCatHistoryDesc},
        {'id': 'temple', 'label': l10n.onboardingCatSpiritualLabel, 'icon': '⛩️', 'desc': l10n.onboardingCatSpiritualDesc},
        {'id': 'nature', 'label': l10n.onboardingCatNatureLabel, 'icon': '🌿', 'desc': l10n.onboardingCatNatureDesc},
        {'id': 'cafe', 'label': l10n.onboardingCatCafeLabel, 'icon': '☕', 'desc': l10n.onboardingCatCafeDesc},
        {'id': 'shopping', 'label': l10n.onboardingCatShoppingLabel, 'icon': '🛍️', 'desc': l10n.onboardingCatShoppingDesc},
        {'id': 'culture', 'label': l10n.onboardingCatArtLabel, 'icon': '🎶', 'desc': l10n.onboardingCatArtDesc},
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
        SnackBar(
          content: Text(context.l10n.selectAtLeastOnePreference),
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
          content: Text(authState.error ?? context.l10n.cantSavePreferences),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = context.l10n;
    final categories = _categories(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.travelPreferences),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/map'),
            child: Text(l10n.skip),
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
                      l10n.whichExperience,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.preferencesSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
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
                text: l10n.saveAndExplore(_selectedPreferences.length),
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
