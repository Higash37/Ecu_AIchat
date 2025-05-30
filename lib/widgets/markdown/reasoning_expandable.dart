import 'package:flutter/material.dart';

class ReasoningExpandable extends StatefulWidget {
  final String reasoning;
  const ReasoningExpandable({required this.reasoning, super.key});
  @override
  State<ReasoningExpandable> createState() => _ReasoningExpandableState();
}

class _ReasoningExpandableState extends State<ReasoningExpandable> {
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
