import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../services/message_service.dart';
import '../../../services/chat_service.dart';
import '../../../services/local_cache_service.dart';
import '../../../models/message.dart';
import '../../../models/chat.dart';
import '../../../env.dart';
import '../../../services/chat_message_manager.dart';

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
  String _selectedModel = 'gpt-4o';

  // 新しいサービスインスタンス
  late final ChatMessageManager _messageManager;

  ChatScreenController({required this.chatId, required this.projectId}) {
    _messageManager = ChatMessageManager(
      user: _user,
      bot: _bot,
      messages: messages,
    );
  }
  Future<void> init() async {
    final user = await LocalCacheService.getUserInfo();
    final userId = user?['user_id'] ?? '';
    await loadChatHistory(userId: userId);
  }

  /// チャットルームごとに履歴を自動ロード（ローカルキャッシュ即時反映→API取得後差し替え）
  Future<void> loadChatHistory({String? userId}) async {
    // 1. まずローカルキャッシュを即時反映
    messages.clear();
    List<Message> cached = await LocalCacheService.getCachedMessages(chatId);
    List<types.Message> temp = [];
    for (final msg in cached) {
      temp.add(
        types.TextMessage(
          author: msg.sender == 'user' ? _user : _bot,
          createdAt: msg.createdAt.millisecondsSinceEpoch,
          id: msg.id,
          text: msg.content,
        ),
      );
    }
    messages.addAll(_messageManager.getPairedMessages());
    notifyListeners();

    // 2. API取得を試み、取得できたら差分があればmessagesを更新
    if (userId != null && userId.isNotEmpty) {
      try {
        final history = await _messageService.fetchMessagesByChat(
          chatId,
          userId,
        );
        if (history.length != cached.length ||
            !_messageManager.isSameMessageList(history, cached)) {
          messages.clear();
          List<types.Message> temp2 = [];
          for (final msg in history) {
            temp2.add(
              types.TextMessage(
                author: msg.sender == 'user' ? _user : _bot,
                createdAt: msg.createdAt.millisecondsSinceEpoch,
                id: msg.id,
                text: msg.content,
              ),
            );
          }
          messages.addAll(_messageManager.getPairedMessages());
          notifyListeners();
        }
      } catch (_) {
        // API失敗時はキャッシュのまま
      }
    }
  }

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  String get selectedModel => _selectedModel;

  /// チャットメッセージ送信処理
  Future<void> onSendPressed(BuildContext context, String message) async {
    if (message.trim().isEmpty) return;
    isLoading = true;
    notifyListeners();

    // チャット存在確認・作成
    if (!await _ensureChatExists(context)) return;

    // --- ユーザーメッセージを即時追加 ---
    _messageManager.addUserMessage(message);

    // --- AI応答バブルを即時追加（仮テキスト付き） ---
    final aiMessageId = _messageManager.addAiPendingMessage();

    // 並び順を交互に再構成
    final ordered = _messageManager.getPairedMessages();
    messages
      ..clear()
      ..addAll(ordered);
    notifyListeners();

    try {
      // --- OpenAI APIでAI応答を取得 ---
      final response = await _sendChatRequest(message);
      final aiText = response['reply'] ?? '';

      // --- AI応答を更新 ---
      _messageManager.updateAiMessage(aiMessageId, aiText);
      notifyListeners();

      // --- ユーザー情報取得 ---
      final user = await LocalCacheService.getUserInfo();
      final currentUserId = user?['user_id'] ?? '';
      final isLoggedIn = currentUserId.isNotEmpty;

      // --- メッセージを保存 ---
      await _saveMessages(message, aiText, currentUserId, isLoggedIn);
    } catch (error) {
      // エラー時はAIメッセージをエラー内容で上書き
      _messageManager.updateAiMessageWithError(aiMessageId, error);
      notifyListeners();
    }

    isLoading = false;
    notifyListeners();
    // AI応答が追加された直後にハプティック
    HapticFeedback.mediumImpact();
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  /// AI応答生成のキャンセル（UIのみ、実際のストリーム中断は今後対応）
  void cancelGeneration() {
    isLoading = false;
    notifyListeners();
  }

  /// 最後のユーザーメッセージで再生成（UIのみ、実際のAPI再送信は今後対応）
  Future<void> regenerateLastMessage(BuildContext context) async {
    if (messages.isEmpty) return;
    // 最後のユーザーメッセージを再送信
    types.Message? lastUserMsg;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].author.id == user.id &&
          messages[i] is types.TextMessage) {
        lastUserMsg = messages[i];
        break;
      }
    }
    if (lastUserMsg != null && lastUserMsg is types.TextMessage) {
      await onSendPressed(context, lastUserMsg.text);
    }
  }

  // チャットが存在しなければ作成
  Future<bool> _ensureChatExists(BuildContext context) async {
    if (chatCreated) return true;
    final user = await LocalCacheService.getUserInfo();
    final currentUserId = user?['user_id'] ?? '';
    final isLoggedIn = currentUserId.isNotEmpty;
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}\u0000?$');
    if (projectId.isNotEmpty && !uuidRegExp.hasMatch(projectId)) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロジェクトIDが不正です。管理者にご連絡ください。')),
      );
      return false;
    }
    try {
      final chat = Chat(
        id: chatId,
        projectId: projectId,
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastMessage: '',
        messageCount: 0,
        userId: isLoggedIn ? currentUserId : null,
      );
      if (isLoggedIn) {
        await _chatService.createChat(chat, currentUserId);
      } else {
        await LocalCacheService.cacheChats([chat]);
      }
      chatCreated = true;
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('チャット作成に失敗しました: $e')));
      return false;
    }
  }

  // OpenAI APIへリクエスト
  Future<Map<String, dynamic>> _sendChatRequest(String message) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": message},
        ],
        "model": _selectedModel,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  // メッセージ保存
  Future<void> _saveMessages(
    String userMsg,
    String aiMsg, [
    String? userId,
    bool isLoggedIn = false,
  ]) async {
    final userMessage = Message(
      id: const Uuid().v4(),
      chatId: chatId,
      sender: 'user',
      content: userMsg,
      createdAt: DateTime.now(),
      userId: isLoggedIn ? userId : null,
    );
    final aiMessage = Message(
      id: const Uuid().v4(),
      chatId: chatId,
      sender: 'ai',
      content: aiMsg,
      createdAt: DateTime.now(),
      userId: isLoggedIn ? userId : null,
    );
    if (isLoggedIn && userId != null) {
      await _messageService.createMessage(userMessage, userId);
      await _messageService.createMessage(aiMessage, userId);
    } else {
      await LocalCacheService.cacheMessages(chatId, [userMessage, aiMessage]);
    }
  }
}
