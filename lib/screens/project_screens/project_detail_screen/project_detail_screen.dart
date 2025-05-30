import 'package:flutter/material.dart';
import 'project_detail_header.dart';
import 'project_detail_empty.dart';
import 'project_detail_chat_list.dart';
import '../../../models/project.dart';
import '../../../services/chat_service.dart';
import '../../../services/project_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../../tag_screens/tag_list_screen/tag_list_screen.dart';
import 'project_detail_dialogs.dart';
import 'project_detail_pdf_sheet.dart';
import 'project_detail_toast.dart';
import '../../../widgets/common/error_state_widget.dart';
import '../../chat_screens/chat_screen/chat_screen.dart';
import 'package:uuid/uuid.dart';
import 'project_detail_controller.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectDetailController? _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = ProjectDetailController(
        project: widget.project,
        chatService: ChatService(),
        projectService: ProjectService(),
      );
      _controller!.addListener(_onControllerChanged);
      _controller!.loadChats();
    } catch (e) {
      debugPrint('初期化エラー: $e');
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const AppScaffold(
        title: 'プロジェクト詳細',
        currentNavIndex: 0,
        body: Center(child: Text('コントローラー初期化エラー')),
      );
    }
    return AppScaffold(
      title: widget.project.name,
      currentNavIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed:
              () => showEditProjectDialog(
                context: context,
                project: widget.project,
                projectService: _controller!.projectService,
                onUpdated: () => setState(() {}),
              ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed:
              () => showMoreOptions(
                context: context,
                onDelete:
                    () => showDeleteConfirmation(
                      context: context,
                      onDelete: () async {
                        try {
                          if (widget.project.id == null ||
                              widget.project.id!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('プロジェクトIDが無効です')),
                            );
                            return;
                          }
                          await _controller!.projectService.deleteProject(
                            widget.project.id!,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('プロジェクトを削除しました')),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('プロジェクト削除に失敗しました: $e')),
                            );
                          }
                        }
                      },
                    ),
              ),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.project.id == null || widget.project.id!.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('プロジェクトIDが無効です')));
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatScreen(
                    chatId: const Uuid().v4(),
                    projectId: widget.project.id!,
                  ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectDetailHeader(
            project: widget.project,
            chatCount: _controller!.chats.length,
            onCreateChat: () {
              if (widget.project.id == null || widget.project.id!.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('プロジェクトIDが無効です')));
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ChatScreen(
                        chatId: const Uuid().v4(),
                        projectId: widget.project.id!,
                      ),
                ),
              );
            },
            onTagManage: () {
              if (widget.project.id != null && widget.project.id!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            TagListScreen(projectId: widget.project.id!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('プロジェクトIDが無効です')));
              }
            },
            onPdfGenerate: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return _buildPdfGenerationSheet(context);
                },
              );
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('チャット一覧', style: AppTheme.heading2),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('更新'),
                  onPressed: _controller!.loadChats,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _controller!.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller!.errorMessage != null
                    ? ErrorStateWidget(
                      message: _controller!.errorMessage ?? 'エラーが発生しました',
                      onRetry: _controller!.loadChats,
                    )
                    : _controller!.chats.isEmpty
                    ? ProjectDetailEmpty(
                      onCreateChat: () {
                        if (widget.project.id == null ||
                            widget.project.id!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('プロジェクトIDが無効です')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatScreen(
                                  chatId: const Uuid().v4(),
                                  projectId: widget.project.id!,
                                ),
                          ),
                        );
                      },
                    )
                    : ProjectDetailChatList(
                      chats: _controller!.chats,
                      onDeleteChat:
                          (chat) => showConfirmDeleteChat(
                            context: context,
                            chat: chat,
                            onDelete:
                                () => _controller!.deleteChat(chat.id, context),
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfGenerationSheet(BuildContext context) {
    return ProjectDetailPdfSheet(
      onToast: (msg) => showSuccessToast(context, msg),
    );
  }
}
