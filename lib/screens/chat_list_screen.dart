import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../screens/chat_detail_screen.dart'; // Import ChatDetailScreen

class ChatListScreen extends StatefulWidget {
  final String projectId; // ← プロジェクトに紐づくチャットのみ表示

  const ChatListScreen({super.key, required this.projectId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chats = await _chatService.fetchChatsByProject(widget.projectId);

    setState(() {
      _chats = chats;
      _isLoading = false;
    });
  }

  Future<void> _createChat() async {
    final newChat = Chat(
      id: '',
      projectId: widget.projectId,
      title: 'New Chat',
      createdAt: DateTime.now(),
    );
    await _chatService.createChat(newChat);
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('チャット一覧')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return ListTile(
                    title: Text(chat.title),
                    subtitle: Text(chat.createdAt.toLocal().toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(chatId: chat.id),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChat,
        child: const Icon(Icons.add),
      ),
    );
  }
}
