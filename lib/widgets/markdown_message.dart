import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/quiz.dart';
import 'quiz_widget.dart';
import 'header_guideline.dart';
import 'pdf_preview_screen.dart';

class MarkdownMessage extends StatefulWidget {
  final types.TextMessage message;
  final bool isUserMessage;

  const MarkdownMessage({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  @override
  State<MarkdownMessage> createState() => _MarkdownMessageState();
}

class _MarkdownMessageState extends State<MarkdownMessage> {
  bool _animationCompleted = false;
  final List<Quiz> _quizzes = [];

  // テキストが見出しを含むかどうかをチェック
  bool _hasHeaders(String text) {
    // MarkdownのH1-H3見出しパターンをチェック（# タイトル、## タイトル、### タイトル）
    final RegExp headerRegExp = RegExp(r'^(#{1,3})\s+(.+)$', multiLine: true);
    return headerRegExp.hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    // AIメッセージで、かつ新しいメッセージの場合はアニメーション表示
    final isNewMessage =
        DateTime.now().millisecondsSinceEpoch -
            (widget.message.createdAt ?? 0) <
        1000;

    if (!widget.isUserMessage && isNewMessage) {
      // タイピングアニメーション終了後に完全なテキストを表示するために遅延実行
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _animationCompleted = true;
          });
        }
      });
    } else {
      _animationCompleted = true;
    }

    // AIメッセージの場合、クイズを生成
    if (!widget.isUserMessage) {
      _generateQuizzesFromMessage();
    }
  }

  // メッセージ内容からクイズを生成
  void _generateQuizzesFromMessage() {
    // 本文からテーマを抽出し、関連するクイズを生成
    final String messageText = widget.message.text.toLowerCase();

    // プログラミング関連のクイズ
    if (messageText.contains('flutter') || messageText.contains('dart')) {
      _quizzes.add(_createProgrammingQuiz());
    }

    // 古典文学関連のクイズ
    if (messageText.contains('古典') || messageText.contains('文学')) {
      _quizzes.add(_createLiteratureQuiz());
    }
  }

  // プログラミング関連のクイズを作成
  Quiz _createProgrammingQuiz() {
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

  // 古典文学関連のクイズを作成
  Quiz _createLiteratureQuiz() {
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

  // 時間フォーマット用のヘルパーメソッド
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 理系・古字・上付き・下付き・ギリシャ文字・記号などの変換
  String _convertSuperscript(String text) {
    // 上付き数字
    text = text.replaceAllMapped(RegExp(r'\^0'), (m) => '⁰');
    text = text.replaceAllMapped(RegExp(r'\^1'), (m) => '¹');
    text = text.replaceAllMapped(RegExp(r'\^2'), (m) => '²');
    text = text.replaceAllMapped(RegExp(r'\^3'), (m) => '³');
    text = text.replaceAllMapped(RegExp(r'\^4'), (m) => '⁴');
    text = text.replaceAllMapped(RegExp(r'\^5'), (m) => '⁵');
    text = text.replaceAllMapped(RegExp(r'\^6'), (m) => '⁶');
    text = text.replaceAllMapped(RegExp(r'\^7'), (m) => '⁷');
    text = text.replaceAllMapped(RegExp(r'\^8'), (m) => '⁸');
    text = text.replaceAllMapped(RegExp(r'\^9'), (m) => '⁹');
    text = text.replaceAllMapped(RegExp(r'\^n'), (m) => 'ⁿ');
    text = text.replaceAllMapped(RegExp(r'\^\-1'), (m) => '⁻¹');
    // 下付き数字
    text = text.replaceAllMapped(RegExp(r'_0'), (m) => '₀');
    text = text.replaceAllMapped(RegExp(r'_1'), (m) => '₁');
    text = text.replaceAllMapped(RegExp(r'_2'), (m) => '₂');
    text = text.replaceAllMapped(RegExp(r'_3'), (m) => '₃');
    text = text.replaceAllMapped(RegExp(r'_4'), (m) => '₄');
    text = text.replaceAllMapped(RegExp(r'_5'), (m) => '₅');
    text = text.replaceAllMapped(RegExp(r'_6'), (m) => '₆');
    text = text.replaceAllMapped(RegExp(r'_7'), (m) => '₇');
    text = text.replaceAllMapped(RegExp(r'_8'), (m) => '₈');
    text = text.replaceAllMapped(RegExp(r'_9'), (m) => '₉');
    text = text.replaceAllMapped(RegExp(r'_n'), (m) => 'ₙ');
    // ギリシャ文字
    text = text.replaceAll('alpha', 'α');
    text = text.replaceAll('beta', 'β');
    text = text.replaceAll('gamma', 'γ');
    text = text.replaceAll('delta', 'δ');
    text = text.replaceAll('epsilon', 'ε');
    text = text.replaceAll('zeta', 'ζ');
    text = text.replaceAll('eta', 'η');
    text = text.replaceAll('theta', 'θ');
    text = text.replaceAll('iota', 'ι');
    text = text.replaceAll('kappa', 'κ');
    text = text.replaceAll('lambda', 'λ');
    text = text.replaceAll('mu', 'μ');
    text = text.replaceAll('nu', 'ν');
    text = text.replaceAll('xi', 'ξ');
    text = text.replaceAll('omicron', 'ο');
    text = text.replaceAll('pi', 'π');
    text = text.replaceAll('rho', 'ρ');
    text = text.replaceAll('sigma', 'σ');
    text = text.replaceAll('tau', 'τ');
    text = text.replaceAll('upsilon', 'υ');
    text = text.replaceAll('phi', 'φ');
    text = text.replaceAll('chi', 'χ');
    text = text.replaceAll('psi', 'ψ');
    text = text.replaceAll('omega', 'ω');
    // 数学記号
    text = text.replaceAll('sqrt', '√');
    text = text.replaceAll('infinity', '∞');
    text = text.replaceAll('≒', '≒');
    text = text.replaceAll('≠', '≠');
    text = text.replaceAll('≡', '≡');
    text = text.replaceAll('<=', '≤');
    text = text.replaceAll('>=', '≥');
    text = text.replaceAll('->', '→');
    text = text.replaceAll('<-', '←');
    text = text.replaceAll('<->', '↔');
    text = text.replaceAll('+-', '±');
    text = text.replaceAll('degree', '°');
    // 古字
    text = text.replaceAll('ゑ', 'ゑ');
    text = text.replaceAll('ゐ', 'ゐ');
    text = text.replaceAll('ヱ', 'ヱ');
    text = text.replaceAll('ヰ', 'ヰ');
    // その他
    text = text.replaceAll('hbar', 'ℏ');
    text = text.replaceAll('angstrom', 'Å');
    text = text.replaceAll('ohm', 'Ω');
    text = text.replaceAll('delta', 'Δ'); // 大文字
    text = text.replaceAll('Delta', 'Δ');
    text = text.replaceAll('Sigma', 'Σ');
    text = text.replaceAll('Pi', 'Π');
    text = text.replaceAll('Omega', 'Ω');
    text = text.replaceAll('Gamma', 'Γ');
    text = text.replaceAll('Theta', 'Θ');
    text = text.replaceAll('Lambda', 'Λ');
    text = text.replaceAll('Phi', 'Φ');
    text = text.replaceAll('Psi', 'Ψ');
    text = text.replaceAll('Xi', 'Ξ');
    return text;
  }

  // カスタムマークダウンビルダー
  MarkdownStyleSheet _getMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      // 本文テキスト
      p: GoogleFonts.notoSans(
        fontSize: 15.0,
        height: 1.5,
        color: AppTheme.textPrimary,
      ),
      // 見出し
      h1: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor,
        height: 1.6,
      ),
      h1Padding: const EdgeInsets.only(top: 24, bottom: 12),
      h2: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
        height: 1.5,
      ),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16),
      h3: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
        height: 1.5,
      ),
      h3Padding: const EdgeInsets.only(top: 16, bottom: 8, left: 32),
      // 段落のパディング
      pPadding: const EdgeInsets.only(top: 8, bottom: 8),
      // コード
      code: GoogleFonts.jetBrainsMono(
        backgroundColor: const Color(0xFFf6f8fa),
        fontSize: 14,
        color: const Color(0xFF24292e),
      ),
      // コードブロック
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFf6f8fa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      // 引用
      blockquote: GoogleFonts.notoSans(
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade700,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.5),
            width: 4,
          ),
        ),
        color: AppTheme.primaryColor.withOpacity(0.05),
      ),
      blockquotePadding: const EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      // リスト
      listBullet: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      listBulletPadding: const EdgeInsets.only(right: 8),
      listIndent: 24.0,
      // 水平線
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      // リンク
      a: GoogleFonts.notoSans(
        color: AppTheme.primaryColor,
        decoration: TextDecoration.underline,
      ),
      // テーブル
      tableHead: const TextStyle(fontWeight: FontWeight.bold),
      tableBorder: TableBorder.all(color: Colors.grey.shade300, width: 1),
    );
  }

  /// マークダウンテキストを表示するウィジェットを生成
  Widget _buildMarkdownContent() {
    final convertedText = _convertSuperscript(widget.message.text);

    if (!widget.isUserMessage && !_animationCompleted) {
      // AIメッセージでアニメーション表示中
      return AnimatedTextKit(
        isRepeatingAnimation: false,
        totalRepeatCount: 1,
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
        onFinished: () {
          setState(() {
            _animationCompleted = true;
          });
        },
        animatedTexts: [
          TypewriterAnimatedText(
            convertedText,
            textStyle: GoogleFonts.notoSans(
              fontSize: 15.0,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            speed: const Duration(milliseconds: 30),
          ),
        ],
      );
    } else {
      // ユーザーメッセージまたはアニメーション完了後のAIメッセージ
      return widget.isUserMessage
          // ユーザーメッセージ（通常テキスト）
          ? Text(
            widget.message.text,
            style: GoogleFonts.notoSans(
              fontSize: 15.0,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          )
          // AIメッセージ（マークダウン対応）
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // マークダウンテキスト（見出しのガイドライン付き）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側：見出しガイドライン（階層構造を視覚的に表現）
                  if (_hasHeaders(widget.message.text))
                    SizedBox(
                      width: 40, // 導線部分の幅
                      child: HeaderGuideline(markdownText: widget.message.text),
                    ),

                  // 右側：マークダウンコンテンツ
                  Expanded(
                    child: MarkdownBody(
                      data: convertedText,
                      styleSheet: _getMarkdownStyleSheet(),
                      selectable: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          // リンクタップ処理
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('リンクが開かれました: $href')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              // クイズセクション（存在する場合）
              if (_quizzes.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    '理解度チェック',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                ...List.generate(
                  _quizzes.length,
                  (index) => QuizWidget(quiz: _quizzes[index]),
                ),
              ],
            ],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // PCとタブレット用の条件（画面幅が広い場合）
        final isWideScreen = constraints.maxWidth > 600;
        final contentWidth =
            isWideScreen
                ? constraints.maxWidth *
                    0.7 // 画面幅の70%
                : constraints.maxWidth; // スマホでは全幅

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メッセージヘッダー
                  Row(
                    children: [
                      // アバター
                      CircleAvatar(
                        backgroundColor:
                            widget.isUserMessage
                                ? Colors.grey.shade300
                                : AppTheme.primaryColor,
                        radius: 16,
                        child: Icon(
                          widget.isUserMessage ? Icons.person : Icons.smart_toy,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 送信者名
                      Text(
                        widget.isUserMessage ? 'あなた' : 'AI教材チャット',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 時間
                      Text(
                        _formatTime(
                          DateTime.fromMillisecondsSinceEpoch(
                            widget.message.createdAt ?? 0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // メッセージコンテンツ (吹き出しボックスなし)
                  _buildMarkdownContent(),

                  // AIメッセージの場合のアクションボタン
                  if (!widget.isUserMessage)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            context,
                            Icons.content_copy,
                            'コピー',
                            onPressed: () {
                              // コピー機能の実装
                              Clipboard.setData(
                                ClipboardData(text: widget.message.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('テキストをコピーしました')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            Icons.refresh,
                            '再生成',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('再生成機能は準備中です')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            Icons.picture_as_pdf,
                            'PDFプレビュー',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PdfPreviewScreen(
                                        markdownText: widget.message.text,
                                      ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ), // セパレータ
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
