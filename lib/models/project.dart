class Project {
  final String? id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  Project({this.id, required this.name, this.description, this.createdAt});

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description};
  }
}
