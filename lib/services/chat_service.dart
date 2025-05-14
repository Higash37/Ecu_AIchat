import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat.dart';

class ChatService {
  final supabase = Supabase.instance.client;

  // チャット一覧の取得（プロジェクトごと）
  Future<List<Chat>> fetchChatsByProject(String projectId) async {
    final response = await supabase
        .from('chats')
        .select()
        .eq('project_id', projectId)
        .order('created_at');

    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }

  // 新しいチャットの作成
  Future<void> createChat(Chat chat) async {
    await supabase.from('chats').insert(chat.toMap());
  }
}
