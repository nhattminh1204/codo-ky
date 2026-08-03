import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/itinerary/presentation/widgets/place_picker_bottom_sheet.dart';

class ItineraryResultScreen extends ConsumerStatefulWidget {
  const ItineraryResultScreen({super.key});

  @override
  ConsumerState<ItineraryResultScreen> createState() => _ItineraryResultScreenState();
}

class _ItineraryResultScreenState extends ConsumerState<ItineraryResultScreen> {
  int _activeDay = 0;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final itineraryState = ref.watch(itineraryProvider);
    final itinerary = itineraryState.aiSuggestions.isNotEmpty
        ? itineraryState.aiSuggestions.first
        : (itineraryState.myItineraries.isNotEmpty ? itineraryState.myItineraries.last : null);

    if (itinerary == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Lịch trình AI Huế', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 64, color: Color(0xFFFF7A00)),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lộ trình AI nào được khởi tạo.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hãy thiết lập nhu cầu du lịch để AI đề xuất lịch trình tối ưu nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/itinerary/setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Tạo Lộ Trình Ngay ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final days = itinerary.days;
    if (_activeDay >= days.length) {
      _activeDay = 0;
    }
    final currentDay = days.isNotEmpty ? days[_activeDay] : null;

    final totalStops = days.fold<int>(0, (sum, day) => sum + day.activities.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Lịch trình AI Huế ✨',
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
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isSaved ? const Color(0xFFFF5E62) : const Color(0xFF1E1E1E),
            ),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              if (_isSaved) {
                ref.read(itineraryProvider.notifier).saveItinerary(itinerary);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSaved ? 'Đã lưu lịch trình vào danh sách của bạn!' : 'Đã bỏ lưu lịch trình.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TRIP SUMMARY OVERVIEW CARD
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5E62).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🌸 Lịch trình Gemini AI',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            SizedBox(width: 4),
                            Text('4.9 AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      itinerary.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itinerary.description,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTripBadge('${itinerary.durationDays} Ngày'),
                        const SizedBox(width: 8),
                        _buildTripBadge('$totalStops Điểm dừng'),
                        const SizedBox(width: 8),
                        _buildTripBadge('${(itinerary.budget / 1000).toInt()}k VNĐ'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. DAY TABS BAR
            if (days.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: List.generate(days.length, (index) {
                    final day = days[index];
                    final isSelected = index == _activeDay;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeDay = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF7A00) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Text(
                            'Ngày ${day.dayNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            const SizedBox(height: AppSpacing.md),

            // DAY TITLE
            if (currentDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDay.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                    ),
                    if (currentDay.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        currentDay.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 10),

            // 3. TIMELINE STOPS LIST
            if (currentDay != null && currentDay.activities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentDay.activities.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (itinerary.status == 'completed') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể sửa lộ trình đã hoàn thành.')));
                      return;
                    }
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    try {
                      final isLate = await ref.read(itineraryProvider.notifier).reorderActivity(
                        itinerary.id,
                        _activeDay,
                        oldIndex,
                        newIndex,
                      );
                      if (isLate && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('⚠️ Cảnh báo: Lịch trình vượt quá 22:00 do thay đổi.'),
                          backgroundColor: Colors.orange,
                        ));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    final activity = currentDay.activities[index];
                    final isLast = index == currentDay.activities.length - 1;

                    return _buildTimelineStopCard(
                      context,
                      key: ValueKey(activity.id),
                      activity: activity,
                      index: index + 1,
                      isLast: isLast,
                      onDelete: itinerary.status == 'completed' ? null : () => _confirmDeleteActivity(context, itinerary.id, _activeDay, activity),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text('Không có hoạt động nào cho ngày này.', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ),

            // 4. ADD ACTIVITY BUTTON FOR CURRENT DAY
            if (itinerary.status != 'completed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                child: InkWell(
                  onTap: () => _openPlacePicker(context, itinerary.id, _activeDay),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7A00).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_location_alt_rounded, color: Color(0xFFFF7A00), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Thêm điểm đến vào lộ trình',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openPlacePicker(BuildContext context, String itineraryId, int dayIndex) async {
    final selectedPlace = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PlacePickerBottomSheet(),
    );

    if (selectedPlace == null || !context.mounted) return;

    final String? placeId = selectedPlace['id']?.toString() ?? selectedPlace['place_id']?.toString();
    final String? placeName = selectedPlace['name']?.toString() ?? selectedPlace['place_name']?.toString();
    final rawLat = selectedPlace['latitude'] ?? selectedPlace['lat'];
    final rawLng = selectedPlace['longitude'] ?? selectedPlace['lng'];

    if (placeId == null || placeId.isEmpty || placeName == null || placeName.isEmpty || rawLat == null || rawLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu địa điểm không hợp lệ, vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double latitude = rawLat.toDouble();
    final double longitude = rawLng.toDouble();

    try {
      final isLate = await ref.read(itineraryProvider.notifier).addActivity(
        itineraryId,
        dayIndex,
        placeId: placeId,
        placeName: placeName,
        latitude: latitude,
        longitude: longitude,
      );

      if (isLate && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('⚠️ Cảnh báo: Lịch trình vượt quá 22:00 do thêm địa điểm mới.'),
          backgroundColor: Colors.orange,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không thể thêm địa điểm: $message'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _confirmDeleteActivity(BuildContext context, String itineraryId, int dayIndex, ItineraryActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${activity.name}" khỏi lộ trình ngày này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final isLate = await ref.read(itineraryProvider.notifier).removeActivity(itineraryId, dayIndex, activity.id);
                if (isLate && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('⚠️ Cảnh báo: Lịch trình vượt quá 22:00 do thay đổi.'),
                    backgroundColor: Colors.orange,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  final message = e.toString().replaceAll('Exception: ', '');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Không thể xóa hoạt động: $message'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTripBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTimelineStopCard(
    BuildContext context, {
    Key? key,
    required ItineraryActivityModel activity,
    required int index,
    required bool isLast,
    VoidCallback? onDelete,
  }) {
    final startTimeStr =
        '${activity.startTime.hour.toString().padLeft(2, '0')}:${activity.startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr =
        '${activity.endTime.hour.toString().padLeft(2, '0')}:${activity.endTime.minute.toString().padLeft(2, '0')}';
    final timeRange = '$startTimeStr - $endTimeStr';

    final categoryTag = activity.type.toLowerCase().contains('restaurant') || activity.type.toLowerCase().contains('eat') || activity.type.toLowerCase().contains('food')
        ? '🍜 Ẩm thực'
        : (activity.type.toLowerCase().contains('temple') ? '⛩️ Tâm linh' : '🏰 Di sản');

    final image = 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=400&auto=format&fit=crop&q=80';

    return IntrinsicHeight(
      key: key,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator Bar
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7A00),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFFFEAD8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Stop Details Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  if (activity.placeId.isNotEmpty) {
                    context.push('/place/${activity.placeId}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeRange,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryTag,
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.placeName.isNotEmpty ? activity.placeName : activity.name,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                ),
                                Text(
                                  activity.description.isNotEmpty ? activity.description : 'Điểm tham quan Huế',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '💡 ${activity.notes}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
