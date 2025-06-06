import 'package:flutter/material.dart';
import '../../../app_services/services-model/chat.dart';

class DeleteChatDialog extends StatelessWidget {
  final Chat chat;
  final VoidCallback onDelete;
  const DeleteChatDialog({
    super.key,
    required this.chat,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('チャットを削除'),
      content: Text('「${chat.title}」を削除しますか？この操作は元に戻せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
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
