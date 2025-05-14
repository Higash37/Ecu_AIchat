import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectService {
  final supabase = Supabase.instance.client;

  Future<List<Project>> fetchProjects() async {
    final response = await supabase.from('projects').select();

    if (response == null) throw Exception('No response from Supabase');
    if (response is! List) throw Exception('Unexpected response format');

    return response
        .map((e) => Project.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createProject(Project project) async {
    final response = await supabase.from('projects').insert(project.toMap());

    if (response == null) throw Exception('Failed to insert project');
  }
}
