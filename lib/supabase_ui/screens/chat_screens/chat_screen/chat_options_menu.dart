import 'package:flutter/material.dart';
import 'chat_screen_controller.dart';

/// チャットオプションメニュー
class ChatOptionsMenu {
  static void showOptionsMenu(
    BuildContext context,
    ChatScreenController? controller,
  ) {
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
                leading: const Icon(Icons.save),
                title: const Text('チャットを保存'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('チャット保存機能は準備中です')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDFとして保存'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF生成機能は準備中です')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('チャット履歴をクリア'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmation(context, controller);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showClearConfirmation(
    BuildContext context,
    ChatScreenController? controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('チャット履歴をクリア'),
            content: const Text('すべてのメッセージが削除されます。この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller?.clearMessages();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('クリア'),
              ),
            ],
          ),
    );
  }
}
