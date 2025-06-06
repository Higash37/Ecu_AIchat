// project_list_input.dart
// 新規プロジェクト作成ダイアログWidget

import 'package:flutter/material.dart';

class ProjectListInput extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onCreate;
  const ProjectListInput({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'プロジェクト名',
            hintText: '例: 中2英語',
          ),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: '説明（任意）',
            hintText: '例: 2学期の英語授業用教材',
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
