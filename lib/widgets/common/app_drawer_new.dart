import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat.dart';
import '../../screens/project_screens/project_list_screen/project_list_screen.dart';
import '../../screens/chat_screens/chat_list_screen/chat_list_screen.dart';
import '../../screens/chat_screens/chat_screen/chat_screen.dart';
import '../../screens/chat_screens/chat_detail_screen/chat_detail_screen.dart';
import '../../screens/tag_screens/tag_list_screen/tag_list_screen.dart';
import '../../services/chat_service.dart';
import 'package:intl/intl.dart';

class AppDrawerNew extends StatefulWidget {
  const AppDrawerNew({super.key});

  @override
  State<AppDrawerNew> createState() => _AppDrawerNewState();
}

class _AppDrawerNewState extends State<AppDrawerNew> {
  final ChatService _chatService = ChatService();
  List<Chat> _recentChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    try {
      // 直近のチャット履歴を取得（最大10件）
      final allChats = await _chatService.fetchAllChats();

      setState(() {
        _recentChats = allChats.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        size: 36,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'AI教材チャット',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // メインナビゲーション部分
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    title: '新規チャット',
                    icon: Icons.add_circle_outline,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => ChatScreen(
                                chatId: const Uuid().v4(),
                                projectId: '',
                              ),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(height: 8),
                  _buildSearchBar(context),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // チャット履歴
                  _buildSectionHeader('直近のチャット', Icons.history),

                  // 最近のチャット一覧
                  _isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                      : Column(
                        children:
                            _recentChats.map((chat) {
                              return _buildChatItem(context, chat);
                            }).toList(),
                      ),
                  const SizedBox(height: 8),
                  _buildViewAllChats(context),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // プロジェクト関連
                  _buildSectionHeader('プロジェクト', Icons.folder),
                  _buildMenuItem(
                    context,
                    title: 'プロジェクト一覧',
                    icon: Icons.folder_open,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => const ProjectListScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    title: 'タグ管理',
                    icon: Icons.tag,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) =>
                                  const TagListScreen(projectId: ''),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  // 設定や機能
                  _buildMenuItem(
                    context,
                    title: 'PDFエクスポート',
                    icon: Icons.picture_as_pdf,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonToast(context, 'PDFエクスポート機能は開発中です');
                    },
                    isDisabled: true,
                  ),
                  _buildMenuItem(
                    context,
                    title: '設定',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonToast(context, '設定機能は開発中です');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          // TODO: 検索画面へ
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'チャットを検索',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Chat chat) {
    String formatDate(DateTime? date) {
      if (date == null) return '';

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (date.isAfter(today)) {
        return '今日';
      } else if (date.isAfter(yesterday)) {
        return '昨日';
      } else {
        return DateFormat('MM/dd').format(date);
      }
    }

    final lastDate = chat.updatedAt ?? chat.createdAt;
    final dateText = formatDate(lastDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(chatId: chat.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chat.lastMessage != null &&
                        chat.lastMessage!.isNotEmpty)
                      Text(
                        chat.lastMessage!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (dateText.isNotEmpty)
                Text(
                  dateText,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllChats(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ChatListScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.more_horiz, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'すべてのチャットを表示',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDisabled = false,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: isPrimary ? 20 : 16,
                  color: isPrimary ? const Color(0xFF6C63FF) : Colors.grey[800],
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isPrimary ? 15 : 14,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                    color: isPrimary ? const Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonToast(BuildContext context, String message) {
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
                color: const Color(0xFF6C63FF).withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.update, color: Colors.white),
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
