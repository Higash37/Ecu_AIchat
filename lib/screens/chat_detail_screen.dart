import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import '../models/message.dart' as app_models;
import '../services/chat_service.dart';
import '../services/message_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/markdown_message.dart';
import '../widgets/chat_input_field.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final Chat? chat;
  const ChatDetailScreen({super.key, required this.chatId, this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final MessageService _messageService = MessageService();
  final ChatService _chatService = ChatService();
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'ai');
  final List<types.Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  late Chat _chat;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    setState(() => _isLoading = true);

    if (widget.chat != null) {
      _chat = widget.chat!;
      await _loadMessages();
    } else {
      try {
        final chat = await _chatService.fetchChatById(widget.chatId);
        if (mounted) {
          setState(() {
            _chat = chat;
          });
          await _loadMessages();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('チャットの読み込みに失敗しました: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      final fetched = await _messageService.fetchMessagesByChat(widget.chatId);
      final mapped =
          fetched.map((m) {
            final isUser = m.sender == 'user';
            return types.TextMessage(
              author: isUser ? _user : _bot,
              id: m.id,
              text: m.content,
              createdAt: m.createdAt.millisecondsSinceEpoch,
            );
          }).toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(mapped);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('メッセージの読み込みに失敗しました: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onSendPressed(String message) async {
    if (message.trim().isEmpty) return;

    // UIメッセージを作成
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message,
    );
    setState(() {
      _messages.insert(0, textMessage);
      _isSending = true;
    });

    try {
      // 1. メッセージをDBに保存
      await _saveUserMessage(message);

      // 2. AIからの返答を取得
      final aiReply = await _fetchAIResponse(message);

      // 3. AIの返答もDBに保存
      await _saveAIMessage(aiReply);

      // 4. UIに追加
      final aiMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: aiReply,
      );

      if (mounted) {
        setState(() {
          _messages.insert(0, aiMessage);
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveUserMessage(String content) async {
    final message = app_models.Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      sender: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    await _messageService.createMessage(message);
    await _chatService.incrementMessageCount(widget.chatId);
  }

  Future<void> _saveAIMessage(String content) async {
    final message = app_models.Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      sender: 'ai',
      content: content,
      createdAt: DateTime.now(),
    );
    await _messageService.createMessage(message);
    await _chatService.updateLastMessage(widget.chatId, content);
    await _chatService.incrementMessageCount(widget.chatId);
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
    // 画面幅を取得してレイアウトを決定
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1000; // PCレイアウト用のしきい値

    return AppScaffold(
      title: _isLoading ? 'チャット読み込み中...' : _chat.title,
      currentNavIndex: 1,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : isWideScreen
              // PCレイアウト - サイドバー形式
              ? Row(
                children: [
                  // 左側：チャット履歴サイドバー（全体の30%）
                  Container(
                    width: screenWidth * 0.3, // 画面幅の30%
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        // サイドバーヘッダー
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'チャット履歴',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ここに履歴リストを表示する場合は追加
                        // 現状では空の領域として表示
                        Expanded(
                          child: Center(
                            child: Text(
                              '他の会話履歴',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 右側：チャット本体（全体の70%）
                  Expanded(child: _buildChatContent()),
                ],
              )
              // モバイルレイアウト - 全画面表示
              : _buildChatContent(),
    );
  }

  // チャットのメインコンテンツを構築
  Widget _buildChatContent() {
    return Column(
      children: [
        // AIアシスタントヘッダー（ChatGPT風）
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
        // 区切り線
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withAlpha((0.2 * 255).round()),
        ),
        // チャットメッセージ表示エリア
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // PCとタブレット用の条件（画面幅が広い場合）
              final isWideScreen = constraints.maxWidth > 600;
              final contentWidth =
                  isWideScreen
                      ? constraints.maxWidth *
                          0.7 // 画面幅の70%
                      : constraints.maxWidth; // スマホでは全幅

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
                        _messages.isEmpty
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
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        _messages[index] as types.TextMessage;
                                    final isUserMessage =
                                        message.author.id == _user.id;
                                    return MarkdownMessage(
                                      message: message,
                                      isUserMessage: isUserMessage,
                                    );
                                  },
                                ),
                                if (_isSending)
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
        // 入力エリア
        ChatInputField(onSendPressed: _onSendPressed),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('タイトル変更'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTitleDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDFとして保存'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF生成機能は準備中です'),
                      behavior: SnackBarBehavior.floating,
                    ),
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

  void _showEditTitleDialog(BuildContext context) {
    final titleController = TextEditingController(text: _chat.title);

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder:
          (context) => AlertDialog(
            title: const Text('チャットタイトル変更'),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('タイトルを入力してください'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  try {
                    await _chatService.updateChatTitle(widget.chatId, title);
                    setState(() {
                      _chat = Chat(
                        id: _chat.id,
                        projectId: _chat.projectId,
                        title: title,
                        createdAt: _chat.createdAt,
                        updatedAt: _chat.updatedAt,
                        lastMessage: _chat.lastMessage,
                        messageCount: _chat.messageCount,
                      );
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('タイトルを更新しました')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('タイトル更新に失敗しました: $e')),
                      );
                    }
                  }
                },
                child: const Text('更新'),
              ),
            ],
          ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder:
          (context) => AlertDialog(
            title: const Text('チャット履歴をクリア'),
            content: const Text('すべてのメッセージが削除されます。この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    // TODO: メッセージクリア機能実装
                    // await _messageService.deleteAllMessages(widget.chatId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('チャット履歴を削除しました'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    setState(() {
                      _messages.clear();
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('チャット履歴の削除に失敗しました: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text('クリア'),
              ),
            ],
          ),
    );
  }
}
