import '../../models/quiz.dart';

/// クイズ生成ユーティリティ
class QuizGenerator {
  static List<Quiz> generateQuizzesFromMessage(String messageText) {
    final List<Quiz> quizzes = [];
    final lowerText = messageText.toLowerCase();
    // プログラミング関連のクイズ
    if (lowerText.contains('flutter') || lowerText.contains('dart')) {
      quizzes.add(_createProgrammingQuiz());
    }
    // 古典文学関連のクイズ
    if (lowerText.contains('古典') || lowerText.contains('文学')) {
      quizzes.add(_createLiteratureQuiz());
    }
    return quizzes;
  }

  static Quiz _createProgrammingQuiz() {
    return Quiz(
      question: 'Flutterのメイン開発言語は何ですか？',
      category: 'プログラミング',
      difficulty: '初級',
      options: [
        QuizOption(
          text: 'JavaScript',
          isCorrect: false,
          explanation:
              'FlutterではDart言語を使用します。JavaScriptはWeb開発で広く使用されていますが、Flutterのメイン言語ではありません。',
        ),
        QuizOption(
          text: 'Dart',
          isCorrect: true,
          explanation:
              '正解です！FlutterはGoogleが開発したDart言語を使用しています。Dartは読みやすく、型安全で、高いパフォーマンスを持つ言語です。',
        ),
        QuizOption(
          text: 'Swift',
          isCorrect: false,
          explanation:
              'SwiftはAppleが開発した言語で、iOSアプリ開発に使用されますが、Flutterではありません。Flutter SDKではDart言語が使われています。',
        ),
        QuizOption(
          text: 'Kotlin',
          isCorrect: false,
          explanation:
              'KotlinはJetBrainsによって開発された言語で、主にAndroidアプリ開発に使用されます。FlutterではDart言語が使われています。',
        ),
      ],
    );
  }

  static Quiz _createLiteratureQuiz() {
    return Quiz(
      question: '古典文学を理解する上で重要なものは次のうちどれ？',
      category: '古典文学',
      difficulty: '中級',
      options: [
        QuizOption(
          text: '背景知識',
          isCorrect: true,
          explanation:
              '正解です！古典文学は、その時代の文化、社会、歴史的背景を深く反映しています。背景知識を持つことで作品の理解が深まります。',
        ),
        QuizOption(
          text: '暗記力',
          isCorrect: false,
          explanation:
              '暗記力も役立つことがありますが、文脈や背景を理解せずに暗記するだけでは、古典文学の本当の魅力や深みを理解することは難しいでしょう。',
        ),
        QuizOption(
          text: '速読能力',
          isCorrect: false,
          explanation:
              '古典文学はむしろじっくりと読み進めることで、文章の美しさやストーリーの奥深さを味わうことができます。速読はあまり重要ではありません。',
        ),
        QuizOption(
          text: '現代語の語彙力',
          isCorrect: false,
          explanation: '現代語の語彙力も大切ですが、古典特有の言い回しや表現を理解することの方が、古典文学を読む上では重要です。',
        ),
      ],
    );
  }
}
