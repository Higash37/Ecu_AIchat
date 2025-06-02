import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:characters/characters.dart';
import '../../../models/chat.dart';
import '../../../models/message.dart' as app_models;
import '../../../services/chat_service.dart';
import '../../../services/message_service.dart';
import '../../../services/local_cache_service.dart';
import '../../../env.dart';

/// ChatDetailScreenのロジック・状態管理用コントローラー
class ChatDetailController extends ChangeNotifier {
  final String chatId;
  final ChatService _chatService = ChatService();
  final MessageService _messageService = MessageService();
  final types.User user = const types.User(id: 'user');
  final types.User bot = const types.User(id: 'ai');
  final List<types.Message> messages = [];
  Chat? chat;
  bool isLoading = true;
  bool isSending = false;

  ChatDetailController({required this.chatId, Chat? initialChat}) {
    if (initialChat != null) {
      chat = initialChat;
      _loadMessages();
    } else {
      _loadChat();
    }
  }

  Future<void> _loadChat() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = await LocalCacheService.getUserInfo();
      final userId = user?['user_id'];
      final c =
          userId != null
              ? await _chatService.fetchChatById(chatId, userId)
              : await _chatService.fetchChatById(chatId, '');
      chat = c;
      await _loadMessages();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadMessages() async {
    try {
      final user = await LocalCacheService.getUserInfo();
      final userId = user?['user_id'];
      final fetched =
          userId != null
              ? await _messageService.fetchMessagesByChat(chatId, userId)
              : await _messageService.fetchMessagesByChat(chatId, '');
      // 通信成功時はキャッシュ保存
      await LocalCacheService.cacheMessages(chatId, fetched);
      final mapped =
          fetched.map((m) {
            final isUser = m.sender == 'user';
            // ignore: unnecessary_this
            return types.TextMessage(
              author: isUser ? this.user : this.bot,
              id: m.id,
              text: m.content,
              createdAt: m.createdAt.millisecondsSinceEpoch,
            );
          }).toList();
      messages.clear();
      messages.addAll(mapped);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      // 通信失敗時はキャッシュから取得
      final cached = await LocalCacheService.getCachedMessages(chatId);
      if (cached.isNotEmpty) {
        final mapped =
            cached.map((m) {
              final isUser = m.sender == 'user';
              return types.TextMessage(
                author: isUser ? user : bot,
                id: m.id,
                text: m.content,
                createdAt: m.createdAt.millisecondsSinceEpoch,
              );
            }).toList();
        messages.clear();
        messages.addAll(mapped);
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message,
    );
    messages.insert(0, textMessage);
    isSending = true;
    notifyListeners();
    try {
      final userInfo = await LocalCacheService.getUserInfo();
      final currentUserId = userInfo?['user_id'];
      if (currentUserId == null) {
        // 未ログイン時はローカルキャッシュのみ保存
        final localMsg = app_models.Message(
          id: const Uuid().v4(),
          chatId: chatId,
          sender: 'user',
          content: message,
          createdAt: DateTime.now(),
          userId: null,
          emotion: null,
        );
        await LocalCacheService.cacheMessages(chatId, [localMsg]);
        // AI返信もローカル保存
        // --- ストリーム風表示（マルチバイト対応） ---
        final aiRes = await _fetchAIResponseWithEmotion(message, '');
        String aiReply = aiRes['reply'] ?? '';
        String aiEmotion = aiRes['emotion'] ?? 'ニュートラル';
        String display = '';
        final aiMsgId = const Uuid().v4();
        final aiMessage = types.TextMessage(
          author: bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiMsgId,
          text: '',
          metadata: {'emotion': aiEmotion},
        );
        messages.insert(0, aiMessage);
        notifyListeners();
        for (final char in aiReply.characters) {
          display += char;
          messages[0] =
              (aiMessage.copyWith(text: display) as types.TextMessage);
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 12));
        }
        // 完了時にローカル保存
        final aiMsg = app_models.Message(
          id: aiMsgId,
          chatId: chatId,
          sender: 'ai',
          content: aiReply,
          createdAt: DateTime.now(),
          userId: null,
          emotion: aiEmotion,
        );
        await LocalCacheService.cacheMessages(chatId, [localMsg, aiMsg]);
        isSending = false;
        notifyListeners();
        return;
      }
      // ログイン時はサーバーにメッセージを保存
      final aiRes = await _fetchAIResponseWithEmotion(message, currentUserId);
      String aiReply = aiRes['reply'] ?? '';
      String aiEmotion = aiRes['emotion'] ?? 'ニュートラル';
      String display = '';
      final aiMsgId = const Uuid().v4();
      final aiMessage = types.TextMessage(
        author: bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: aiMsgId,
        text: '',
        metadata: {'emotion': aiEmotion},
      );
      messages.insert(0, aiMessage);
      notifyListeners();
      for (final char in aiReply.characters) {
        display += char;
        messages[0] = (aiMessage.copyWith(text: display) as types.TextMessage);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 12));
      }
      await _messageService.saveAIMessage(
        chatId: chatId,
        content: aiReply,
        userId: currentUserId,
        emotion: aiEmotion,
      );
      isSending = false;
      notifyListeners();
    } catch (e) {
      isSending = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchAIResponseWithEmotion(
    String userInput,
    String userId,
  ) async {
    final history = await _messageService.fetchMessagesByChat(chatId, userId);
    final messagesForAI =
        history
            .map(
              (m) => {
                'role': m.sender == 'user' ? 'user' : 'assistant',
                'content': m.content,
              },
            )
            .toList();
    messagesForAI.add({'role': 'user', 'content': userInput});
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"messages": messagesForAI}),
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    return {
      'reply': json['reply'] ?? '',
      'emotion': json['emotion'] ?? 'ニュートラル',
    };
  }

  Future<void> reload() async {
    await _loadChat();
  }

  Future<void> updateTitle(String title) async {
    if (chat == null) return;
    await _chatService.updateChatTitle(chatId, title);
    chat = Chat(
      id: chat?.id ?? '',
      projectId: chat?.projectId,
      title: title,
      createdAt: chat?.createdAt ?? DateTime.now(),
      updatedAt: chat?.updatedAt,
      lastMessage: chat?.lastMessage,
      messageCount: chat?.messageCount,
      userId: chat?.userId,
    );
    notifyListeners();
  }

  Future<void> clearMessages() async {
    // TODO: メッセージクリア機能実装
    // await _messageService.deleteAllMessages(chatId);
    messages.clear();
    notifyListeners();
  }

  Future<void> initializeChatTitle(String initialMessage) async {
    if (chat == null) return;
    try {
      final title = await _chatService.generateChatTitle(
        chatId,
        initialMessage,
      );
      await _chatService.updateChatTitle(chatId, title);
      chat = Chat(
        id: chat?.id ?? '',
        projectId: chat?.projectId,
        title: title,
        createdAt: chat?.createdAt ?? DateTime.now(),
        updatedAt: chat?.updatedAt,
        lastMessage: chat?.lastMessage,
        messageCount: chat?.messageCount,
        userId: chat?.userId,
      );
    } catch (e) {
      print('タイトル生成に失敗しました: $e');
    }
  }
}
