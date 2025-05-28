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
  late ChatScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatScreenController(
      chatId: widget.chatId,
      projectId: widget.projectId,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
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
      body: Column(
        children: [
          // --- モデル切り替えドロップダウンはヘッダー(actions)のみで本文には表示しない ---
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child:
                  _controller.messages.isEmpty
                      ? Center(
                        child: Text(
                          '最初のメッセージを送信してください',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                      : Stack(
                        children: [
                          ListView.builder(
                            reverse: false, // 並び順: user→AI→user→AI...
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            itemCount: _controller.messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  _controller.messages[index]
                                      as types.TextMessage;
                              final isUserMessage =
                                  message.author.id == _controller.user.id;
                              return MarkdownMessage(
                                message: message,
                                isUserMessage: isUserMessage,
                              );
                            },
                          ),
                          if (_controller.isLoading)
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
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                      ),
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
                                        _controller.cancelGeneration();
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
                                        _controller.regenerateLastMessage(
                                          context,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),
          ChatInputField(
            onSendPressed: (msg) => _controller.onSendPressed(context, msg),
          ),
        ],
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
                  _controller.clearMessages();
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
