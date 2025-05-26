import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ChatMessageAvatar extends StatelessWidget {
  final bool isAI;
  const ChatMessageAvatar({super.key, required this.isAI});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: isAI ? AppTheme.primaryColor : Colors.grey.shade300,
          radius: 16,
          child: Icon(
            isAI ? Icons.smart_toy : Icons.person,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
