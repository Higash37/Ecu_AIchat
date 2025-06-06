import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../supabase_ui/project_screens/project_list_screen/project_list_screen.dart';
import '../../supabase_ui/chat_screens/chat_list_screen/chat_list_screen.dart';
import '../../supabase_ui/chat_screens/chat_screen/chat_screen.dart';
import '../../supabase_ui/tag_screens/tag_list_screen/tag_list_screen.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFF6C63FF), // テーマカラー
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          onTap: (index) {
            if (index == currentIndex) return;

            Widget screen;
            switch (index) {
              case 0:
                screen = const ProjectListScreen();
                break;
              case 1:
                screen = const ChatListScreen();
                break;
              case 2:
                screen = ChatScreen(
                  chatId: Uuid().v4(),
                  projectId: '', // 空文字で渡す
                ); // projectIdも渡す
                break;
              case 3:
                // TagListScreenはprojectIdを必要とするため、プロジェクトIDがないとエラーになる
                // 仮のプロジェクトIDを使用して画面を表示（本来はプロジェクト選択UIを表示すべき）
                screen = TagListScreen(projectId: ''); // 空文字で渡す
                break;
              default:
                return;
            }

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => screen,
                transitionDuration: Duration.zero,
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'プロジェクト',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'チャット履歴',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              activeIcon: Icon(Icons.chat_rounded),
              label: '新規チャット',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_outlined),
              activeIcon: Icon(Icons.tag),
              label: 'タグ',
            ),
          ],
        ),
      ),
    );
  }
}
