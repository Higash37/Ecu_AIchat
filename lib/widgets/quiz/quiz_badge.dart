import 'package:flutter/material.dart';

class QuizBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const QuizBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
