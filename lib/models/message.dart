// models/message.dart
class Message {
  final String id;
  final String chatId;
  final String sender; // 'user' or 'ai'
  final String content;
  final DateTime createdAt;
  final String? userId; // 追加: ユーザー識別子

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.createdAt,
    this.userId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      chatId: map['chat_id'],
      sender: map['sender'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender': sender,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
