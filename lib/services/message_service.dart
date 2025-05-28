// services/message_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class MessageService {
  final supabase = Supabase.instance.client;

  Future<List<Message>> fetchMessagesByChat(
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

  Future<void> createMessage(Message message, String userId) async {
    final msgMap = message.toMap();
    msgMap['user_id'] = userId;
    await supabase.from('messages').insert(msgMap);
  }

  Future<void> createMessageForNewChat(
    String chatId,
    String sender,
    String content,
    String userId,
  ) async {
    final message = Message(
      id: Uuid().v4(),
      chatId: chatId,
      sender: sender,
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
    );
    await createMessage(message, userId);
  }

  Future<void> saveAIMessage({
    required String chatId,
    required String content,
    required String userId,
    required String emotion,
  }) async {
    final message = Message(
      id: Uuid().v4(),
      chatId: chatId,
      sender: 'ai',
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
      emotion: emotion,
    );
    await createMessage(message, userId);
  }
}
