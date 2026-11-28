import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfTheme {
  static final blue = PdfColor.fromInt(0xFF0D47A1);

  static List<pw.Widget> header({
    required String title,
    String? summary,
    DateTime? generatedAt,
    String? division,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    final now = generatedAt ?? DateTime.now();
    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('dd/MM/yyyy HH:mm');
    return [
      pw.Text(
        'Indian Railways — Smart Coach Monitoring System',
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
      ),
      pw.SizedBox(height: 2),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: blue),
          ),
          pw.Text(
            'Generated: ${timeFmt.format(now)} IST',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
      if (periodStart != null && periodEnd != null) ...[
        pw.SizedBox(height: 2),
        pw.Text(
          'Period: ${dateFmt.format(periodStart)} → ${dateFmt.format(periodEnd)}'
          '${division != null && division.isNotEmpty ? "  |  Division: $division" : ""}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ] else if (division != null && division.isNotEmpty) ...[
        pw.SizedBox(height: 2),
        pw.Text('Division: $division', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
      if (summary != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          summary,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 8),
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
