import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// 見出しの階層構造を視覚的に表現するウィジェット
class HeaderGuideline extends StatelessWidget {
  /// マークダウンテキスト全体
  final String markdownText;

  /// アクティブな状態で表示するかどうか
  final bool isActive;

  const HeaderGuideline({
    Key? key,
    required this.markdownText,
    this.isActive = true,
  }) : super(key: key);

  /// マークダウンから見出し情報を抽出
  List<HeaderInfo> _extractHeaders() {
    final List<HeaderInfo> headers = [];
    final RegExp headerRegExp = RegExp(r'^(#{1,3})\s+(.+)$', multiLine: true);
    final matches = headerRegExp.allMatches(markdownText);

    for (final match in matches) {
      final level = match.group(1)?.length ?? 0;
      final title = match.group(2) ?? '';
      headers.add(HeaderInfo(level: level, title: title));
    }

    return headers;
  }

  @override
  Widget build(BuildContext context) {
    final headers = _extractHeaders();
    if (headers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 見出し階層のガイドライン表示
          ...headers.map(
            (header) => _buildHeaderItem(
              header,
              headers.indexOf(header) == headers.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(HeaderInfo header, bool isLast) {
    final indent = (header.level - 1) * 20.0;
    final isH1 = header.level == 1;
    final isH2 = header.level == 2;

    Color lineColor;
    double lineWidth;

    if (isH1) {
      lineColor = AppTheme.primaryColor;
      lineWidth = 3.0;
    } else if (isH2) {
      lineColor = AppTheme.primaryColor.withOpacity(0.7);
      lineWidth = 2.0;
    } else {
      lineColor = AppTheme.primaryColor.withOpacity(0.5);
      lineWidth = 1.5;
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 導線
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? lineColor : Colors.grey.shade400,
                ),
              ),
              if (!isLast)
                Container(
                  width: lineWidth,
                  height: isH1 ? 40 : (isH2 ? 32 : 24),
                  color: isActive ? lineColor : Colors.grey.shade400,
                ),
            ],
          ),
          const SizedBox(width: 8),

          // 見出しテキスト
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                header.title,
                style: GoogleFonts.notoSans(
                  fontSize: isH1 ? 16 : (isH2 ? 14 : 13),
                  fontWeight: isH1 ? FontWeight.bold : FontWeight.w500,
                  color:
                      isActive
                          ? (isH1
                              ? AppTheme.primaryColor
                              : (isH2 ? Colors.black87 : Colors.black54))
                          : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 見出し情報を格納するクラス
class HeaderInfo {
  final int level;
  final String title;

  HeaderInfo({required this.level, required this.title});
}
