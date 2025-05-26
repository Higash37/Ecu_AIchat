import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz.dart';

class QuizOptionItem extends StatelessWidget {
  final Quiz quiz;
  final int index;
  final bool isSelected;
  final bool showExplanation;
  final int? selectedOptionIndex;
  final void Function(int) onTap;

  const QuizOptionItem({
    super.key,
    required this.quiz,
    required this.index,
    required this.isSelected,
    required this.showExplanation,
    required this.selectedOptionIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final option = quiz.options[index];
    final Map<int, int> votePercentages = quiz.getVotePercentages();
    final int percentage = votePercentages[index] ?? 0;
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;
    if (showExplanation && isSelected) {
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: showExplanation ? null : () => onTap(index),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (showExplanation && isSelected)
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
              if (showExplanation)
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
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color:
                            showExplanation
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
                              showExplanation
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
                            showExplanation && isSelected
                                ? Icon(
                                  option.isCorrect ? Icons.check : Icons.close,
                                  color:
                                      option.isCorrect
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                  size: 12,
                                )
                                : Text(
                                  String.fromCharCode(65 + index),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? (showExplanation
                                                ? (option.isCorrect
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700)
                                                : AppTheme.primaryColor)
                                            : Colors.grey.shade600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.text,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                    if ((showExplanation && quiz.showPercentages) || isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              showExplanation
                                  ? (option.isCorrect
                                      ? Colors.green.shade50
                                      : Colors.red.shade50)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                showExplanation
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
                            if (showExplanation)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.bar_chart,
                                  size: 12,
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
                                    showExplanation
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
}
