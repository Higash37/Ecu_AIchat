// models/chat.dart
class Chat {
  final String id;
  final String projectId;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessage;
  final int? messageCount;

  Chat({
    required this.id,
    required this.projectId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.messageCount,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
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
      'project_id': projectId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };

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
