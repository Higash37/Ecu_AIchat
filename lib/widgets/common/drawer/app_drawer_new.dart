import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat.dart';
import '../../../screens/project_screens/project_list_screen/project_list_screen.dart';
import '../../../screens/chat_screens/chat_screen/chat_screen.dart';
import '../../../screens/tag_screens/tag_list_screen/tag_list_screen.dart';
import '../../../services/chat_service.dart';
import 'drawer_section_header.dart';
import 'drawer_chat_item.dart';
import 'drawer_menu_item.dart';
import 'drawer_search_bar.dart';
import 'drawer_view_all_chats.dart';
import 'drawer_toast.dart';

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
                  DrawerMenuItem(
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
                  const DrawerSearchBar(),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // チャット履歴
                  const DrawerSectionHeader(
                    title: '直近のチャット',
                    icon: Icons.history,
                  ),

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
                              return DrawerChatItem(chat: chat);
                            }).toList(),
                      ),
                  const SizedBox(height: 8),
                  const DrawerViewAllChats(),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // プロジェクト関連
                  const DrawerSectionHeader(
                    title: 'プロジェクト',
                    icon: Icons.folder,
                  ),
                  DrawerMenuItem(
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
                  DrawerMenuItem(
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
                  DrawerMenuItem(
                    title: 'PDFエクスポート',
                    icon: Icons.picture_as_pdf,
                    onTap: () {
                      Navigator.pop(context);
                      showComingSoonToast(context, 'PDFエクスポート機能は開発中です');
                    },
                    isDisabled: true,
                  ),
                  DrawerMenuItem(
                    title: '設定',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      showComingSoonToast(context, '設定機能は開発中です');
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
}
