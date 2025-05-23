import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pdf;

class PdfPreviewScreen extends StatelessWidget {
  final String markdownText;
  final String? caution;
  final String? hint;
  final String? praise;
  const PdfPreviewScreen({
    super.key,
    required this.markdownText,
    this.caution,
    this.hint,
    this.praise,
  });

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
                          (pw.Context context) => pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                flex: 7,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    markdownText,
                                    style: const pw.TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 3,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    if (caution != null && caution!.isNotEmpty)
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: pw.Text(
                                          caution!,
                                          style: pw.TextStyle(
                                            color: pdf.PdfColor.fromHex(
                                              '#B71C1C',
                                            ),
                                            // 濃い赤
                                            decoration:
                                                pw.TextDecoration.underline,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (hint != null && hint!.isNotEmpty)
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: pw.Text(
                                          hint!,
                                          style: pw.TextStyle(
                                            color: pdf.PdfColor.fromHex(
                                              '#00FF00',
                                            ),
                                            // 緑（赤シートで隠れる色例）
                                            decoration:
                                                pw.TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    if (praise != null && praise!.isNotEmpty)
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: pw.Text(
                                          praise!,
                                          style: pw.TextStyle(
                                            color: pdf.PdfColor.fromHex(
                                              '#222222',
                                            ),
                                            fontWeight: pw.FontWeight.bold,
                                            decoration:
                                                pw.TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
