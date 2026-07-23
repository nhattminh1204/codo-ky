import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';

class WriteReviewBottomSheet extends ConsumerStatefulWidget {
  const WriteReviewBottomSheet({super.key});

  @override
  ConsumerState<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends ConsumerState<WriteReviewBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  double _rating = 0;
  String? _selectedPlaceId;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Viết đánh giá',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Place selection
              TextInput(
                controller: TextEditingController(),
                label: 'Địa điểm',
                hint: 'Chọn địa điểm',
                prefixIcon: const Icon(Icons.place_outlined),
                validator: (v) => Validators.required(v, fieldName: 'Địa điểm'),
                readOnly: true,
                onTap: () {
                  // TODO: Show place picker
                },
              ),
              const SizedBox(height: 16),
              // Rating
              Text(
                'Đánh giá của bạn',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RatingSelector(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 16),
              // Title
              TextInput(
                controller: _titleController,
                label: 'Tiêu đề',
                hint: 'Viết tiêu đề đánh giá...',
                prefixIcon: const Icon(Icons.title_outlined),
                validator: (v) => Validators.minLength(v, 5, fieldName: 'Tiêu đề'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              // Content
              TextInput(
                controller: _contentController,
                label: 'Nội dung',
                hint: 'Chia sẻ trải nghiệm của bạn...',
                prefixIcon: const Icon(Icons.description_outlined),
                validator: (v) => Validators.minLength(v, 20, fieldName: 'Nội dung'),
                maxLines: 5,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Đăng đánh giá',
                isLoading: false,
                onPressed: _submitReview,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
        );
        return;
      }

      // TODO: Submit review
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng đánh giá thành công!')),
      );
    }
  }
}

class _RatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starRating = index + 1.0;
        return IconButton(
          icon: Icon(
            starRating <= rating ? Icons.star : Icons.star_border,
            size: 36,
            color: starRating <= rating ? Colors.amber : Colors.grey,
          ),
          onPressed: () => onChanged(starRating),
        );
      }),
    );
  }
}