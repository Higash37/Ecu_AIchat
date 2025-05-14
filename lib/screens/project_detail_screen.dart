import 'package:flutter/material.dart';
import '../models/project.dart';
import '../chat_screen.dart'; // ← チャット画面に遷移するためにインポート

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description ?? 'No description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('チャット画面に進む'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const ChatScreen(), // ← 必要に応じて project を渡す
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
