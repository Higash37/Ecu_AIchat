import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedTypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback? onFinished;
  final bool enableAnimation; // 新しいプロパティ

  const AnimatedTypingText({
    required this.text,
    required this.style,
    this.onFinished,
    this.enableAnimation = true, // デフォルトでアニメーションを有効化
    super.key,
  });

  @override
  State<AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<AnimatedTypingText> {
  String _displayText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _startAnimation();
    } else {
      _displayText = widget.text; // アニメーションを無効化した場合、全テキストを即座に表示
    }
  }

  void _startAnimation() {
    const chunkSize = 3;
    int index = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (index >= widget.text.length) {
        timer.cancel();
        widget.onFinished?.call();
      } else {
        setState(() {
          _displayText = widget.text.substring(
            0,
            (index + chunkSize).clamp(0, widget.text.length),
          );
        });
        index += chunkSize;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style);
  }
}
