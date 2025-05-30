import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../theme/app_theme.dart';
import '../../../widgets/markdown/markdown_message.dart';
import 'blinking_cursor.dart';
import 'chat_screen_controller.dart';

/// チャットメッセージリスト
class MessageList extends StatelessWidget {
  final ChatScreenController? controller;
  final bool isLoading;

  const MessageList({
    Key? key,
    required this.controller,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- メッセージリスト ---
        if (controller?.messages.isEmpty == true && isLoading)
          _buildSkeletonBubbles()
        else
          _buildMessageList(),

        // --- AI応答ローディング ---
        if (controller?.isLoading == true) _buildLoadingIndicator(context),

        // --- 履歴ロード中の超軽量インジケータ（画面右下） ---
        if (isLoading) _buildHistoryLoadingIndicator(),
      ],
    );
  }

  Widget _buildSkeletonBubbles() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: 3,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 24 + (index * 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMessageList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: ListView.builder(
        key: ValueKey(controller?.messages.length ?? 0),
        reverse: true,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        itemCount: controller?.messages.length ?? 0,
        itemBuilder: (context, index) {
          if (controller?.messages.isEmpty != false) {
            return const SizedBox.shrink();
          }
          final messageIndex = (controller?.messages.length ?? 0) - 1 - index;
          if (messageIndex < 0 ||
              messageIndex >= (controller?.messages.length ?? 0)) {
            return const SizedBox.shrink();
          }
          final message =
              controller?.messages[messageIndex] as types.TextMessage;
          final isUserMessage = message.author.id == controller?.user.id;
          // AI応答ストリーミング中の最新AIメッセージにはアニメーションカーソルを表示
          final isLatestAI =
              !isUserMessage && index == 0 && (controller?.isLoading == true);

          return Stack(
            children: [
              MarkdownMessage(message: message, isUserMessage: isUserMessage),
              if (isLatestAI)
                Positioned(
                  right: isUserMessage ? 8 : null,
                  left: isUserMessage ? null : 8,
                  bottom: 6,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: BlinkingCursor(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white.withOpacity(0.8),
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
              style: TextStyle(color: Colors.grey.shade800),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('停止'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () {
                controller?.cancelGeneration();
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('再生成'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () {
                controller?.regenerateLastMessage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryLoadingIndicator() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            const Text('履歴を取得中...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
