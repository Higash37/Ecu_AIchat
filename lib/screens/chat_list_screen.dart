import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../screens/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String? projectId; // プロジェクトに紐づくチャットのみ表示（nullの場合は全表示）

  const ChatListScreen({super.key, this.projectId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = true;
  String _projectTitle = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      List<Chat> chats;
      if (widget.projectId != null) {
        chats = await _chatService.fetchChatsByProject(widget.projectId!);
        // TODO: プロジェクトタイトルも取得
        _projectTitle = 'プロジェクト内チャット';
      } else {
        chats = await _chatService.fetchAllChats();
        _projectTitle = 'すべてのチャット';
      } // 更新日時でソート（最新順）
      chats.sort((a, b) {
        final DateTime dateA = a.updatedAt ?? a.createdAt;
        final DateTime dateB = b.updatedAt ?? b.createdAt;
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャットの読み込みに失敗しました: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createChat() async {
    if (widget.projectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロジェクトを選択してください')));
      return;
    }

    // 新規チャットのタイトル入力用のコントローラ
    final titleController = TextEditingController();

    // 新規チャットのタイトル入力ダイアログを表示
    final title = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('新規チャット'),
            content: TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'チャットタイトル',
                hintText: '例：ChatGPTによる数学の問題解決',
              ),
              onSubmitted: (value) {
                Navigator.pop(context, value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, titleController.text);
                },
                child: const Text('作成'),
              ),
            ],
          ),
    );

    // ダイアログの結果を処理
    if (title != null && title.isNotEmpty) {
      try {
        final newChat = Chat(
          id: '',
          projectId: widget.projectId!,
          title: title,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastMessage: '',
          messageCount: 0,
        );

        final createdChat = await _chatService.createChat(newChat);
        await _loadChats();

        if (mounted) {
          // 作成したチャットの詳細画面に遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatDetailScreen(
                    chatId: createdChat.id,
                    chat: createdChat,
                  ),
            ),
          ).then((_) => _loadChats());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('チャットの作成に失敗しました: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _projectTitle,
      currentNavIndex: 1,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadChats),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chats.isEmpty
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '右下の+ボタンから新しいチャットを作成できます',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final formatter = DateFormat('yyyy/MM/dd HH:mm');
        // updatedAtがnullの場合はcreatedAtを使用
        final DateTime displayDate = chat.updatedAt ?? chat.createdAt;
        final formattedDate = formatter.format(displayDate.toLocal());

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(chatId: chat.id, chat: chat),
                ),
              ).then((_) => _loadChats()); // 戻ってきたら再読み込み
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chat.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.messageCount != null && chat.messageCount! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.messageCount}件',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (chat.lastMessage != null && chat.lastMessage!.isNotEmpty)
                    Text(
                      chat.lastMessage!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
