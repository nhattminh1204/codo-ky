import 'package:flutter/material.dart';
import 'package:codoky/core/theme/motion.dart';

class PlaceMarker extends StatelessWidget {
  final String category;
  final bool isSelected;

  const PlaceMarker({
    super.key,
    required this.category,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);

    return AnimatedScale(
      scale: isSelected ? 1.18 : 1.0,
      duration: AppMotion.standard,
      curve: isSelected ? AppMotion.springyCurve : AppMotion.standardCurve,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.6 : 0.4),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _getCategoryIcon(category),
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'attraction':
        return Colors.blue;
      case 'temple':
        return Colors.purple;
      case 'tomb':
        return Colors.red;
      case 'entertainment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'attraction':
        return Icons.place;
      case 'temple':
        return Icons.church;
      case 'tomb':
        return Icons.account_balance;
      case 'entertainment':
        return Icons.games;
      default:
        return Icons.location_on;
    }
  }
}