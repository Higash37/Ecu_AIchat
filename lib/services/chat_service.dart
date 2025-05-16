import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat.dart';

class ChatService {
  final supabase = Supabase.instance.client;
  // すべてのチャット一覧の取得
  Future<List<Chat>> fetchAllChats() async {
    final response = await supabase
        .from('chats')
        .select()
        .order('updated_at', ascending: false);

    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }

  // チャット一覧の取得（プロジェクトごと）
  Future<List<Chat>> fetchChatsByProjectId(String projectId) async {
    final response = await supabase
        .from('chats')
        .select()
        .eq('project_id', projectId)
        .order('updated_at', ascending: false);

    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }

  // チャット一覧の取得（エイリアスメソッド）
  Future<List<Chat>> fetchChatsByProject(String projectId) async {
    return fetchChatsByProjectId(projectId);
  }

  // チャットの取得（ID指定）
  Future<Chat> fetchChatById(String id) async {
    final response =
        await supabase.from('chats').select().eq('id', id).single();

    return Chat.fromMap(response);
  }

  // 新しいチャットの作成
  Future<Chat> createChat(Chat chat) async {
    final response =
        await supabase.from('chats').insert(chat.toMap()).select().single();

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
