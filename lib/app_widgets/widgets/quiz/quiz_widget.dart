import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app_models/models/quiz.dart';
import '../../../app_styles/theme/app_theme.dart';
import 'quiz_badge.dart';
import 'quiz_option_item.dart';
import 'quiz_explanation.dart';

class QuizWidget extends StatefulWidget {
  final Quiz quiz;

  const QuizWidget({super.key, required this.quiz});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  bool _isExpanded = false;
  int? _selectedOptionIndex;
  bool _showExplanation = false;

  // 難易度に基づいて色を取得
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '初級':
      case 'easy':
      case '簡単':
        return Colors.green.shade700;
      case '中級':
      case 'medium':
      case '普通':
        return Colors.orange.shade700;
      case '上級':
      case 'hard':
      case '難しい':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 難易度とカテゴリーバッジ
          if (widget.quiz.difficulty != null || widget.quiz.category != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (widget.quiz.difficulty != null)
                    QuizBadge(
                      text: widget.quiz.difficulty ?? '',
                      color: _getDifficultyColor(widget.quiz.difficulty ?? ''),
                      icon: Icons.signal_cellular_alt,
                    ),
                  if (widget.quiz.difficulty != null &&
                      widget.quiz.category != null)
                    const SizedBox(width: 8),
                  if (widget.quiz.category != null)
                    QuizBadge(
                      text: widget.quiz.category ?? '',
                      color: Colors.blue.shade700,
                      icon: Icons.category,
                    ),
                ],
              ),
            ),
          // 質問ヘッダー
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) {
                  _selectedOptionIndex = null;
                  _showExplanation = false;
                }
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.quiz.question,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          _isExpanded
                              ? Colors.grey.shade200
                              : AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color:
                          _isExpanded
                              ? Colors.grey.shade700
                              : AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 展開時に表示する選択肢
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showExplanation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'あなたの考えを選んでください:',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ...List.generate(
                    widget.quiz.options.length,
                    (index) => QuizOptionItem(
                      quiz: widget.quiz,
                      index: index,
                      isSelected: _selectedOptionIndex == index,
                      showExplanation: _showExplanation,
                      selectedOptionIndex: _selectedOptionIndex,
                      onTap: (i) {
                        setState(() {
                          _selectedOptionIndex = i;
                          _showExplanation = true;
                        });
                      },
                    ),
                  ),
                  if (_showExplanation && _selectedOptionIndex != null)
                    QuizExplanation(
                      quiz: widget.quiz,
                      index: _selectedOptionIndex ?? 0,
                      onRetry: () {
                        setState(() {
                          _isExpanded = false;
                          _selectedOptionIndex = null;
                          _showExplanation = false;
                        });
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
