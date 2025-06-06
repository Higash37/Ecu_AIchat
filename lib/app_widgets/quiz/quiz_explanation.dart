import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_styles/app_theme.dart';
import '../../ai_ui/quiz.dart';

class QuizExplanation extends StatelessWidget {
  final Quiz quiz;
  final int index;
  final VoidCallback onRetry;
  const QuizExplanation({
    super.key,
    required this.quiz,
    required this.index,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final option = quiz.options[index];
    final correctOption = quiz.correctOption;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: option.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  option.isCorrect
                      ? Colors.green.shade100
                      : Colors.red.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (option.isCorrect ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    option.isCorrect ? Icons.emoji_events : Icons.error_outline,
                    color:
                        option.isCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.isCorrect ? '正解です！' : '不正解です',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            option.isCorrect
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                      ),
                    ),
                    if (!option.isCorrect && correctOption != null)
                      Text(
                        '正解は: ${correctOption.text}',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade800,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '解説:',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    option.explanation,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      'もう一度挑戦する',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
