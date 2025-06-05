import 'package:flutter/material.dart';
import '../../../../app_models/models/chat.dart';
import '../../../../supabase_ui/screens/chat_screens/chat_screen/chat_screen.dart';
import 'package:intl/intl.dart';

/// Drawer内のチャット履歴アイテム用Widget
class DrawerChatItem extends StatelessWidget {
  final Chat chat;
  const DrawerChatItem({super.key, required this.chat});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date.isAfter(today)) {
      return '今日';
    } else if (date.isAfter(yesterday)) {
      return '昨日';
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastDate = chat.updatedAt ?? chat.createdAt;
    final dateText = _formatDate(lastDate);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatScreen(
                    chatId: chat.id,
                    projectId: chat.projectId ?? '',
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((chat.lastMessage ?? '').isNotEmpty)
                      Text(
                        chat.lastMessage ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (dateText.isNotEmpty)
                Text(
                  dateText,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
