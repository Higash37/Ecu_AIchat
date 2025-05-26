import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownMessageActionButtons extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onPdfPreview;

  const MarkdownMessageActionButtons({
    super.key,
    required this.onCopy,
    required this.onRegenerate,
    required this.onPdfPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(context, Icons.content_copy, 'コピー', onCopy),
        const SizedBox(width: 8),
        _buildActionButton(context, Icons.refresh, '再生成', onRegenerate),
        const SizedBox(width: 8),
        _buildActionButton(
          context,
          Icons.picture_as_pdf,
          'PDFプレビュー',
          onPdfPreview,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
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
