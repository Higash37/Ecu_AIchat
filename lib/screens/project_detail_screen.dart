import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../services/project_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'chat_detail_screen.dart';
import 'tag_list_screen.dart';

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
          _buildProjectHeader(),
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
                    ? _buildEmptyState()
                    : _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
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
              // プロジェクトアイコン
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
                    widget.project.name.substring(0, 1).toUpperCase(),
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
                    Text(widget.project.name, style: AppTheme.heading1),
                    const SizedBox(height: 4),
                    Text(
                      widget.project.description ?? '説明はありません',
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
                          '作成日: ${_formatDate(widget.project.createdAt)}',
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
                          'チャット数: ${_chats.length}',
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
                onPressed: () => _showCreateChatDialog(context),
              ),
              ActionChip(
                avatar: const Icon(Icons.tag_outlined, size: 16),
                label: const Text('タグ管理'),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                onPressed: () {
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
              ),
              ActionChip(
                avatar: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('教材生成'),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                onPressed: () {
                  // PDF生成画面表示
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => _buildPdfGenerationSheet(context),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            onPressed: () => _showCreateChatDialog(context),
            style: AppTheme.primaryButton,
            child: const Text('新規チャット作成'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                child: Text(
                  chat.title.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                chat.title,
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _formatLastMessage(chat.lastMessage),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(chat.updatedAt ?? chat.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.message_outlined,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chat.messageCount ?? 0}メッセージ',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChatDetailScreen(chatId: chat.id, chat: chat),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '日時不明';
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatLastMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'メッセージがありません';
    }
    return message;
  }

  void _showCreateChatDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('新規チャット作成'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'チャットタイトル',
                    hintText: '例: 英語長文読解の教材作成',
                  ),
                  autofocus: true,
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
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チャットタイトルを入力してください')),
                    );
                    return;
                  } // プロジェクトIDがnullの場合、例外を投げる
                  if (widget.project.id == null) {
                    throw Exception('プロジェクトIDが未設定です');
                  }

                  final chat = Chat(
                    id: '',
                    projectId: widget.project.id!,
                    title: title,
                    lastMessage: '',
                    createdAt: DateTime.now(),
                  );

                  Navigator.pop(context);

                  try {
                    final createdChat = await _chatService.createChat(chat);
                    _loadChats();

                    if (mounted) {
                      // 作成したチャットの詳細画面に移動
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('チャットの作成に失敗しました: $e')),
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

  void _showEditProjectDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.project.name);
    final descriptionController = TextEditingController(
      text: widget.project.description ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('プロジェクト編集'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'プロジェクト名'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '説明（任意）'),
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

                  try {
                    final updatedProject = Project(
                      id: widget.project.id,
                      name: name,
                      description: descriptionController.text.trim(),
                      createdAt: widget.project.createdAt,
                      chatCount: widget.project.chatCount,
                    );

                    await _projectService.updateProject(updatedProject);

                    // 画面を再読み込みする代わりに、ステート更新
                    if (mounted) {
                      setState(() {
                        // ウィジェットの再描画のため
                      });

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
                child: const Text('更新'),
              ),
            ],
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
          (context) => AlertDialog(
            title: const Text('プロジェクトを削除'),
            content: const Text(
              'このプロジェクトに関連するすべてのチャットとメッセージも削除されます。この操作は取り消せません。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    if (widget.project.id == null) {
                      throw Exception('プロジェクトIDが未設定です');
                    }

                    await _projectService.deleteProject(widget.project.id!);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('プロジェクトを削除しました')),
                      );

                      // プロジェクト一覧画面に戻る
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }

  // PDF生成シート表示
  Widget _buildPdfGenerationSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '教材生成オプション',
            style: AppTheme.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('学習教材PDF'),
            subtitle: const Text('チャットの内容からPDF教材を自動生成します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);

              // 通知の表示を洗練されたトースト表示に変更
              _showSuccessToast(context, '教材が生成されました！');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.quiz_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('問題集PDF'),
            subtitle: const Text('チャットの内容から問題集を自動生成します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);

              // 通知の表示を洗練されたトースト表示に変更
              _showSuccessToast(context, '問題集が生成されました！');
            },
          ),
        ],
      ),
    );
  }

  // 成功トースト表示
  void _showSuccessToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(30),
                color: Colors.green.shade600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
