import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../theme/app_theme.dart';
import '../../../widgets/markdown/markdown_message.dart';
import '../../../widgets/chat/chat_input_field.dart';

class ChatDetailContent extends StatelessWidget {
  final List<types.Message> messages;
  final bool isSending;
  final void Function(String) onSendPressed;
  final types.User user;
  final types.User bot;

  const ChatDetailContent({
    super.key,
    required this.messages,
    required this.isSending,
    required this.onSendPressed,
    required this.user,
    required this.bot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AIアシスタントヘッダー
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(
                  (0.15 * 255).round(),
                ),
                radius: 20,
                child: const Icon(
                  Icons.smart_toy,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "AI アシスタント",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "学習のサポートをします",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withAlpha((0.2 * 255).round()),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;
              final contentWidth =
                  isWideScreen
                      ? constraints.maxWidth * 0.7
                      : constraints.maxWidth;
              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      image: DecorationImage(
                        image: const AssetImage('assets/images/chat_bg.png'),
                        repeat: ImageRepeat.repeat,
                        opacity: 0.08,
                      ),
                    ),
                    child:
                        messages.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'メッセージがありません',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '下のテキスト欄からメッセージを送信してください',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : Stack(
                              children: [
                                ListView.builder(
                                  reverse: true,
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 16,
                                  ),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        messages[index] as types.TextMessage;
                                    final isUserMessage =
                                        message.author.id == user.id;
                                    return MarkdownMessage(
                                      message: message,
                                      isUserMessage: isUserMessage,
                                    );
                                  },
                                ),
                                if (isSending)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.white.withAlpha(
                                        (0.8 * 255).round(),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'AIが回答を考えています...',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ),
              );
            },
          ),
        ),
        ChatInputField(onSendPressed: onSendPressed),
      ],
    );
  }
}
