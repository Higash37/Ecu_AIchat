import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz.dart';
import '../pdf/pdf_preview_screen.dart';
import '../../utils/markdown_symbol_utils.dart';
import '../../utils/quiz_generator.dart';
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
      _quizzes.addAll(
        QuizGenerator.generateQuizzesFromMessage(widget.message.text),
      );
    }
  }

  // 理系・古字・上付き・下付き・ギリシャ文字・記号などの変換
  String _convertSuperscript(String text) {
    return convertMarkdownSymbols(text);
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
                  MarkdownMessageHeader(
                    isUserMessage: widget.isUserMessage,
                    createdAt: widget.message.createdAt,
                  ),
                  const SizedBox(height: 16),

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
                            _convertSuperscript(widget.message.text),
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
                        text: _convertSuperscript(widget.message.text),
                        isUserMessage: widget.isUserMessage,
                        animationCompleted: _animationCompleted,
                        quizzes: _quizzes,
                      ),

                  // AIメッセージの場合のアクションボタン
                  if (!widget.isUserMessage)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: MarkdownMessageActionButtons(
                        onCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.message.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('テキストをコピーしました')),
                          );
                        },
                        onRegenerate: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('再生成機能は準備中です')),
                          );
                        },
                        onPdfPreview: () {
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
}
