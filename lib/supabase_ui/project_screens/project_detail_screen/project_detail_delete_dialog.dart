import 'package:flutter/material.dart';

class ProjectDetailDeleteDialog extends StatelessWidget {
  final VoidCallback onDelete;
  const ProjectDetailDeleteDialog({super.key, required this.onDelete});

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
          onPressed: () async {
            Navigator.pop(context);
            onDelete();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
