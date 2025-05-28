import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/project.dart';
import '../../../services/project_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../project_detail_screen/project_detail_screen.dart';
import 'project_list_empty.dart';
import 'project_list_item.dart';

class ProjectListScreen extends StatefulWidget {
  final bool forSelection;
  final String? selectionPurpose;
  final String? navigationMode;
  final List<Project>? prefetchedProjects;
  final Map<String, dynamic>? prefetchedUser;

  const ProjectListScreen({
    super.key,
    this.forSelection = false,
    this.selectionPurpose,
    this.navigationMode,
    this.prefetchedProjects,
    this.prefetchedUser,
  });

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _errorMessage; // エラー状態追加

  @override
  void initState() {
    super.initState();
    // プリフェッチがあれば即時反映
    if (widget.prefetchedProjects != null &&
        widget.prefetchedProjects!.isNotEmpty) {
      _projects = widget.prefetchedProjects!;
      _isLoading = false;
    } else {
      _loadProjects();
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _errorMessage = 'プロジェクトの読み込みに失敗しました。再試行してください。';
      });
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
      showBottomNav: false, // ボトムナビゲーションを非表示
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : _projects.isEmpty
              ? ProjectListEmpty(
                forSelection: widget.forSelection,
                selectionPurpose: widget.selectionPurpose,
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return ProjectListItem(
                    project: project,
                    forSelection: widget.forSelection,
                    onTap: () {
                      if (widget.forSelection) {
                        Navigator.pop(context, project);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProjectDetailScreen(project: project),
                          ),
                        ).then((_) => _loadProjects());
                      }
                    },
                  );
                },
              ),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'エラーが発生しました',
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadProjects, child: const Text('再試行')),
        ],
      ),
    );
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
                    id: Uuid().v4(), // Supabaseで自動生成しない場合はここで生成
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
