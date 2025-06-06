import 'package:flutter/material.dart';

class ProblemRow extends StatelessWidget {
  final String question;
  final String? caution; // 注意（赤・下線・PDF時は赤シートで隠れる色）
  final String? hint; // ヒント（赤シートで隠れる色）
  final String? praise; // できたらすごい（黒系・太字・下線）

  const ProblemRow({
    super.key,
    required this.question,
    this.caution,
    this.hint,
    this.praise,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 問題文（左7割）
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(question, style: const TextStyle(fontSize: 16)),
          ),
        ),
        // 補助情報（右3割）
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((caution ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    caution ?? '',
                    style: const TextStyle(
                      color: Color(0xFFB71C1C), // 濃い赤
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if ((hint ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    hint ?? '',
                    style: const TextStyle(
                      color: Color(0xFF00FF00), // 緑（PDF時赤シートで隠れる色例）
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              if ((praise ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    praise ?? '',
                    style: const TextStyle(
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
