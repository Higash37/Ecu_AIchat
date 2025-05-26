import 'package:flutter/material.dart';

class ChatDetailEditTitleDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onUpdate;
  const ChatDetailEditTitleDialog({
    super.key,
    required this.controller,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('チャットタイトル変更'),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'タイトル',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: onUpdate, child: const Text('更新')),
      ],
    );
  }
}
