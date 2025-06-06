import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_list_controller.dart';
import '../../../app_models/project.dart';
import '../../../app_styles/app_theme.dart';
import '../../../app_widgets/sides/drawer/app_scaffold.dart';
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
  ProjectListController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProjectListController();
    _controller!.loadProjects(prefetched: widget.prefetchedProjects);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.forSelection
            ? '${widget.selectionPurpose ?? "選択"}するプロジェクトを選択'
            : 'プロジェクト一覧';
    return ChangeNotifierProvider<ProjectListController>.value(
      value: _controller!,
      child: Consumer<ProjectListController>(
        builder: (context, controller, _) {
          return AppScaffold(
            title: title,
            currentNavIndex: 0,
            showBottomNav: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.loadProjects,
              ),
            ],
            body:
                controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage != null
                    ? _buildErrorState(controller)
                    : controller.projects.isEmpty
                    ? ProjectListEmpty(
                      forSelection: widget.forSelection,
                      selectionPurpose: widget.selectionPurpose,
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.projects.length,
                      itemBuilder: (context, index) {
                        final project = controller.projects[index];
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
                              ).then((_) => controller.loadProjects());
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
                      onPressed:
                          () => _showCreateProjectDialog(context, controller),
                      child: const Icon(Icons.add),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ProjectListController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage ?? 'エラーが発生しました',
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadProjects,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(
    BuildContext context,
    ProjectListController controller,
  ) {
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
                  Navigator.pop(context);
                  final success = await controller.createProject(
                    name,
                    descriptionController.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'プロジェクトを作成しました'
                              : (controller.errorMessage ?? 'プロジェクトの作成に失敗しました'),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('作成'),
              ),
            ],
          ),
    );
  }
}
