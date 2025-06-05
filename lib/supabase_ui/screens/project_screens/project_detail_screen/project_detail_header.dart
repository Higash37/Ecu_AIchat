// project_detail_header.dart
// プロジェクトヘッダーWidget

import 'package:flutter/material.dart';
import '../../../../app_models/models/project.dart';
import '../../../../app_styles/theme/app_theme.dart';

class ProjectDetailHeader extends StatelessWidget {
  final Project project;
  final int chatCount;
  final VoidCallback onCreateChat;
  final VoidCallback onTagManage;
  final VoidCallback onPdfGenerate;
  const ProjectDetailHeader({
    super.key,
    required this.project,
    required this.chatCount,
    required this.onCreateChat,
    required this.onTagManage,
    required this.onPdfGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: Text(
                    project.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name, style: AppTheme.heading1),
                    const SizedBox(height: 4),
                    Text(
                      project.description ?? '説明はありません',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '作成日: '
                          '${project.createdAt != null ? '${project.createdAt?.year}/${project.createdAt?.month}/${project.createdAt?.day}' : '不明'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'チャット数: $chatCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('新規チャット'),
                onPressed: onCreateChat,
              ),
              ActionChip(
                avatar: const Icon(Icons.tag_outlined, size: 16),
                label: const Text('タグ管理'),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                onPressed: onTagManage,
              ),
              ActionChip(
                avatar: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('教材生成'),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                onPressed: onPdfGenerate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
