// models/tag.dart
class Tag {
  final String id;
  final String projectId;
  final String label;
  final String type; // 'emotion', 'keyword', 'trait'
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.projectId,
    required this.label,
    required this.type,
    required this.createdAt,
  });

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      label: map['label'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'label': label,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
