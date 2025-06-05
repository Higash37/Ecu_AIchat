import 'package:flutter/material.dart';
import '../../../app_styles/theme/app_theme.dart';

class MarkdownMessageHeader extends StatelessWidget {
  final bool isUserMessage;
  final int? createdAt;

  const MarkdownMessageHeader({
    super.key,
    required this.isUserMessage,
    required this.createdAt,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
              isUserMessage ? Colors.grey.shade300 : AppTheme.primaryColor,
          radius: 16,
          child: Icon(
            isUserMessage ? Icons.person : Icons.smart_toy,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isUserMessage ? 'あなた' : 'AI教材チャット',
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(DateTime.fromMillisecondsSinceEpoch(createdAt ?? 0)),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
