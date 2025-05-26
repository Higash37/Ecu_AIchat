// project_detail_empty.dart
// チャットが空のときの表示Widget

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProjectDetailEmpty extends StatelessWidget {
  final VoidCallback onCreateChat;
  const ProjectDetailEmpty({super.key, required this.onCreateChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'チャットがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '右下の+ボタンから新規チャットを作成しましょう',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreateChat,
            style: AppTheme.primaryButton,
            child: const Text('新規チャット作成'),
          ),
        ],
      ),
    );
  }
}
