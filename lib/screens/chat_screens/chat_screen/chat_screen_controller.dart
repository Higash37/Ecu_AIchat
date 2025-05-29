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

  ChatScreenController({required this.chatId, required this.projectId});

  Future<void> init() async {
    final user = await LocalCacheService.getUserInfo();
    final userId = user?['user_id'] ?? '';
    await loadChatHistory(userId: userId);
    // _addWelcomeMessage(); ← 挨拶メッセージ呼び出しを削除
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
    messages.addAll(_pairOrder(temp));
    notifyListeners();

    // 2. API取得を試み、取得できたら差分があればmessagesを更新
    if (userId != null && userId.isNotEmpty) {
      try {
        final history = await _messageService.fetchMessagesByChat(
          chatId,
          userId,
        );
        if (history.length != cached.length ||
            !_isSameMessageList(history, cached)) {
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
          messages.addAll(_pairOrder(temp2));
          notifyListeners();
        }
      } catch (_) {
        // API失敗時はキャッシュのまま
      }
    }
  }

  // メッセージリストの内容が同じか判定（idとcontentのみ比較）
  bool _isSameMessageList(List<Message> a, List<Message> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].content != b[i].content) return false;
    }
    return true;
  }

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  String get selectedModel => _selectedModel;

  /// ストリーミングでAI応答を受信し、1文字ずつ表示
  Future<void> onSendPressed(BuildContext context, String message) async {
    if (message.trim().isEmpty) return;
    isLoading = true;
    notifyListeners();
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}\u0000?$');
    final user = await LocalCacheService.getUserInfo();
    final currentUserId = user?['user_id'] ?? '';
    final isLoggedIn = currentUserId.isNotEmpty;
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
          title: '', // タイトルは後で自動生成
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
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャット作成に失敗しました: $e')));
        return;
      }
    }
    // --- ユーザーメッセージを即時追加（末尾に追加） ---
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message,
    );
    messages.add(textMessage);
    // --- AI応答バブルを即時追加（仮テキスト付き） ---
    final aiMessageId = Uuid().v4();
    String aiText = '';
    final aiMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: aiMessageId,
      text: '...AIが応答を準備中',
    );
    messages.add(aiMessage);
    // 並び順を交互に再構成
    final ordered = _pairOrder(List<types.Message>.from(messages));
    messages
      ..clear()
      ..addAll(ordered);
    notifyListeners();

    // 1秒経ってもストリーム開始しない場合は仮テキストを維持
    bool streamStarted = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (!streamStarted) {
        final idx = messages.lastIndexWhere((m) => m.id == aiMessageId);
        if (idx != -1 &&
            messages[idx] is types.TextMessage &&
            (messages[idx] as types.TextMessage).text == '...AIが応答を準備中') {
          messages[idx] = types.TextMessage(
            author: _bot,
            createdAt: messages[idx].createdAt,
            id: aiMessageId,
            text: 'AIが応答を準備中...（ネットワーク遅延の可能性）',
          );
          notifyListeners();
        }
      }
    });

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat/stream');
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "messages": [
          {"role": "user", "content": message},
        ],
        "model": _selectedModel,
      });
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode != 200) {
        throw Exception('API error: \\${streamedResponse.statusCode}');
      }
      // SSEストリームを1行ずつ受信
      final utf8Stream = streamedResponse.stream.transform(utf8.decoder);
      streamStarted = true;
      await for (final line in utf8Stream) {
        if (line.trim().isEmpty) continue;
        if (line.trim() == 'data: [DONE]') break;
        if (line.startsWith('data:')) {
          final jsonStr = line.substring(5).trim();
          try {
            final tokenObj = jsonDecode(jsonStr);
            final token = tokenObj['token'] ?? '';
            aiText += token;
            // 最新のAIメッセージを更新（末尾を更新）
            final idx = messages.lastIndexWhere((m) => m.id == aiMessageId);
            if (idx != -1) {
              messages[idx] = types.TextMessage(
                author: _bot,
                createdAt: messages[idx].createdAt,
                id: aiMessageId,
                text: aiText.isEmpty ? '...' : aiText,
              );
              notifyListeners();
            }
          } catch (_) {}
        }
      }
      // --- 保存処理 ---
      final userMsg = Message(
        id: Uuid().v4(),
        chatId: chatId,
        sender: 'user',
        content: message,
        createdAt: DateTime.now(),
        userId: isLoggedIn ? currentUserId : null,
      );
      final aiMsg = Message(
        id: Uuid().v4(),
        chatId: chatId,
        sender: 'ai',
        content: aiText,
        createdAt: DateTime.now(),
        userId: isLoggedIn ? currentUserId : null,
      );
      if (isLoggedIn) {
        await _messageService.createMessage(userMsg, currentUserId);
        await _messageService.createMessage(aiMsg, currentUserId);
      } else {
        await LocalCacheService.cacheMessages(chatId, [userMsg, aiMsg]);
      }
    } catch (error) {
      // エラー時はAIメッセージをエラー内容で上書き
      final idx = messages.lastIndexWhere((m) => m.id == aiMessageId);
      if (idx != -1) {
        messages[idx] = types.TextMessage(
          author: _bot,
          createdAt: messages[idx].createdAt,
          id: aiMessageId,
          text: "申し訳ありません。エラーが発生しました。\nしばらく経ってからもう一度お試しください。\n\nエラー詳細: $error",
        );
        notifyListeners();
      }
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

  /// ユーザー→AI→ユーザー→AIの交互順で並べる（古い順からペアで下に追加）
  List<types.Message> _pairOrder(List<types.Message> list) {
    final List<types.Message> ordered = [];
    int i = 0;
    while (i < list.length) {
      // ユーザー
      if (list[i].author.id == _user.id) {
        ordered.add(list[i]);
        // 次がAIならペアで追加
        if (i + 1 < list.length && list[i + 1].author.id == _bot.id) {
          ordered.add(list[i + 1]);
          i += 2;
        } else {
          i++;
        }
      } else {
        // 先頭がAIの場合もそのまま追加
        ordered.add(list[i]);
        i++;
      }
    }
    return ordered;
  }
}
