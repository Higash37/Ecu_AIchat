import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'ai');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初期メッセージを表示
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text:
          "こんにちは！AI教材チャットへようこそ。\n"
          "授業の準備や教材作成のお手伝いをします。\n"
          "以下のような質問ができます：\n\n"
          "- 「中学2年生向けの英語長文問題を作成して」\n"
          "- 「数学の二次関数について説明する教材を作って」\n"
          "- 「古典文学の教え方のコツは？」\n\n"
          "どのようなお手伝いができますか？",
    );

    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  void _onSendPressed(String message) async {
    if (message.trim().isEmpty) return;

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _isLoading = true;
    });

    try {
      final aiReply = await _fetchAIResponse(message);

      final aiMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: aiReply,
      );

      setState(() {
        _messages.insert(0, aiMessage);
        _isLoading = false;
      });
    } catch (error) {
      final errorMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: "申し訳ありません。エラーが発生しました。\nしばらく経ってからもう一度お試しください。\n\nエラー詳細: $error",
      );

      setState(() {
        _messages.insert(0, errorMessage);
        _isLoading = false;
      });
    }
  }

  Future<String> _fetchAIResponse(String text) async {
    final uri = Uri.parse('http://127.0.0.1:8000/chat');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": text},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final reply =
        (json is Map && json.containsKey("reply"))
            ? json["reply"]
            : "[返答がありませんでした]";

    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '新規チャット',
      currentNavIndex: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ],
      body: Column(
        children: [
          // チャットヘッダー（プロジェクト情報など）
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '未保存のチャット',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('保存'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チャットの保存機能は現在開発中です')),
                    );
                  },
                ),
              ],
            ),
          ),

          // チャットメッセージ表示エリア
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Text(
                          '最初のメッセージを送信してください',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                      : Stack(
                        children: [
                          ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  _messages[index] as types.TextMessage;
                              final isUserMessage =
                                  message.author.id == _user.id;

                              return ChatMessageBubble(
                                message: message,
                                isUserMessage: isUserMessage,
                              );
                            },
                          ),
                          if (_isLoading)
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
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),

          // 入力エリア
          ChatInputField(onSendPressed: _onSendPressed),
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
                  setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  });
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
