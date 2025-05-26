import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/chat.dart';
import '../../../models/message.dart' as app_models;
import '../../../services/chat_service.dart';
import '../../../services/message_service.dart';
import '../../../widgets/common/app_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_edit_title_dialog.dart';
import 'chat_detail_clear_dialog.dart';
import 'chat_detail_options_sheet.dart';
import 'chat_detail_content.dart';
import 'chat_detail_sidebar.dart';

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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final message = app_models.Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      sender: 'user',
      content: content,
      createdAt: DateTime.now(),
      userId: currentUserId, // ログインユーザーIDをセット
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
      userId: null, // AIはuserId: nullでもOK
    );
    await _messageService.createMessage(message);
    await _chatService.updateLastMessage(widget.chatId, content);
    await _chatService.incrementMessageCount(widget.chatId);
  }

  Future<String> _fetchAIResponse(String userInput) async {
    // 直近のチャット履歴（このチャットIDの全メッセージ）を取得
    final history = await _messageService.fetchMessagesByChat(widget.chatId);
    // role: 'user' or 'assistant' 形式でAIサーバーに渡す
    final messagesForAI =
        history
            .map(
              (m) => {
                'role': m.sender == 'user' ? 'user' : 'assistant',
                'content': m.content,
              },
            )
            .toList();
    // 今回のユーザー入力も追加
    messagesForAI.add({'role': 'user', 'content': userInput});

    final uri = Uri.parse('http://127.0.0.1:8000/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"messages": messagesForAI}),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: \\${response.statusCode}');
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
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      color: Colors.grey.shade50,
                    ),
                    child: const ChatDetailSidebar(),
                  ),
                  // 右側：チャット本体（全体の70%）
                  Expanded(
                    child: ChatDetailContent(
                      messages: _messages,
                      isSending: _isSending,
                      onSendPressed: _onSendPressed,
                      user: _user,
                      bot: _bot,
                    ),
                  ),
                ],
              )
              // モバイルレイアウト - 全画面表示
              : ChatDetailContent(
                messages: _messages,
                isSending: _isSending,
                onSendPressed: _onSendPressed,
                user: _user,
                bot: _bot,
              ),
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
        return ChatDetailOptionsSheet(
          onEditTitle: () => _showEditTitleDialog(context),
          onSavePdf: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF生成機能は準備中です'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onClear: () => _showClearConfirmation(context),
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
          (context) => ChatDetailEditTitleDialog(
            controller: titleController,
            onUpdate: () async {
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('タイトルを更新しました')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('タイトル更新に失敗しました: $e')));
                }
              }
            },
          ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder:
          (context) => ChatDetailClearDialog(
            onClear: () async {
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
          ),
    );
  }
}
