// project_detail_chat_list.dart
// チャットリストWidget

import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../theme/app_theme.dart';
import '../../chat_screens/chat_detail_screen/chat_detail_screen.dart';

class ProjectDetailChatList extends StatelessWidget {
  final List<Chat> chats;
  const ProjectDetailChatList({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                child: Text(
                  chat.title.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                chat.title,
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage ?? 'メッセージがありません',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chat.updatedAt ?? chat.createdAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.message_outlined,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chat.messageCount ?? 0}メッセージ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryColor,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChatDetailScreen(chatId: chat.id, chat: chat),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
