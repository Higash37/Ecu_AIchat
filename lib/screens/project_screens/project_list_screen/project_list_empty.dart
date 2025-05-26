// project_list_empty.dart
// プロジェクトが空のときの表示Widget

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProjectListEmpty extends StatelessWidget {
  final bool forSelection;
  final String? selectionPurpose;
  const ProjectListEmpty({
    super.key,
    this.forSelection = false,
    this.selectionPurpose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'プロジェクトがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            forSelection ? '現在利用可能なプロジェクトがありません' : '右下の+ボタンから新しいプロジェクトを作成できます',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!forSelection)
            ElevatedButton(
              onPressed: () {}, // 呼び出し元でonPressedを指定
              style: AppTheme.primaryButton,
              child: const Text('新規プロジェクト作成'),
            ),
        ],
      ),
    );
  }
}
