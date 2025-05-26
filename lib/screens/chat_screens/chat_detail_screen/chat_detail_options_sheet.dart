import 'package:flutter/material.dart';

class ChatDetailOptionsSheet extends StatelessWidget {
  final VoidCallback onEditTitle;
  final VoidCallback onSavePdf;
  final VoidCallback onClear;
  const ChatDetailOptionsSheet({
    super.key,
    required this.onEditTitle,
    required this.onSavePdf,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.title),
            title: const Text('タイトル変更'),
            onTap: () {
              Navigator.pop(context);
              onEditTitle();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDFとして保存'),
            onTap: () {
              Navigator.pop(context);
              onSavePdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('チャット履歴をクリア'),
            onTap: () {
              Navigator.pop(context);
              onClear();
            },
          ),
        ],
      ),
    );
  }
}
