class Project {
  final String? id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final int? chatCount; // チャット数を追加

  Project({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.chatCount, // コンストラクタに追加
  });
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      chatCount:
          map['chat_count'] != null ? (map['chat_count'] as num).toInt() : 0,
    );
  }
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {'name': name};

    if (description != null) {
      data['description'] = description;
    }

    // 既存プロジェクトの更新時のみIDを含める
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
