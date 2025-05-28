// project_detail_dialogs.dart
// プロジェクト編集・削除・新規チャット作成などのダイアログWidget

import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../models/project.dart';
import '../../../services/project_service.dart';
import 'project_detail_edit_project_dialog.dart';
import 'project_detail_delete_dialog.dart';

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

// --- ここからロジック系を追加 ---

Future<void> showEditProjectDialog({
  required BuildContext context,
  required Project project,
  required ProjectService projectService,
  required VoidCallback onUpdated,
}) async {
  showDialog(
    context: context,
    builder:
        (context) => ProjectDetailEditProjectDialog(
          project: project,
          onUpdate: (updatedProject) async {
            try {
              await projectService.updateProject(updatedProject);
              if (context.mounted) {
                onUpdated();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('プロジェクトを更新しました')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('プロジェクト更新に失敗しました: $e')));
              }
            }
          },
        ),
  );
}

Future<void> showMoreOptions({
  required BuildContext context,
  required VoidCallback onDelete,
}) async {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('プロジェクトIDをコピー'),
              onTap: () {
                Navigator.pop(context);
                // TODO: クリップボードにコピー
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プロジェクトIDをコピーしました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('プロジェクトを削除'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showDeleteConfirmation({
  required BuildContext context,
  required VoidCallback onDelete,
}) async {
  showDialog(
    context: context,
    builder: (context) => ProjectDetailDeleteDialog(onDelete: onDelete),
  );
}

Future<void> showConfirmDeleteChat({
  required BuildContext context,
  required Chat chat,
  required Future<void> Function() onDelete,
}) async {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('チャットを削除'),
          content: Text('「${chat.title}」を削除しますか？この操作は元に戻せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await onDelete();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        ),
  );
}
