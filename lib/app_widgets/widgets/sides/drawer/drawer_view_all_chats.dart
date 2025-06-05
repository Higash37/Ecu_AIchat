import 'package:flutter/material.dart';
import '../../../../supabase_ui/screens/chat_screens/chat_list_screen/chat_list_screen.dart';

/// Drawer内の「すべてのチャットを表示」ボタンWidget
class DrawerViewAllChats extends StatelessWidget {
  const DrawerViewAllChats({super.key});

  @override
  Widget build(BuildContext context) {
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
}
