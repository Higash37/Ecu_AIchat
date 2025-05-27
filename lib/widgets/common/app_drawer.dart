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
              title: '新規チャット',
              icon: Icons.add_circle_outline,
              screen: ChatScreen(
                chatId: Uuid().v4(),
                projectId: '', // 空文字で渡す
              ),
              isPrimary: true, // 主要なアクション
            ),
            const Divider(),
            _buildMenuItem(
              context,
              title: 'チャット履歴',
              icon: Icons.history,
              isHeader: true, // セクションヘッダーとして扱う
            ),
            _buildMenuItem(
              context,
              title: 'チャット一覧',
              icon: Icons.chat_bubble_outline,
              screen: const ChatListScreen(),
              indented: true, // インデント表示
            ),
            const Divider(),
            _buildMenuItem(
              context,
              title: 'プロジェクト',
              icon: Icons.folder,
              screen: const ProjectListScreen(),
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
    bool isPrimary = false, // 主要アクション（強調表示）
    bool isHeader = false, // セクションヘッダー
    bool indented = false, // インデント表示
  }) {
    final Color activeColor =
        isPrimary ? const Color(0xFF6C63FF) : const Color(0xFF6C63FF);
    final TextStyle textStyle = TextStyle(
      color:
          isDisabled
              ? Colors.grey
              : isHeader
              ? Colors.grey.shade600
              : Colors.black87,
      fontWeight: isHeader || isPrimary ? FontWeight.bold : FontWeight.w500,
      fontSize: isHeader ? 12 : null,
    );

    return Padding(
      padding: EdgeInsets.only(left: indented ? 16.0 : 0),
      child: ListTile(
        dense: isHeader,
        leading: Icon(
          icon,
          color: isDisabled ? Colors.grey : activeColor,
          size: isPrimary ? 28 : null,
        ),
        title: Text(title, style: textStyle),
        onTap:
            isDisabled || isHeader
                ? () {
                  if (isDisabled) {
                    Navigator.pop(context);
                    _showComingSoonToast(
                      context,
                      '${title.replaceAll('（準備中）', '')}機能は開発中です',
                    );
                  }
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
      ),
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
