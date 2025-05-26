import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../screens/project_screens/project_list_screen/project_list_screen.dart';
import '../../screens/chat_screens/chat_list_screen/chat_list_screen.dart';
import '../../screens/chat_screens/chat_screen/chat_screen.dart';
import '../../screens/tag_screens/tag_list_screen/tag_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
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
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        size: 40,
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
            _buildMenuItem(
              context,
              title: 'プロジェクト一覧',
              icon: Icons.folder,
              screen: const ProjectListScreen(),
            ),
            _buildMenuItem(
              context,
              title: 'チャット履歴',
              icon: Icons.history,
              screen: const ChatListScreen(),
            ),
            _buildMenuItem(
              context,
              title: '新規チャット',
              icon: Icons.chat_bubble,
              screen: ChatScreen(
                chatId: Uuid().v4(),
                projectId: '', // 空文字で渡す
              ), // projectIdも渡す
            ),
            _buildMenuItem(
              context,
              title: 'タグ管理',
              icon: Icons.tag,
              screen: const TagListScreen(projectId: ''), // 空文字で渡す
            ),
            const Divider(),
            _buildMenuItem(
              context,
              title: 'ワードクラウド（準備中）',
              icon: Icons.cloud,
              isDisabled: true,
            ),
            _buildMenuItem(
              context,
              title: 'PDF生成（準備中）',
              icon: Icons.picture_as_pdf,
              isDisabled: true,
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                // TODO: 設定画面へ遷移
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? screen,
    bool isDisabled = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDisabled ? Colors.grey : const Color(0xFF6C63FF),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDisabled ? Colors.grey : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap:
          isDisabled
              ? () {
                Navigator.pop(context);
                _showComingSoonToast(
                  context,
                  '${title.replaceAll('（準備中）', '')}機能は開発中です',
                );
              }
              : () {
                Navigator.pop(context);
                if (screen != null) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => screen,
                      transitionDuration: Duration.zero,
                    ),
                  );
                }
              },
    );
  }

  // 準備中機能向けのトースト表示
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
