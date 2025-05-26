import 'package:flutter/material.dart';

class ChatMessageActionButtons extends StatelessWidget {
  final void Function()? onRegenerate;
  final void Function()? onRequest;
  final void Function()? onCopy;
  const ChatMessageActionButtons({
    super.key,
    this.onRegenerate,
    this.onRequest,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context,
          Icons.refresh,
          '再生成',
          onPressed: onRegenerate,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          context,
          Icons.edit_note,
          '要望追加',
          onPressed: onRequest,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          context,
          Icons.content_copy,
          'コピー',
          onPressed: onCopy,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    void Function()? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
