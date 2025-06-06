import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services-model/chat.dart';

class ChatService {
  final supabase = Supabase.instance.client;
  // すべてのチャット一覧の取得（ユーザーごと）
  Future<List<Chat>> fetchAllChats(String userId) async {
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}');
    if (userId.isEmpty || !uuidRegExp.hasMatch(userId)) {
      print('[fetchAllChats] userIdがUUIDでない、または空です。user_id条件を外して取得します');
      final response = await supabase
          .from('chats')
          .select()
          .order('updated_at', ascending: false);
      return (response as List).map((e) => Chat.fromMap(e)).toList();
    }
    final response = await supabase
        .from('chats')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }

  // チャット一覧の取得（プロジェクトごと・ユーザーごと）
  Future<List<Chat>> fetchChatsByProjectId(
    String projectId,
    String userId,
  ) async {
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}');
    if (userId.isEmpty || !uuidRegExp.hasMatch(userId)) {
      print('[fetchChatsByProjectId] userIdがUUIDでない、または空です。user_id条件を外して取得します');
      final response = await supabase
          .from('chats')
          .select()
          .eq('project_id', projectId)
          .order('updated_at', ascending: false);
      return (response as List).map((e) => Chat.fromMap(e)).toList();
    }
    final response = await supabase
        .from('chats')
        .select()
        .eq('project_id', projectId)
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }

  // チャット一覧の取得（エイリアスメソッド）
  Future<List<Chat>> fetchChatsByProject(
    String projectId,
    String userId,
  ) async {
    return fetchChatsByProjectId(projectId, userId);
  }

  // チャットの取得（ID指定・ユーザーごと）
  Future<Chat> fetchChatById(String id, String userId) async {
    final uuidRegExp = RegExp(r'^[0-9a-fA-F\-]{36}');
    if (userId.isEmpty || !uuidRegExp.hasMatch(userId)) {
      print('[fetchChatById] userIdがUUIDでない、または空です。user_id条件を外して取得します');
      final response =
          await supabase.from('chats').select().eq('id', id).single();
      return Chat.fromMap(response);
    }
    final response =
        await supabase
            .from('chats')
            .select()
            .eq('id', id)
            .eq('user_id', userId)
            .single();
    return Chat.fromMap(response);
  }

  // チャットの存在確認
  Future<bool> checkIfChatExists(String chatId, String userId) async {
    try {
      final response =
          await supabase
              .from('chats')
              .select('id')
              .eq('id', chatId)
              .eq('user_id', userId)
              .maybeSingle();
      return response != null;
    } catch (e) {
      print('チャット存在確認エラー: $e');
      return false;
    }
  }

  // 新しいチャットの作成（ユーザーごと）
  Future<Chat> createChat(Chat chat, String userId) async {
    // 既存のチャットをチェック
    final exists = await checkIfChatExists(chat.id, userId);
    if (exists) {
      print('チャットが既に存在します: ${chat.id}');
      return await fetchChatById(chat.id, userId);
    }

    final chatMap = chat.toMap();
    chatMap['user_id'] = userId;
    final response =
        await supabase.from('chats').insert(chatMap).select().single();

    return Chat.fromMap(response);
  }

  // 最終メッセージの更新
  Future<void> updateLastMessage(String chatId, String message) async {
    await supabase
        .from('chats')
        .update({
          'last_message': message,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', chatId);
  }

  // メッセージカウントの更新
  Future<void> incrementMessageCount(String chatId) async {
    // 現在のメッセージ数を取得
    final response =
        await supabase
            .from('chats')
            .select('message_count')
            .eq('id', chatId)
            .single();

    final currentCount = response['message_count'] as int? ?? 0;

    // インクリメント
    await supabase
        .from('chats')
        .update({
          'message_count': currentCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', chatId);
  }

  // チャットタイトルの更新
  Future<void> updateChatTitle(String chatId, String title) async {
    await supabase
        .from('chats')
        .update({
          'title': title,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', chatId);
  }

  // チャットの削除
  Future<void> deleteChat(String chatId) async {
    await supabase.from('chats').delete().eq('id', chatId);
  }
}
