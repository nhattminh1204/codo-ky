import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';

class AISuggestionDialog extends ConsumerStatefulWidget {
  const AISuggestionDialog({super.key});

  @override
  ConsumerState<AISuggestionDialog> createState() => _AISuggestionDialogState();
}

class _AISuggestionDialogState extends ConsumerState<AISuggestionDialog> {
  final _formKey = GlobalKey<FormState>();
  int _durationDays = 2;
  double _budget = 2000000;
  final List<String> _selectedInterests = [];
  bool _isGenerating = false;

  final List<String> _allInterests = [
    'Ăn uống',
    'Văn hóa - Lịch sử',
    'Thiền - Tâm linh',
    'Nghỉ dưỡng',
    'Check-in sống ảo',
    'Mạo hiểm',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.purple),
          const SizedBox(width: 12),
          const Text('AI Tạo lộ trình'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập thông tin để AI đề xuất lộ trình phù hợp nhất cho bạn',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Duration
              Text('Số ngày:', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4, 5].map((day) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$day ngày'),
                        selected: _durationDays == day,
                        onSelected: (_) => setState(() => _durationDays = day),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Budget
              Text('Ngân sách dự kiến:', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              TextInput(
                controller: TextEditingController(text: _budget.toStringAsFixed(0)),
                label: 'VNĐ',
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Nhập ngân sách' : null,
                onChanged: (v) => _budget = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 24),
              // Interests
              Text('Sở thích:', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        PrimaryButton(
          text: 'Tạo lộ trình',
          isLoading: _isGenerating,
          onPressed: _isGenerating ? null : _generateItinerary,
        ),
      ],
    );
  }

  Future<void> _generateItinerary() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isGenerating = true);

      try {
        await ref.read(itineraryProvider.notifier).generateAISuggestion(
          durationDays: _durationDays,
          budget: _budget,
          interests: _selectedInterests,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI đang tạo lộ trình...')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isGenerating = false);
        }
      }
    }
  }
}