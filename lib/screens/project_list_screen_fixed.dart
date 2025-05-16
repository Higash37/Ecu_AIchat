import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  final bool forSelection;
  final String? selectionPurpose;
  final String? navigationMode;

  const ProjectListScreen({
    super.key,
    this.forSelection = false,
    this.selectionPurpose,
    this.navigationMode,
  });

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await _projectService.fetchProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('プロジェクトの読み込みに失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.forSelection
            ? '${widget.selectionPurpose ?? "選択"}するプロジェクトを選択'
            : 'プロジェクト一覧';

    return AppScaffold(
      title: title,
      currentNavIndex: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _projects.isEmpty
              ? _buildEmptyState()
              : _buildProjectList(),
      floatingActionButton:
          widget.forSelection
              ? null
              : FloatingActionButton(
                backgroundColor: AppTheme.primaryColor,
                onPressed: () => _showCreateProjectDialog(context),
                child: const Icon(Icons.add),
              ),
    );
  }

  Widget _buildEmptyState() {
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
            widget.forSelection
                ? '現在利用可能なプロジェクトがありません'
                : '右下の+ボタンから新しいプロジェクトを作成できます',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!widget.forSelection)
            ElevatedButton(
              onPressed: () {
                _showCreateProjectDialog(context);
              },
              style: AppTheme.primaryButton,
              child: const Text('新規プロジェクト作成'),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
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
                        '作成日: ${_formatDate(project.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryColor,
              ),
              onTap: () {
                if (widget.forSelection) {
                  Navigator.pop(context, project);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProjectDetailScreen(project: project),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '不明';
    return '${date.year}/${date.month}/${date.day}';
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('新規プロジェクト作成'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'プロジェクト名',
                    hintText: '例: 中2英語',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '説明（任意）',
                    hintText: '例: 2学期の英語授業用教材',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('プロジェクト名を入力してください')),
                    );
                    return;
                  }

                  final project = Project(
                    id: '', // Supabaseで自動生成
                    name: name,
                    description:
                        descriptionController.text.trim().isNotEmpty
                            ? descriptionController.text.trim()
                            : null,
                    createdAt: DateTime.now(),
                  );

                  // ダイアログを閉じる
                  Navigator.pop(context);

                  try {
                    // プロジェクトを作成
                    await _projectService.createProject(project);
                    // リストを更新
                    _loadProjects();

                    // 成功メッセージ
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('プロジェクトを作成しました')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('プロジェクトの作成に失敗しました: $e')),
                      );
                    }
                  }
                },
                child: const Text('作成'),
              ),
            ],
          ),
    );
  }
}
