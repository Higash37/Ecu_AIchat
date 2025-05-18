import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../theme/app_theme.dart';

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

  // バッジウィジェットを構築
  Widget _buildBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
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
          // 難易度とカテゴリーバッジ（存在する場合）
          if (widget.quiz.difficulty != null || widget.quiz.category != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (widget.quiz.difficulty != null)
                    _buildBadge(
                      text: widget.quiz.difficulty!,
                      color: _getDifficultyColor(widget.quiz.difficulty!),
                      icon: Icons.signal_cellular_alt,
                    ),
                  if (widget.quiz.difficulty != null &&
                      widget.quiz.category != null)
                    const SizedBox(width: 8),
                  if (widget.quiz.category != null)
                    _buildBadge(
                      text: widget.quiz.category!,
                      color: Colors.blue.shade700,
                      icon: Icons.category,
                    ),
                ],
              ),
            ),
          // 難易度とカテゴリーバッジ（存在する場合）
          if (widget.quiz.difficulty != null || widget.quiz.category != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (widget.quiz.difficulty != null)
                    _buildBadge(
                      text: widget.quiz.difficulty!,
                      color: _getDifficultyColor(widget.quiz.difficulty!),
                      icon: Icons.signal_cellular_alt,
                    ),
                  if (widget.quiz.difficulty != null &&
                      widget.quiz.category != null)
                    const SizedBox(width: 8),
                  if (widget.quiz.category != null)
                    _buildBadge(
                      text: widget.quiz.category!,
                      color: Colors.blue.shade700,
                      icon: Icons.category,
                    ),
                ],
              ),
            ),

          // 質問ヘッダー（常に表示）
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
                  // 投票依頼メッセージ
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

                  // 選択肢リスト
                  ...List.generate(
                    widget.quiz.options.length,
                    (index) => _buildOptionItem(index),
                  ),

                  // 解説
                  if (_showExplanation && _selectedOptionIndex != null)
                    _buildExplanation(_selectedOptionIndex!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(int index) {
    final option = widget.quiz.options[index];
    final bool isSelected = _selectedOptionIndex == index;
    final Map<int, int> votePercentages = widget.quiz.getVotePercentages();
    final int percentage = votePercentages[index] ?? 0;

    // 選択肢の状態に応じた色を設定
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;

    if (_showExplanation && isSelected) {
      // 回答後の色設定
      bgColor = option.isCorrect ? Colors.green.shade500 : Colors.red.shade500;
      borderColor =
          option.isCorrect ? Colors.green.shade700 : Colors.red.shade700;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = AppTheme.primaryColor.withOpacity(0.7);
      borderColor = AppTheme.primaryColor;
      textColor = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // パディングを小さく
      child: InkWell(
        borderRadius: BorderRadius.circular(8), // 小さくしたので角丸も調整
        onTap:
            _showExplanation
                ? null // 説明表示中は選択肢を押せなくする
                : () {
                  setState(() {
                    _selectedOptionIndex = index;
                    _showExplanation = true;
                  });
                },
        child: Container(
          height: 30, // 選択肢の高さを約40%に縮小（70→30）
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8), // 小さくしたので角丸も調整
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (_showExplanation && isSelected)
                BoxShadow(
                  color: (option.isCorrect ? Colors.green : Colors.red)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Stack(
            children: [
              // 進行状況バー（投票率を視覚化）
              if (_showExplanation)
                Positioned.fill(
                  child: Row(
                    children: [
                      Flexible(
                        flex: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: (option.isCorrect
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(6),
                              bottomLeft: const Radius.circular(6),
                              topRight:
                                  percentage == 100
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                              bottomRight:
                                  percentage == 100
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                      if (percentage < 100)
                        Flexible(flex: 100 - percentage, child: Container()),
                    ],
                  ),
                ), // コンテンツ
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ), // パディングを小さく
                child: Row(
                  children: [
                    // 選択肢マーカー（A, B, C, D）とアイコン
                    Container(
                      width: 22, // サイズを小さく
                      height: 22, // サイズを小さく
                      decoration: BoxDecoration(
                        color:
                            _showExplanation
                                ? (isSelected
                                    ? (option.isCorrect
                                        ? Colors.green.shade100
                                        : Colors.red.shade100)
                                    : Colors.grey.shade100)
                                : (isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _showExplanation
                                  ? (isSelected
                                      ? (option.isCorrect
                                          ? Colors.green
                                          : Colors.red)
                                      : Colors.grey.shade400)
                                  : (isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade400),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child:
                            _showExplanation && isSelected
                                ? Icon(
                                  option.isCorrect ? Icons.check : Icons.close,
                                  color:
                                      option.isCorrect
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                  size: 12, // サイズを小さく
                                )
                                : Text(
                                  String.fromCharCode(
                                    65 + index,
                                  ), // A, B, C, D...
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13, // サイズを小さく
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? (_showExplanation
                                                ? (option.isCorrect
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700)
                                                : AppTheme.primaryColor)
                                            : Colors.grey.shade600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 8), // 間隔を狭く
                    // 選択肢テキスト
                    Expanded(
                      child: Text(
                        option.text,
                        style: GoogleFonts.notoSans(
                          fontSize: 13, // サイズを小さく
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ), // 投票率表示
                    if ((_showExplanation && widget.quiz.showPercentages) ||
                        isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, // パディングを小さく
                          vertical: 2, // パディングを小さく
                        ),
                        decoration: BoxDecoration(
                          color:
                              _showExplanation
                                  ? (option.isCorrect
                                      ? Colors.green.shade50
                                      : Colors.red.shade50)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                _showExplanation
                                    ? (option.isCorrect
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3))
                                    : AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_showExplanation)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.bar_chart,
                                  size: 12, // アイコンサイズ縮小
                                  color:
                                      option.isCorrect
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                ),
                              ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    _showExplanation
                                        ? (option.isCorrect
                                            ? Colors.green.shade700
                                            : Colors.red.shade700)
                                        : AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(int index) {
    final option = widget.quiz.options[index];
    // 正解の選択肢を取得
    final correctOption = widget.quiz.correctOption;

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
          // 正解/不正解ヘッダー
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
          ), // 説明文
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

                // 次の問題へのリンク（オプション）
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                        _selectedOptionIndex = null;
                        _showExplanation = false;
                      });
                    },
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
