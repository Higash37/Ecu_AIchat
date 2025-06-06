import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../ai_ui/quiz.dart';

pw.Document buildKumonStylePdf({
  required String title,
  required String name,
  required List<Question> questions,
  required List<Answer> answers,
  String? date,
}) {
  final pdf = pw.Document();

  // 1ページ目：問題
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(28),
      build:
          (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ヘッダー（タイトル・名前・日付）
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1.2, color: PdfColors.grey700),
                  borderRadius: pw.BorderRadius.circular(8),
                  color: PdfColors.grey200,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 100,
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              width: 1,
                              color: PdfColors.grey600,
                            ),
                            borderRadius: pw.BorderRadius.circular(4),
                            color: PdfColors.white,
                          ),
                          child: pw.Text(
                            '名前:',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        if (date != null)
                          pw.Container(
                            width: 70,
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 1,
                                color: PdfColors.grey600,
                              ),
                              borderRadius: pw.BorderRadius.circular(4),
                              color: PdfColors.white,
                            ),
                            child: pw.Text(
                              '日付:',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1.2, color: PdfColors.grey700),
              pw.SizedBox(height: 6),
              // 問題リスト
              ...questions.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final q = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 18),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.8, color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                    color: PdfColors.white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 28,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '【$idx】',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              q.question,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      if (q.options != null)
                        pw.Column(
                          children:
                              q.options!
                                  .map(
                                    (opt) => pw.Row(
                                      children: [
                                        pw.Container(
                                          width: 16,
                                          height: 16,
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(
                                              width: 1,
                                              color: PdfColors.grey600,
                                            ),
                                            borderRadius: pw
                                                .BorderRadius.circular(2),
                                          ),
                                        ),
                                        pw.SizedBox(width: 8),
                                        pw.Text(
                                          opt,
                                          style: pw.TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      if (q.options == null)
                        pw.Container(
                          height: 24,
                          margin: const pw.EdgeInsets.only(top: 8, right: 32),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                width: 1.1,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              pw.Divider(thickness: 1.2, color: PdfColors.grey700),
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '【問題ページ終わり】',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          ),
    ),
  );

  // 2ページ目：解答・解説
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(28),
      build:
          (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1.2,
                    color: PdfColors.blueGrey800,
                  ),
                  borderRadius: pw.BorderRadius.circular(8),
                  color: PdfColors.blue50,
                ),
                child: pw.Text(
                  '【解答・解説】',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 14),
              ...answers.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final a = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 14),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 0.8,
                      color: PdfColors.blueGrey200,
                    ),
                    borderRadius: pw.BorderRadius.circular(6),
                    color: PdfColors.white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 28,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '【$idx】',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey800,
                              ),
                            ),
                          ),
                          pw.Text(
                            '答え: ${a.answer}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.blue,
                            ),
                          ),
                        ],
                      ),
                      if (a.explanation != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4, left: 28),
                          child: pw.Text(
                            '解説: ${a.explanation}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              pw.Divider(thickness: 1.2, color: PdfColors.blueGrey800),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '【解答ページ終わり】',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blueGrey400,
                  ),
                ),
              ),
            ],
          ),
    ),
  );

  return pdf;
}
