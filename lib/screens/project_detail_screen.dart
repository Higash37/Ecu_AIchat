import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('説明:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(project.description ?? '説明はありません'),
          ],
        ),
      ),
    );
  }
}
