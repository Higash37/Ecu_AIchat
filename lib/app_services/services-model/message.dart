import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String chatId;
  @HiveField(2)
  final String sender; // 'user' or 'ai'
  @HiveField(3)
  final String content;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String? userId; // ユーザー識別子
  @HiveField(6)
  final String? emotion; // AI感情ラベル

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.createdAt,
    this.userId,
    this.emotion,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      chatId: map['chat_id'],
      sender: map['sender'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
      emotion: map['emotion'],
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
      'emotion': emotion,
    };
  }
}
