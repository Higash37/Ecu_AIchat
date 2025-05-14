// models/chat.dart
class Chat {
  final String id;
  final String projectId;
  final String title;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.projectId,
    required this.title,
    required this.createdAt,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      title: map['title'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
