import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String markdownText;
  const PdfPreviewScreen({super.key, required this.markdownText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDFプレビュー')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth * 0.6;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: PdfPreview(
                build: (format) async {
                  final doc = pw.Document();
                  doc.addPage(
                    pw.Page(
                      build:
                          (pw.Context context) =>
                              pw.Center(child: pw.Text(markdownText)),
                    ),
                  );
                  return doc.save();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
