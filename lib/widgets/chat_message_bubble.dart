import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_theme.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) _buildAvatar(isAI: true),
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
                  padding: const EdgeInsets.only(
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
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
                if (!isUserMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          context,
                          Icons.refresh,
                          '再生成',
                          onPressed: () {
                            // TODO: 再生成機能の実装
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('再生成機能は準備中です')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.edit_note,
                          '要望追加',
                          onPressed: () {
                            // TODO: 要望追加機能の実装
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('要望追加機能は準備中です')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.content_copy,
                          'コピー',
                          onPressed: () {
                            // TODO: コピー機能の実装
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('テキストをコピーしました')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isUserMessage) _buildAvatar(isAI: false),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isAI}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor:
              isAI
                  ? AppTheme
                      .primaryColor // AIのアバター色
                  : Colors.grey.shade300, // ユーザーのアバター色
          radius: 16,
          child: Icon(
            isAI ? Icons.smart_toy : Icons.person,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
