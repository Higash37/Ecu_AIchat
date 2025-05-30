import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectService {
  final supabase = Supabase.instance.client;

  Future<List<Project>> fetchProjects() async {
    final response = await supabase.from('projects').select();

    return (response as List)
        .map((e) => Project.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createProject(Project project) async {
    final response = await supabase.from('projects').insert(project.toMap());
    if (response == null) throw Exception('Failed to insert project');
  }

  Future<void> updateProject(Project project) async {
    if (project.id == null) {
      throw Exception('プロジェクトIDが指定されていません');
    }

    final response = await supabase
        .from('projects')
        .update(project.toMap())
        .eq('id', project.id ?? ''); // project.idはnullでないので!で明示

    if (response == null) throw Exception('プロジェクトの更新に失敗しました');
  }

  Future<void> deleteProject(String projectId) async {
    final response = await supabase
        .from('projects')
        .delete()
        .eq('id', projectId);

    if (response == null) throw Exception('プロジェクトの削除に失敗しました');
  }
}
