import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _projectService = ProjectService();
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _projectService.fetchProjects();
    setState(() {
      _projects = projects;
    });
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
            subtitle: Text(project.description ?? '（説明なし）'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailScreen(project: project),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
