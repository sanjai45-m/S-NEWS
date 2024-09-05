import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/dark_theme_provider.dart';

class BadgeWidgets extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;

  const BadgeWidgets({super.key,
    required this.child,
    required this.count,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                maxWidth: 24,
                maxHeight: 24,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style:  const TextStyle(
            color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
