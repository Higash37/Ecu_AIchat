// services/message_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class MessageService {
  final supabase = Supabase.instance.client;

  Future<List<Message>> fetchMessagesByChat(String chatId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');

    return (response as List).map((e) => Message.fromMap(e)).toList();
  }

  Future<List<Message>> fetchMessagesByChatAndUser(
    String chatId,
    String userId,
  ) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('user_id', userId)
        .order('created_at');
    return (response as List).map((e) => Message.fromMap(e)).toList();
  }

  Future<void> createMessage(Message message) async {
    await supabase.from('messages').insert(message.toMap());
  }

  Future<void> createMessageForNewChat(
    String chatId,
    String sender,
    String content,
  ) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final message = Message(
      id: Uuid().v4(),
      chatId: chatId,
      sender: sender,
      content: content,
      createdAt: DateTime.now(),
      userId: currentUserId, // ログインユーザーIDをセット
    );
    await createMessage(message);
  }
}
