import 'package:flutter/material.dart';

class KnowledgeGraphMiniView extends StatelessWidget {
  final dynamic graphData; // MapやList形式を想定
  const KnowledgeGraphMiniView({required this.graphData, super.key});
  @override
  Widget build(BuildContext context) {
    if (graphData is Map && graphData.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.graphic_eq, color: Colors.blueGrey, size: 16),
                const SizedBox(width: 6),
                Text(
                  '知識グラフ',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...graphData.entries
                .take(5)
                .map(
                  (e) => Text(
                    '・${e.key} → ${e.value}',
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
            if (graphData.length > 5)
              const Text(
                '...（一部表示）',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
