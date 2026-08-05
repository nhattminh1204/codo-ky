import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
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

  final _durationIds = const ['1d', '2d1n', '3d2n', '4d3n'];
  final _companionIds = const ['solo', 'couple', 'family', 'friends'];
  final _styleIds = const ['heritage', 'food', 'chill', 'temple', 'photo', 'nature'];
  final _budgetIds = const ['saver', 'standard', 'luxury'];

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
    final l10n = context.l10n;
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
            content: Text(l10n.quotaWarning(currentQuota)),
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

  String _durationLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case '1d':
        return l10n.duration1d;
      case '2d1n':
        return l10n.duration2d;
      case '4d3n':
        return l10n.duration4d;
      default:
        return l10n.duration3d;
    }
  }

  String _companionLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case 'solo':
        return l10n.companionSolo;
      case 'family':
        return l10n.companionFamily;
      case 'friends':
        return l10n.companionFriends;
      default:
        return l10n.companionCouple;
    }
  }

  String _styleLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case 'food':
        return l10n.styleFood;
      case 'chill':
        return l10n.styleChill;
      case 'temple':
        return l10n.styleSpiritual;
      case 'photo':
        return l10n.styleCheckin;
      case 'nature':
        return l10n.styleNature;
      default:
        return l10n.styleHeritage;
    }
  }

  String _budgetLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case 'saver':
        return l10n.budgetSaving;
      case 'luxury':
        return l10n.budgetVip;
      default:
        return l10n.budgetStandard;
    }
  }

  String _budgetDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case 'saver':
        return l10n.budgetSavingDesc;
      case 'luxury':
        return l10n.budgetVipDesc;
      default:
        return l10n.budgetStandardDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.aiSetupTitle,
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
                    l10n.heroSubtitle,
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
                  Text(
                    l10n.sectionDuration,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durationIds.map((id) {
                      final isSelected = _selectedDuration == id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = id),
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
                            _durationLabel(id, l10n),
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
                  Text(
                    l10n.sectionCompanion,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _companionIds.map((id) {
                      final isSelected = _selectedCompanion == id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCompanion = id),
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
                            _companionLabel(id, l10n),
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
                  Text(
                    l10n.sectionStyle,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _styleIds.map((id) {
                      final isSelected = _selectedStyles.contains(id);
                      return GestureDetector(
                        onTap: () => _toggleStyle(id),
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
                            _styleLabel(id, l10n),
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
                  Text(
                    l10n.sectionBudget,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _budgetIds.map((id) {
                      final isSelected = _selectedBudget == id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedBudget = id),
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
                                        _budgetLabel(id, l10n),
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      ),
                                      Text(
                                        _budgetDesc(id, l10n),
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
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(l10n.aiGenerating, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.createAiItinerary,
                                      style: const TextStyle(
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
