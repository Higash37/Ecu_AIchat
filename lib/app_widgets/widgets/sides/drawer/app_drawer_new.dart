import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../supabase_ui/screens/project_screens/project_list_screen/project_list_screen.dart';
import '../../../../supabase_ui/screens/chat_screens/chat_screen/chat_screen.dart';
import '../../../../supabase_ui/screens/tag_screens/tag_list_screen/tag_list_screen.dart';
import 'app_drawer_controller.dart';
import 'drawer_section_header.dart';
import 'drawer_chat_item.dart';
import 'drawer_menu_item.dart';
import 'drawer_search_bar.dart';
import 'drawer_view_all_chats.dart';
import 'drawer_toast.dart';
import '../../auth/login_dialog.dart';

class AppDrawerNew extends StatelessWidget {
  const AppDrawerNew({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDrawerController(),
      child: const _AppDrawerNewBody(),
    );
  }
}

class _AppDrawerNewBody extends StatelessWidget {
  const _AppDrawerNewBody();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppDrawerController>(context);

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
                  controller.isLoading
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
                            controller.recentChats.map((chat) {
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
            // ログイン/ユーザー表示導線
            if (!controller.isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('ログイン / 新規登録'),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder:
                          (context) => LoginDialog(
                            onSubmit: (nickname, password, isLogin) {}, // ダミー
                          ),
                    );
                    if (result is Map &&
                        result['user_id'] != null &&
                        result['nickname'] != null) {
                      await controller.login(
                        result['user_id'],
                        result['nickname'],
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.nickname ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await controller.logout();
                      },
                      child: const Text('ログアウト'),
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
