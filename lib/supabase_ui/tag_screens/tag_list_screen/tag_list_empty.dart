// tag_list_empty.dart
// タグが空のときの表示Widget

import 'package:flutter/material.dart';

class TagListEmpty extends StatelessWidget {
  const TagListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tag_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'タグがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '上部のフォームから新しいタグを追加できます',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
