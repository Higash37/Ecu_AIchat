import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app_services/services-model/chat.dart';
import '../../../app_styles/app_theme.dart';
import '../../../app_widgets/sides/drawer/app_scaffold.dart';
import '../chat_screen/chat_screen.dart'; // ChatScreenをimport
import 'chat_list_controller.dart';
import 'chat_list_item.dart';
import 'chat_list_empty_state.dart';
import 'delete_chat_dialog.dart';

class ChatListScreen extends StatefulWidget {
  final String? projectId;
  final List<Chat>? prefetchedChats;
  final Map<String, dynamic>? prefetchedUser;
  const ChatListScreen({
    super.key,
    this.projectId,
    this.prefetchedChats,
    this.prefetchedUser,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ChatListController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = ChatListController(projectId: widget.projectId);
    _controller!.addListener(_onControllerChanged);
    // プリフェッチがあれば即時反映
    if (widget.prefetchedChats != null &&
        (widget.prefetchedChats?.isNotEmpty ?? false)) {
      _controller!.chats = widget.prefetchedChats ?? [];
      _controller!.isLoading = false;
    } else {
      _loadChats();
    }
  }

  void _loadChats() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      await _controller?.loadChats(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'チャットの読み込みに失敗しました。再試行してください。';
      });
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

  void _createChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              chatId: const Uuid().v4(),
              projectId: widget.projectId ?? '',
            ),
      ),
    );
  }

  void _confirmDeleteChat(Chat chat) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteChatDialog(
            chat: chat,
            onDelete: () async {
              await _controller?.deleteChat(context, chat.id);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _controller?.projectTitle ?? '',
      currentNavIndex: 1,
      showBottomNav: false,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadChats),
      ],
      body:
          _controller?.isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : (_controller?.chats.isEmpty ?? true)
              ? _buildEmptyState()
              : _buildChatList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: _createChat,
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
          ElevatedButton(onPressed: _loadChats, child: const Text('再試行')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const ChatListEmptyState();
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller!.chats.length,
      itemBuilder: (context, index) {
        final chat = _controller!.chats[index];
        return ChatListItem(
          chat: chat,
          onDelete: () => _confirmDeleteChat(chat),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ChatScreen(
                      chatId: chat.id,
                      projectId: chat.projectId ?? '',
                    ),
              ),
            ).then((_) => _controller?.loadChats(context));
          },
        );
      },
    );
  }
}
