import 'package:flutter/material.dart';
import '../const_home_feed/consts.dart';

class TabItem extends StatelessWidget {
  final String text;
  final NewsType type;
  final NewsType currentType;
  final Function(NewsType) onTabSelected;
  final bool isDarkMode;

  const TabItem({
    super.key,
    required this.text,
    required this.type,
    required this.currentType,
    required this.onTabSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentType == type;

    return GestureDetector(
      onTap: () => onTabSelected(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.black : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSelected ? 18 : 14,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.white70 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
