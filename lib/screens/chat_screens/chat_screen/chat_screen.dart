import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../../../widgets/markdown/markdown_message.dart';
import '../../../widgets/chat/chat_input_field.dart';
import 'chat_screen_controller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String projectId;
  const ChatScreen({super.key, required this.chatId, required this.projectId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenController? _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = ChatScreenController(
      chatId: widget.chatId,
      projectId: widget.projectId,
    );
    _initFuture = _controller!.init();
    _controller!.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '新規チャット',
      currentNavIndex: 2,
      actions: [
        // --- モデル切り替えドロップダウンを追加 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(height: 36, child: _ModelSelector()),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ],
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          // --- 極限まで高速表示: 履歴ロード中もUI即表示・入力即可能 ---
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return Column(
            children: [
              Expanded(
                child: Container(
                  color: AppTheme.backgroundColor,
                  child: Stack(
                    children: [
                      // --- メッセージリスト ---
                      if (_controller!.messages.isEmpty && isLoading)
                        // スケルトンバブル（履歴ロード中・メッセージなし）
                        ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          itemCount: 3,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        )
                      else
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: ListView.builder(
                            key: ValueKey(_controller!.messages.length),
                            reverse: true,
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            itemCount: _controller!.messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  _controller!.messages[_controller!
                                              .messages
                                              .length -
                                          1 -
                                          index]
                                      as types.TextMessage;
                              final isUserMessage =
                                  message.author.id == _controller!.user.id;
                              // AI応答ストリーミング中の最新AIメッセージにはアニメーションカーソルを表示
                              final isLatestAI =
                                  !isUserMessage &&
                                  index == 0 &&
                                  _controller!.isLoading;
                              return Stack(
                                children: [
                                  MarkdownMessage(
                                    message: message,
                                    isUserMessage: isUserMessage,
                                  ),
                                  if (isLatestAI)
                                    Positioned(
                                      right: isUserMessage ? 8 : null,
                                      left: isUserMessage ? null : 8,
                                      bottom: 6,
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: _BlinkingCursor(),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      // --- AI応答ローディング ---
                      if (_controller!.isLoading)
                        Positioned(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller?.cancelGeneration();
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('再生成'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(60, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller?.regenerateLastMessage(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      // --- 履歴ロード中の超軽量インジケータ（画面右下） ---
                      if (isLoading)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 6),
                              ],
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
                                const Text(
                                  '履歴を取得中...',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // --- 入力欄は常に即表示・即入力可能 ---
              ChatInputField(
                onSendPressed:
                    (msg) => _controller?.onSendPressed(context, msg),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('チャットを保存'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('チャット保存機能は準備中です')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDFとして保存'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF生成機能は準備中です')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('チャット履歴をクリア'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('チャット履歴をクリア'),
            content: const Text('すべてのメッセージが削除されます。この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller?.clearMessages();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('クリア'),
              ),
            ],
          ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller =
        context.findAncestorStateOfType<_ChatScreenState>()?._controller;
    String selectedModel = controller?.selectedModel ?? 'gpt-4o';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedModel,
          items: [
            DropdownMenuItem(value: 'gpt-4o', child: Text('GPT-4o')),
            DropdownMenuItem(value: 'higash-ai', child: Text('Higash-AI')),
          ],
          onChanged: (value) {
            if (controller != null && value != null) {
              HapticFeedback.selectionClick(); // モデル切替時にカチッ
              controller.setModel(value);
            }
          },
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          ),
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
        ),
      ),
    );
  }
}

// 末尾に追加
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 1, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: Container(
        width: 12,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
