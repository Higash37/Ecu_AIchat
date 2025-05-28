import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../chat_detail_screen/chat_detail_screen.dart';
import 'chat_list_controller.dart';
import 'chat_list_item.dart';
import 'chat_list_empty_state.dart';
import 'new_chat_dialog.dart';
import 'delete_chat_dialog.dart';

class ChatListScreen extends StatefulWidget {
  final String? projectId;
  const ChatListScreen({super.key, this.projectId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatListController(projectId: widget.projectId);
    _controller.addListener(_onControllerChanged);
    _controller.loadChats(context);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _createChat() async {
    if (widget.projectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロジェクトを選択してください')));
      return;
    }
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => NewChatDialog(controller: titleController),
    );
    if (title != null && title.isNotEmpty) {
      final createdChat = await _controller.createChat(context, title);
      if (createdChat != null && createdChat.id.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    ChatDetailScreen(chatId: createdChat.id, chat: createdChat),
          ),
        ).then((_) => _controller.loadChats(context));
      }
    }
  }

  void _confirmDeleteChat(Chat chat) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteChatDialog(
            chat: chat,
            onDelete: () async {
              await _controller.deleteChat(context, chat.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _controller.projectTitle,
      currentNavIndex: 1,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _controller.loadChats(context),
        ),
      ],
      body:
          _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.chats.isEmpty
              ? _buildEmptyState()
              : _buildChatList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: _createChat,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const ChatListEmptyState();
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.chats.length,
      itemBuilder: (context, index) {
        final chat = _controller.chats[index];
        return ChatListItem(
          chat: chat,
          onDelete: () => _confirmDeleteChat(chat),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(chatId: chat.id, chat: chat),
              ),
            ).then((_) => _controller.loadChats(context));
          },
        );
      },
    );
  }
}
