import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/itinerary/presentation/widgets/itinerary_card.dart';
import 'package:codoky/features/itinerary/presentation/widgets/ai_suggestion_dialog.dart';
import 'package:codoky/shared/widgets/empty_state_widget.dart';

class ItineraryPage extends ConsumerStatefulWidget {
  const ItineraryPage({super.key});

  @override
  ConsumerState<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends ConsumerState<ItineraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryProvider.notifier).loadMyItineraries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itineraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF9B1B30)),
            const SizedBox(width: 8),
            Text(
              'Lịch trình AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9B1B30),
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showCreateItineraryDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tạo mới'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9B1B30),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9B1B30),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF9B1B30),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Lộ trình của tôi'),
            Tab(text: 'Đề xuất AI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyItinerariesTab(
            itineraries: state.myItineraries,
            isLoading: state.isLoading,
          ),
          _AISuggestionsTab(
            suggestions: state.aiSuggestions,
            isLoading: state.isLoadingSuggestions,
            onGenerate: () => _showAISuggestionDialog(),
          ),
        ],
      ),
    );
  }

  void _showCreateItineraryDialog() {}

  void _showAISuggestionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AISuggestionDialog(),
    );
  }
}

class _MyItinerariesTab extends StatelessWidget {
  final List<dynamic> itineraries;
  final bool isLoading;

  const _MyItinerariesTab({
    required this.itineraries,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B1B30)));
    }

    if (itineraries.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.route_outlined,
        title: 'Chưa có lộ trình nào',
        message: 'Tạo lộ trình đầu tiên của bạn hoặc để AI gợi ý hành trình khám phá Huế!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itineraries.length,
      itemBuilder: (context, index) {
        return ItineraryCard(
          itinerary: itineraries[index],
          onTap: () {},
        );
      },
    );
  }
}

class _AISuggestionsTab extends StatelessWidget {
  final List<dynamic> suggestions;
  final bool isLoading;
  final VoidCallback onGenerate;

  const _AISuggestionsTab({
    required this.suggestions,
    required this.isLoading,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9B1B30)));
    }

    if (suggestions.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            EmptyStateWidget(
              icon: Icons.auto_awesome_outlined,
              title: 'Chưa có đề xuất AI',
              message: 'Nhấn nút bên dưới để AI tạo lộ trình du lịch Huế phù hợp với bạn!',
            ),
            const SizedBox(height: 16),
            _buildDurationSelector(context),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ItineraryCard(
          itinerary: suggestions[index],
          isAISuggestion: true,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Column(
      children: [
        Text(
          'Chọn thời gian du lịch',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DurationCard(days: 1, label: '1 Ngày', icon: Icons.wb_sunny, onTap: onGenerate),
            _DurationCard(days: 2, label: '2 Ngày', icon: Icons.calendar_view_day, onTap: onGenerate),
            _DurationCard(days: 3, label: '3 Ngày', icon: Icons.date_range, onTap: onGenerate),
          ],
        ),
      ],
    );
  }
}

class _DurationCard extends StatelessWidget {
  final int days;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DurationCard({
    required this.days,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF9B1B30).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF9B1B30), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B1B30),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}