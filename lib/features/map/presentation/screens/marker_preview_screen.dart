import 'package:flutter/material.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

class MarkerPreviewScreen extends StatelessWidget {
  const MarkerPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Map Marker Visual Inspection Gallery',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text(
                'CO DOKY MAP MARKER STATES (REAL RENDER)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Live pixel-perfect render of Default, Selected, Saved, Featured, and Dual-Badge markers',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),

              // Grid / Table of 6 States
              Wrap(
                spacing: 36,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  // a) Default Marker
                  _buildPreviewCard(
                    title: 'a. Marker Default',
                    subtitle: 'Normal state (Scale 1.0x, shadow 10px)',
                    child: const PlaceMarker(
                      category: 'attraction',
                      state: PlaceMarkerState.defaultState,
                    ),
                  ),

                  // b) Selected Marker
                  _buildPreviewCard(
                    title: 'b. Marker Selected',
                    subtitle: 'Selected state (Scale 1.16x, glow 18px)',
                    child: const PlaceMarker(
                      category: 'cafe',
                      state: PlaceMarkerState.selected,
                    ),
                  ),

                  // c) Saved Marker
                  _buildPreviewCard(
                    title: 'c. Marker Saved',
                    subtitle: 'Saved (Heart badge top-right)',
                    child: const PlaceMarker(
                      category: 'food',
                      isSaved: true,
                    ),
                  ),

                  // d) Featured Marker
                  _buildPreviewCard(
                    title: 'd. Marker Featured',
                    subtitle: 'Featured (Star badge top-left + Pulse)',
                    child: const PlaceMarker(
                      category: 'temple',
                      state: PlaceMarkerState.featured,
                    ),
                  ),

                  // e) Saved + Featured (Dual Badges)
                  _buildPreviewCard(
                    title: 'e. Saved + Featured (Dual)',
                    subtitle: 'Both badges (Heart right, Star left)',
                    child: const PlaceMarker(
                      category: 'attraction',
                      isSaved: true,
                      isFeatured: true,
                    ),
                  ),

                  // f) Selected + Saved
                  _buildPreviewCard(
                    title: 'f. Selected + Saved',
                    subtitle: 'Selected 1.16x + Heart badge',
                    child: const PlaceMarker(
                      category: 'food',
                      isSelected: true,
                      isSaved: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 90,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
