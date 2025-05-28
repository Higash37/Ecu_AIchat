import 'package:flutter/material.dart';
import 'project_detail_header.dart';
import 'project_detail_empty.dart';
import 'project_detail_chat_list.dart';
import '../../../models/project.dart';
import '../../../models/chat.dart';
import '../../../services/chat_service.dart';
import '../../../services/project_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/drawer/app_scaffold.dart';
import '../../chat_screens/chat_detail_screen/chat_detail_screen.dart';
import '../../tag_screens/tag_list_screen/tag_list_screen.dart';
import 'project_detail_create_chat_dialog.dart';
import 'project_detail_edit_project_dialog.dart';
import 'project_detail_delete_dialog.dart';
import 'project_detail_pdf_sheet.dart';
import 'project_detail_toast.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _chatService = ChatService();
  final _projectService = ProjectService(); // ProjectServiceを追加
  List<Chat> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // プロジェクトIDがnullの場合のエラー処理
      if (widget.project.id == null) {
        throw Exception('プロジェクトIDが未設定です');
      }
      final chats = await _chatService.fetchChatsByProjectId(
        widget.project.id!,
      );
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャットの読み込みに失敗しました: $e')));
      }
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
          onPressed: () => _showEditProjectDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectDetailHeader(
            project: widget.project,
            chatCount: _chats.length,
            onCreateChat: () => _showCreateChatDialog(context),
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
                    : _chats.isEmpty
                    ? ProjectDetailEmpty(
                      onCreateChat: () => _showCreateChatDialog(context),
                    )
                    : ProjectDetailChatList(
                      chats: _chats,
                      onDeleteChat: (chat) => _confirmDeleteChat(chat),
                    ),
          ),
        ],
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectDetailCreateChatDialog(
            projectId: widget.project.id!,
            onCreate: (chat) async {
              try {
                final createdChat = await _chatService.createChat(chat);
                _loadChats();
                if (createdChat.id.isNotEmpty && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatDetailScreen(
                            chatId: createdChat.id,
                            chat: createdChat,
                          ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('チャットの作成に失敗しました: $e')));
                }
              }
              return null;
            },
          ),
    );
  }

  void _showEditProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectDetailEditProjectDialog(
            project: widget.project,
            onUpdate: (updatedProject) async {
              try {
                await _projectService.updateProject(updatedProject);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('プロジェクトを更新しました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('プロジェクト更新に失敗しました: $e')),
                  );
                }
              }
            },
          ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('プロジェクトIDをコピー'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: クリップボードにコピー
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('プロジェクトIDをコピーしました')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('プロジェクトを削除'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectDetailDeleteDialog(
            onDelete: () async {
              try {
                if (widget.project.id == null) {
                  throw Exception('プロジェクトIDが未設定です');
                }
                await _projectService.deleteProject(widget.project.id!);
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
    );
  }

  // チャット削除の確認ダイアログを表示
  void _confirmDeleteChat(Chat chat) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('チャットを削除'),
            content: Text('「${chat.title}」を削除しますか？この操作は元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteChat(chat.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }

  // チャットを削除する
  Future<void> _deleteChat(String chatId) async {
    try {
      final chatService = ChatService();
      await chatService.deleteChat(chatId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('チャットを削除しました')));
        // チャット一覧を再読み込み
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
