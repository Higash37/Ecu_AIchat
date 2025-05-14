import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _service = ProjectService();
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _service.fetchProjects();
    setState(() {
      _projects = projects;
    });
  }

  void _addProject() async {
    final newProject = Project(
      name: "新規プロジェクト",
      description: "説明",
      createdAt: DateTime.now(),
    );
    await _service.createProject(newProject);
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロジェクト一覧')),
      body: ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return ListTile(
            title: Text(project.name),
            subtitle: Text(project.description ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
