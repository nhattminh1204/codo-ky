import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/widgets/buttons/primary_button.dart';
import 'package:codoky/core/widgets/inputs/text_input.dart';
import 'package:codoky/features/review/data/models/review_model.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';

class WriteReviewBottomSheet extends ConsumerStatefulWidget {
  final String? initialPlaceId;
  final String? initialPlaceName;

  const WriteReviewBottomSheet({
    super.key,
    this.initialPlaceId,
    this.initialPlaceName,
  });

  @override
  ConsumerState<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends ConsumerState<WriteReviewBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _placeController;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  String _selectedPlaceId = '1';
  String _selectedPlaceName = 'Đại Nội Huế (Hoàng Thành)';

  final List<Map<String, String>> _availablePlaces = const [
    {'id': '1', 'name': 'Đại Nội Huế (Hoàng Thành)'},
    {'id': '669249193', 'name': 'Lăng Tự Đức'},
    {'id': '1333018015', 'name': 'Chùa Thiên Mụ'},
    {'id': 'f1', 'name': 'Bún Bò Huế Mụ Rớt'},
    {'id': 'f2', 'name': 'Quán Cơm Hến Hoa Đông'},
    {'id': 'c1', 'name': 'Cafe Muối Gốc Cố Đô'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPlaceId != null && widget.initialPlaceId!.isNotEmpty) {
      _selectedPlaceId = widget.initialPlaceId!;
    }
    if (widget.initialPlaceName != null && widget.initialPlaceName!.isNotEmpty) {
      _selectedPlaceName = widget.initialPlaceName!;
    }
    _placeController = TextEditingController(text: _selectedPlaceName);
  }

  @override
  void dispose() {
    _placeController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showPlacePicker() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn địa điểm đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        children: _availablePlaces.map((place) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() {
                _selectedPlaceId = place['id']!;
                _selectedPlaceName = place['name']!;
                _placeController.text = _selectedPlaceName;
              });
              Navigator.pop(ctx);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(place['name']!, style: const TextStyle(fontSize: 14)),
            ),
          );
        }).toList(),
      ),
    );
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
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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
                controller: _placeController,
                label: 'Địa điểm',
                hint: 'Chọn địa điểm',
                prefixIcon: const Icon(Icons.place_outlined),
                validator: (v) => Validators.required(v, fieldName: 'Địa điểm'),
                readOnly: true,
                onTap: _showPlacePicker,
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
                validator: (v) => Validators.minLength(v, 3, fieldName: 'Tiêu đề'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              // Content
              TextInput(
                controller: _contentController,
                label: 'Nội dung',
                hint: 'Chia sẻ trải nghiệm của bạn về địa điểm này...',
                prefixIcon: const Icon(Icons.description_outlined),
                validator: (v) => Validators.minLength(v, 10, fieldName: 'Nội dung'),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Đăng đánh giá',
                isLoading: _isSubmitting,
                onPressed: _submitReview,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final review = ReviewModel(
          id: '',
          userId: '',
          userName: 'Du khách Huế',
          placeId: _selectedPlaceId,
          placeName: _selectedPlaceName,
          rating: _rating,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(reviewProvider.notifier).createReview(review);

        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng đánh giá thành công!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
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