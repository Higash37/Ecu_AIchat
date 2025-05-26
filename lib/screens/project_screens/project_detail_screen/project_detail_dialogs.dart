// project_detail_dialogs.dart
// プロジェクト編集・削除・新規チャット作成などのダイアログWidget

import 'package:flutter/material.dart';

class EditProjectDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onUpdate;
  const EditProjectDialog({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
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
        ElevatedButton(onPressed: onUpdate, child: const Text('更新')),
      ],
    );
  }
}

class DeleteProjectDialog extends StatelessWidget {
  final VoidCallback onDelete;
  const DeleteProjectDialog({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロジェクトを削除'),
      content: const Text('このプロジェクトに関連するすべてのチャットとメッセージも削除されます。この操作は取り消せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
