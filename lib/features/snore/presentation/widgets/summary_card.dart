import 'package:flutter/material.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final bool isLocked;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    required this.icon,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13), // ~0.05 opacity
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SnoreColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SnoreColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subValue != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        subValue!,
                        style: const TextStyle(
                          color: SnoreColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isLocked)
                  Row(
                    children: const [
                      Icon(
                        Icons.lock,
                        color: SnoreColors.textSecondary,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          color: SnoreColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
