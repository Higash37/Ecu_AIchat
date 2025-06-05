import 'package:flutter/material.dart';

class NewChatDialog extends StatelessWidget {
  final TextEditingController controller;
  const NewChatDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新規チャット'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'チャットタイトル',
          hintText: '例：ChatGPTによる数学の問題解決',
        ),
        onSubmitted: (value) {
          Navigator.pop(context, value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: const Text('作成'),
        ),
      ],
    );
  }
}
