class QuizOption {
  final String text;
  final bool isCorrect;
  final String explanation;

  const QuizOption({
    required this.text,
    required this.isCorrect,
    required this.explanation,
  });
}

class Quiz {
  final String question;
  final List<QuizOption> options;
  final bool showPercentages; // 投票率を表示するかどうか
  final String? category; // クイズのカテゴリー（例: 「プログラミング」「歴史」など）
  final String? difficulty; // 難易度（例: 「初級」「中級」「上級」）

  const Quiz({
    required this.question,
    required this.options,
    this.showPercentages = true,
    this.category,
    this.difficulty,
  });

  // 正解のオプションを取得
  QuizOption? get correctOption {
    for (var option in options) {
      if (option.isCorrect) return option;
    }
    return null;
  }

  // 各オプションの投票率を算出（ランダムまたは実際の統計から計算）
  Map<int, int> getVotePercentages() {
    final Map<int, int> percentages = {};
    // サンプル投票率（本番では実際の統計データから計算）
    final List<int> sampleVotes = [55, 25, 15, 5]; // 合計100%

    for (int i = 0; i < options.length; i++) {
      percentages[i] = i < sampleVotes.length ? sampleVotes[i] : 0;
    }
    return percentages;
  }
}

class Question {
  final String question;
  final List<String>? options;
  Question({required this.question, this.options});
}

class Answer {
  final String answer;
  final String? explanation;
  Answer({required this.answer, this.explanation});
}
