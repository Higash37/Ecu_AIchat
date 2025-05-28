import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz.dart';
import '../pdf/pdf_preview_screen.dart';
import '../../utils/markdown_symbol_utils.dart';
import 'markdown_message_header.dart';
import 'markdown_message_action_buttons.dart';
import 'markdown_message_content.dart';

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
  String? _currentEmotion;

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
    } // AIメッセージの場合、クイズを生成
    /* 一時的にクイズ機能を無効化
    if (!widget.isUserMessage) {
      _quizzes.addAll(
        QuizGenerator.generateQuizzesFromMessage(widget.message.text),
      );
    }
    */
    _currentEmotion =
        widget.message.metadata != null &&
                widget.message.metadata!['emotion'] != null
            ? widget.message.metadata!['emotion'] as String
            : null;
  }

  @override
  void didUpdateWidget(covariant MarkdownMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newEmotion =
        widget.message.metadata != null &&
                widget.message.metadata!['emotion'] != null
            ? widget.message.metadata!['emotion'] as String
            : null;
    if (newEmotion != _currentEmotion) {
      setState(() {
        _currentEmotion = newEmotion;
      });
    }
  }

  // 理系・古字・上付き・下付き・ギリシャ文字・記号などの変換
  String _convertSuperscript(String text) {
    return convertMarkdownSymbols(text);
  }

  @override
  Widget build(BuildContext context) {
    // アイコン・色マップ
    final emotionIconMap = {
      '喜び': Icons.sentiment_satisfied_alt,
      '悲しみ': Icons.sentiment_dissatisfied,
      '怒り': Icons.sentiment_very_dissatisfied,
      '驚き': Icons.sentiment_neutral,
      '恐れ': Icons.sentiment_neutral,
      'ニュートラル': Icons.sentiment_satisfied,
    };
    final emotionColorMap = {
      '喜び': Colors.orange,
      '悲しみ': Colors.blue,
      '怒り': Colors.red,
      '驚き': Colors.purple,
      '恐れ': Colors.teal,
      'ニュートラル': Colors.grey,
    };
    // final icon = emotionIconMap[emotion] ?? Icons.sentiment_satisfied;
    // final color = emotionColorMap[emotion] ?? Colors.grey;

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
                  MarkdownMessageHeader(
                    isUserMessage: widget.isUserMessage,
                    createdAt: widget.message.createdAt,
                  ),
                  const SizedBox(height: 16),

                  // --- チャットバブル内AIアイコン＋creativeアニメーション ---
                  if (!widget.isUserMessage)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                widget.message.metadata != null &&
                                        widget.message.metadata!['creative'] ==
                                            true
                                    ? LinearGradient(
                                      colors: [
                                        Colors.amber,
                                        Colors.pinkAccent,
                                        Colors.cyan,
                                      ],
                                    )
                                    : LinearGradient(
                                      colors: [
                                        Colors.grey.shade200,
                                        Colors.grey.shade400,
                                      ],
                                    ),
                            boxShadow:
                                widget.message.metadata != null &&
                                        widget.message.metadata!['creative'] ==
                                            true
                                    ? [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child:
                                  widget.message.metadata != null &&
                                          widget
                                                  .message
                                                  .metadata!['creative'] ==
                                              true
                                      ? Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 22,
                                        key: const ValueKey('creative'),
                                      )
                                      : Icon(
                                        Icons.smart_toy,
                                        color: Colors.grey.shade700,
                                        size: 22,
                                        key: const ValueKey('normal'),
                                      ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 感情アイコン表示
                              if (!widget.isUserMessage &&
                                  _currentEmotion != null)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutBack,
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        transitionBuilder: (child, anim) {
                                          // 感情ごとにアニメーション切替
                                          switch (_currentEmotion) {
                                            case '喜び':
                                              return ScaleTransition(
                                                scale: anim,
                                                child: child,
                                              );
                                            case '怒り':
                                              return RotationTransition(
                                                turns: anim,
                                                child: child,
                                              );
                                            case '悲しみ':
                                              return FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              );
                                            default:
                                              return FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              );
                                          }
                                        },
                                        child: Icon(
                                          emotionIconMap[_currentEmotion] ??
                                              Icons.sentiment_satisfied,
                                          color:
                                              emotionColorMap[_currentEmotion] ??
                                              Colors.grey,
                                          size: 22,
                                          key: ValueKey(_currentEmotion),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _currentEmotion!,
                                        style: TextStyle(
                                          color:
                                              emotionColorMap[_currentEmotion] ??
                                              Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // メッセージコンテンツ (吹き出しボックスなし)
                              (!widget.isUserMessage && !_animationCompleted)
                                  ? AnimatedTextKit(
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
                                        _convertSuperscript(
                                          widget.message.text,
                                        ),
                                        textStyle: GoogleFonts.notoSans(
                                          fontSize: 15.0,
                                          color: AppTheme.textPrimary,
                                          height: 1.5,
                                        ),
                                        speed: const Duration(milliseconds: 30),
                                      ),
                                    ],
                                  )
                                  : MarkdownMessageContent(
                                    text: _convertSuperscript(
                                      widget.message.text,
                                    ),
                                    isUserMessage: widget.isUserMessage,
                                    animationCompleted: _animationCompleted,
                                    quizzes: _quizzes,
                                  ),

                              // --- reasoning（AIの思考経路）をタップで展開 ---
                              if (!widget.isUserMessage &&
                                  widget.message.metadata != null &&
                                  widget.message.metadata!['creative'] ==
                                      true &&
                                  widget.message.metadata!['reasoning'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _ReasoningExpandable(
                                    reasoning:
                                        widget.message.metadata!['reasoning']
                                            as String,
                                  ),
                                ),

                              // --- creative時のアニメ強化 ---
                              if (!widget.isUserMessage &&
                                  widget.message.metadata != null &&
                                  widget.message.metadata!['creative'] == true)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 600),
                                    opacity: 1.0,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.bolt,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ひらめき！',
                                          style: TextStyle(
                                            color: Colors.amber.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber,
                                                Colors.pinkAccent,
                                                Colors.cyan,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(
                                                  0.5,
                                                ),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // --- 知識グラフ可視化UI ---
                              if (!widget.isUserMessage &&
                                  widget.message.metadata != null &&
                                  widget.message.metadata!['knowledge_graph'] !=
                                      null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _KnowledgeGraphMiniView(
                                    graphData:
                                        widget
                                            .message
                                            .metadata!['knowledge_graph'],
                                  ),
                                ),

                              // AIメッセージの場合のアクションボタン
                              if (!widget.isUserMessage)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: MarkdownMessageActionButtons(
                                    onCopy: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: widget.message.text,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('テキストをコピーしました'),
                                        ),
                                      );
                                    },
                                    onRegenerate: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('再生成機能は準備中です'),
                                        ),
                                      );
                                    },
                                    onPdfPreview: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PdfPreviewScreen(
                                                markdownText:
                                                    widget.message.text,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ), // セパレータ
                            ],
                          ),
                        ),
                      ],
                    ),

                  // セパレータ
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
}

// reasoning展開用ウィジェット
class _ReasoningExpandable extends StatefulWidget {
  final String reasoning;
  const _ReasoningExpandable({required this.reasoning});
  @override
  State<_ReasoningExpandable> createState() => _ReasoningExpandableState();
}

class _ReasoningExpandableState extends State<_ReasoningExpandable> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _expanded ? Icons.expand_less : Icons.psychology,
              color: Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState:
                    _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                firstChild: Text(
                  'AIの思考経路を表示',
                  style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
                ),
                secondChild: Text(
                  widget.reasoning,
                  style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 簡易知識グラフ可視化ウィジェット
class _KnowledgeGraphMiniView extends StatelessWidget {
  final dynamic graphData; // MapやList形式を想定
  const _KnowledgeGraphMiniView({required this.graphData});
  @override
  Widget build(BuildContext context) {
    // 超簡易: ノード名と関係線をリストで表示（本格可視化は今後拡張）
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
