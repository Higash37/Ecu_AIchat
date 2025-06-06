import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../app_styles/app_theme.dart';
import 'chat_message_avatar.dart';
import 'chat_message_action_buttons.dart';

class ChatMessageBubble extends StatelessWidget {
  final types.TextMessage message;
  final bool isUserMessage;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  // 時間フォーマット用のヘルパーメソッドを追加
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUserMessage) const ChatMessageAvatar(isAI: true),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration:
                        isUserMessage
                            ? AppTheme.userMessageBubble
                            : AppTheme.aiMessageBubble,
                    child:
                        isUserMessage
                            ? Text(message.text, style: AppTheme.bodyText)
                            : MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: AppTheme.bodyText,
                                code: TextStyle(
                                  fontFamily: 'monospace',
                                  backgroundColor: Colors.grey.shade200,
                                  fontSize: 14,
                                ),
                                h1: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                h2: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                h3: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                listBullet: TextStyle(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                  ),
                  // メッセージ時刻表示（LINE風）
                  Padding(
                    padding: EdgeInsets.only(
                      top: 2.0,
                      left: isUserMessage ? 0 : 4.0,
                      right: isUserMessage ? 4.0 : 0,
                    ),
                    child: Text(
                      _formatTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          message.createdAt ?? 0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  // メッセージ時刻表示
                  Padding(
                    padding: EdgeInsets.only(
                      top: 2.0,
                      left: isUserMessage ? 0 : 4.0,
                      right: isUserMessage ? 4.0 : 0,
                    ),
                    child: Text(
                      _formatTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          message.createdAt ?? 0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  if (!isUserMessage)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ChatMessageActionButtons(
                        onRegenerate: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('再生成機能は準備中です')),
                          );
                        },
                        onCopy: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('テキストをコピーしました')),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (isUserMessage) const ChatMessageAvatar(isAI: false),
          ],
        ),
      ),
    );
  }
}

// _buildAvatar, _buildActionButtonは削除済み
