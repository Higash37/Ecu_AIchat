// project_list_item.dart
// プロジェクトリストの1件分Widget

import 'package:flutter/material.dart';
import '../../../app_models/project.dart';
import '../../../app_styles/app_theme.dart';

class ProjectListItem extends StatelessWidget {
  final Project project;
  final bool forSelection;
  final void Function()? onTap;
  const ProjectListItem({
    super.key,
    required this.project,
    this.forSelection = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              project.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            project.name,
            style: AppTheme.heading2.copyWith(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                project.description ?? '（説明なし）',
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '作成日: '
                    '${project.createdAt != null ? '${project.createdAt?.year}/${project.createdAt?.month}/${project.createdAt?.day}' : '不明'}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 12,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'チャット数: ${project.chatCount ?? 0}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.primaryColor,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
