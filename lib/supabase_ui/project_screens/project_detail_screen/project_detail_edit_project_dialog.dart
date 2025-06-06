import 'package:flutter/material.dart';
import '../../../app_models/project.dart';

class ProjectDetailEditProjectDialog extends StatelessWidget {
  final Project project;
  final Future<void> Function(Project updatedProject) onUpdate;

  const ProjectDetailEditProjectDialog({
    super.key,
    required this.project,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(
      text: project.description ?? '',
    );
    return AlertDialog(
      title: const Text('プロジェクト編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'プロジェクト名'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: '説明（任意）'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('プロジェクト名を入力してください')));
              return;
            }
            Navigator.pop(context);
            final updatedProject = Project(
              id: project.id,
              name: name,
              description: descriptionController.text.trim(),
              createdAt: project.createdAt,
              chatCount: project.chatCount,
            );
            await onUpdate(updatedProject);
          },
          child: const Text('更新'),
        ),
      ],
    );
  }
}
