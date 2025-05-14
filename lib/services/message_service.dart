// services/message_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> createMessage(Message message) async {
    await supabase.from('messages').insert(message.toMap());
  }
}
