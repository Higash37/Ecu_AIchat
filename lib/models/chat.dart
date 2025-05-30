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
  @HiveField(7)
  final String? userId;

  Chat({
    required this.id,
    this.projectId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.messageCount,
    this.userId,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['created_at'];
    DateTime createdAtSafe;
    if (createdAtRaw == null ||
        (createdAtRaw is String && createdAtRaw.isEmpty)) {
      createdAtSafe = DateTime.now();
    } else if (createdAtRaw is DateTime) {
      createdAtSafe = createdAtRaw;
    } else {
      try {
        createdAtSafe = DateTime.parse(createdAtRaw.toString());
      } catch (_) {
        createdAtSafe = DateTime.now();
      }
    }
    return Chat(
      id: map['id']?.toString() ?? '',
      projectId: map['project_id']?.toString(),
      title: map['title']?.toString() ?? '',
      createdAt: createdAtSafe,
      updatedAt:
          map['updated_at'] != null && map['updated_at'].toString().isNotEmpty
              ? DateTime.tryParse(map['updated_at'].toString())
              : null,
      lastMessage: map['last_message']?.toString(),
      messageCount:
          map['message_count'] != null
              ? (map['message_count'] as num?)?.toInt()
              : null,
      userId: map['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
    // projectIdのnull安全化
    if ((projectId ?? '').isNotEmpty) {
      result['project_id'] = projectId;
    }
    if (updatedAt != null) {
      result['updated_at'] = updatedAt?.toIso8601String();
    }
    if (lastMessage != null) {
      result['last_message'] = lastMessage;
    }
    if (messageCount != null) {
      result['message_count'] = messageCount;
    }
    if (userId != null) {
      result['user_id'] = userId;
    }
    return result;
  }
}
