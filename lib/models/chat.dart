import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 0)
class Chat {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? projectId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final DateTime? updatedAt;
  @HiveField(5)
  final String? lastMessage;
  @HiveField(6)
  final int? messageCount;

  Chat({
    required this.id,
    this.projectId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.messageCount,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      projectId: map['project_id'],
      title: map['title'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      lastMessage: map['last_message'],
      messageCount:
          map['message_count'] != null
              ? (map['message_count'] as num).toInt()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
    if (projectId != null && projectId!.isNotEmpty) {
      result['project_id'] = projectId;
    }
    if (updatedAt != null) {
      result['updated_at'] = updatedAt!.toIso8601String();
    }
    if (lastMessage != null) {
      result['last_message'] = lastMessage;
    }
    if (messageCount != null) {
      result['message_count'] = messageCount;
    }
    return result;
  }
}
