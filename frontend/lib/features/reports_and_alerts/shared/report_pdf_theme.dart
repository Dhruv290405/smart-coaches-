import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfTheme {
  static final blue = PdfColor.fromInt(0xFF0D47A1);

  static List<pw.Widget> header({
    required String title,
    String? summary,
    DateTime? generatedAt,
  }) {
    final now = generatedAt ?? DateTime.now();
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: blue,
            ),
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
      if (summary != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          summary,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
      pw.SizedBox(height: 16),
    ];
  }

  static pw.TextStyle get sectionTitle => pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: blue,
      );

  static pw.TextStyle get tableHeader => pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      );

  static final tableHeaderDecoration = pw.BoxDecoration(color: blue);
  static final tableCellStyle = pw.TextStyle(fontSize: 8);
}
