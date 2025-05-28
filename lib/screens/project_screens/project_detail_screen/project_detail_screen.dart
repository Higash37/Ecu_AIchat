import 'package:flutter/material.dart';
import 'project_detail_header.dart';
import 'project_detail_empty.dart';
import 'project_detail_chat_list.dart';
import '../../../models/project.dart';
import '../../../models/chat.dart';
import '../../../services/chat_service.dart';
import '../../../services/project_service.dart';
import '../../../services/local_cache_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../../tag_screens/tag_list_screen/tag_list_screen.dart';
import 'project_detail_dialogs.dart';
import 'project_detail_pdf_sheet.dart';
import 'project_detail_toast.dart';
import '../../../widgets/common/error_state_widget.dart';
import '../../chat_screens/chat_screen/chat_screen.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _chatService = ChatService();
  final _projectService = ProjectService();
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (widget.project.id == null) {
        throw Exception('プロジェクトIDが未設定です');
      }
      final user = await LocalCacheService.getUserInfo();
      final userId = user?['user_id'] ?? '';
      final chats = await _chatService.fetchChatsByProjectId(
        widget.project.id!,
        userId,
      );
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'チャットの読み込みに失敗しました。再試行してください。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                projectService: _projectService,
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
                          if (widget.project.id == null) {
                            throw Exception('プロジェクトIDが未設定です');
                          }
                          await _projectService.deleteProject(
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatScreen(
                    chatId: const Uuid().v4(),
                    projectId: widget.project.id ?? '',
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
            chatCount: _chats.length,
            onCreateChat: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ChatScreen(
                        chatId: const Uuid().v4(),
                        projectId: widget.project.id ?? '',
                      ),
                ),
              );
            },
            onTagManage: () {
              if (widget.project.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            TagListScreen(projectId: widget.project.id!),
                  ),
                );
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
                  onPressed: _loadChats,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? ErrorStateWidget(
                      message: _errorMessage ?? 'エラーが発生しました',
                      onRetry: _loadChats,
                    )
                    : _chats.isEmpty
                    ? ProjectDetailEmpty(
                      onCreateChat: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatScreen(
                                  chatId: const Uuid().v4(),
                                  projectId: widget.project.id ?? '',
                                ),
                          ),
                        );
                      },
                    )
                    : ProjectDetailChatList(
                      chats: _chats,
                      onDeleteChat:
                          (chat) => showConfirmDeleteChat(
                            context: context,
                            chat: chat,
                            onDelete: () => _deleteChat(chat.id),
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      final chatService = ChatService();
      await chatService.deleteChat(chatId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('チャットを削除しました')));
        _loadChats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャットの削除に失敗しました: $e')));
      }
    }
  }

  Widget _buildPdfGenerationSheet(BuildContext context) {
    return ProjectDetailPdfSheet(
      onToast: (msg) => showSuccessToast(context, msg),
    );
  }
}
