import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../app_services/services-model/message.dart';

/// チャットメッセージを管理するユーティリティクラス
class ChatMessageManager {
  final types.User user;
  final types.User bot;
  final List<types.Message> messages;

  ChatMessageManager({
    required this.user,
    required this.bot,
    required this.messages,
  });

  /// ユーザーメッセージを追加
  types.TextMessage addUserMessage(String content) {
    final message = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: content,
    );
    messages.add(message);
    return message;
  }

  /// AI応答の仮メッセージを追加し、IDを返す
  String addAiPendingMessage() {
    final messageId = const Uuid().v4();
    final message = types.TextMessage(
      author: bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: messageId,
      text: 'AIが応答を考えています...', // 仮テキスト
    );
    messages.add(message);
    return messageId;
  }

  /// AIメッセージを更新
  void updateAiMessage(String messageId, String content) {
    final idx = messages.lastIndexWhere((m) => m.id == messageId);
    if (idx != -1) {
      messages[idx] = types.TextMessage(
        author: bot,
        createdAt: messages[idx].createdAt,
        id: messageId,
        text: content.isEmpty ? 'AI応答が取得できませんでした' : content,
      );
    }
  }

  /// AIメッセージをエラーメッセージに更新
  void updateAiMessageWithError(String messageId, Object error) {
    final idx = messages.lastIndexWhere((m) => m.id == messageId);
    if (idx != -1) {
      messages[idx] = types.TextMessage(
        author: bot,
        createdAt: messages[idx].createdAt,
        id: messageId,
        text: "申し訳ありません。エラーが発生しました。\nしばらく経ってからもう一度お試しください。\n\nエラー詳細: $error",
      );
    }
  }

  /// メッセージを交互順に並び替え
  List<types.Message> getPairedMessages() {
    return _pairOrder(List<types.Message>.from(messages));
  }

  /// 全メッセージをクリア
  void clearAllMessages() {
    messages.clear();
  }

  /// モデルメッセージリストとビューメッセージリストの比較
  bool isSameMessageList(List<Message> a, List<Message> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].content != b[i].content) return false;
    }
    return true;
  }

  /// ビューメッセージからモデルメッセージへの変換
  Message createModelMessage({
    required String id,
    required String chatId,
    required String content,
    required bool isUser,
    String? userId,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      sender: isUser ? 'user' : 'ai',
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
    );
  }

  /// 最後のユーザーメッセージを取得
  types.TextMessage? getLastUserMessage() {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].author.id == user.id &&
          messages[i] is types.TextMessage) {
        return messages[i] as types.TextMessage;
      }
    }
    return null;
  }

  /// ユーザー→AI→ユーザー→AIの交互順で並べる（古い順からペアで下に追加）
  List<types.Message> _pairOrder(List<types.Message> list) {
    final List<types.Message> ordered = [];
    int i = 0;
    while (i < list.length) {
      // ユーザー
      if (list[i].author.id == user.id) {
        ordered.add(list[i]);
        // 次がAIならペアで追加
        if (i + 1 < list.length && list[i + 1].author.id == bot.id) {
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
