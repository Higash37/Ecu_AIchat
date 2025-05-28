import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import 'package:uuid/uuid.dart';

// このファイル（project_detail_create_chat_dialog.dart）は不要になったため削除推奨

class ProjectDetailCreateChatDialog extends StatelessWidget {
  final String projectId;
  final Future<Chat?> Function(Chat chat) onCreate;

  const ProjectDetailCreateChatDialog({
    super.key,
    required this.projectId,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    return AlertDialog(
      title: const Text('新規チャット作成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'チャットタイトル',
              hintText: '例: 英語長文読解の教材作成',
            ),
            autofocus: true,
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
            final title = titleController.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('チャットタイトルを入力してください')),
              );
              return;
            }
            final chat = Chat(
              id: Uuid().v4(),
              projectId: projectId,
              title: title,
              lastMessage: '',
              createdAt: DateTime.now(),
            );
            Navigator.pop(context);
            await onCreate(chat);
          },
          child: const Text('作成'),
        ),
      ],
    );
  }
}
