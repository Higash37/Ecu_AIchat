import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/message_service.dart';
import '../../../services/chat_service.dart';
import '../../../models/message.dart';
import '../../../models/chat.dart';
import '../../../env.dart';

/// ChatScreenのロジック・状態管理用コントローラー
class ChatScreenController extends ChangeNotifier {
  final String chatId;
  final String projectId;
  final List<types.Message> messages = [];
  final types.User _user = const types.User(id: 'user');
  final types.User _bot = const types.User(id: 'ai');
  types.User get user => _user;
  types.User get bot => _bot;
  bool isLoading = false;
  final MessageService _messageService = MessageService();
  final ChatService _chatService = ChatService();
  bool chatCreated = false;

  ChatScreenController({required this.chatId, required this.projectId}) {
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
    messages.insert(0, welcomeMessage);
    notifyListeners();
  }

  Future<void> onSendPressed(BuildContext context, String message) async {
    if (message.trim().isEmpty) return;
    isLoading = true;
    notifyListeners();
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}\u0000?$');
    if (!chatCreated) {
      if (projectId.isNotEmpty && !uuidRegExp.hasMatch(projectId)) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロジェクトIDが不正です。管理者にご連絡ください。')),
        );
        return;
      }
      try {
        final chat = Chat(
          id: chatId,
          projectId: projectId,
          title: '新規チャット',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastMessage: '',
          messageCount: 0,
        );
        await _chatService.createChat(chat);
        chatCreated = true;
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャット作成に失敗しました: $e')));
        return;
      }
    }
    String aiReply = '';
    try {
      aiReply = await _fetchAIResponse(message);
    } catch (error) {
      final errorMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: "申し訳ありません。エラーが発生しました。\nしばらく経ってからもう一度お試しください。\n\nエラー詳細: $error",
      );
      messages.insert(0, errorMessage);
      isLoading = false;
      notifyListeners();
      return;
    }
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    await _messageService.createMessage(
      Message(
        id: Uuid().v4(),
        chatId: chatId,
        sender: 'user',
        content: message,
        createdAt: DateTime.now(),
        userId: currentUserId,
      ),
    );
    await _messageService.createMessage(
      Message(
        id: Uuid().v4(),
        chatId: chatId,
        sender: 'ai',
        content: aiReply,
        createdAt: DateTime.now(),
        userId: null,
      ),
    );
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message,
    );
    final aiMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: aiReply,
    );
    messages.insert(0, aiMessage);
    messages.insert(0, textMessage);
    isLoading = false;
    notifyListeners();
  }

  Future<String> _fetchAIResponse(String text) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat');
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

  void clearMessages() {
    messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }
}
