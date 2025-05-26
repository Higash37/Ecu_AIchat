import 'package:flutter/material.dart';

class ChatDetailClearDialog extends StatelessWidget {
  final VoidCallback onClear;
  const ChatDetailClearDialog({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('チャット履歴をクリア'),
      content: const Text('すべてのメッセージが削除されます。この操作は取り消せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: onClear,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: const Text('クリア'),
        ),
      ],
    );
  }
}
