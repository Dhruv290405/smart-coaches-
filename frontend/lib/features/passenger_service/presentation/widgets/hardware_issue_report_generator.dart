import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class HardwareIssueReportGenerator {
  static Future<void> generate(
    BuildContext context,
    List<Map<String, dynamic>> issues, {
    Map<String, dynamic>? report,
  }) async {
    final String? format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Report Format',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _formatOption(ctx, 'Excel Report', 'xlsx', Icons.table_chart, Colors.green),
            const SizedBox(height: 12),
            _formatOption(ctx, 'PDF Report', 'pdf', Icons.picture_as_pdf, Colors.red),
          ],
        ),
      ),
    );

    if (format == null) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ColorConstants.primary),
              const SizedBox(height: 16),
              Text('Generating Report...',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(issues, report: report);
      } else {
        file = await _buildPdf(issues, report: report);
      }

      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      _showSuccess(context, file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<File> _buildExcel(List<Map<String, dynamic>> issues,
      {Map<String, dynamic>? report}) async {
    final excel = Excel.createExcel();
    final now = DateTime.now();

    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, 'Passenger Service Request');
    _header(summary, 1, 0, 'Generated: ${_fmt(now)} ${DateFormat('HH:mm:ss').format(now)}');
    _blankRow(summary, 2);

    final total = report?['totalCount'] ?? issues.length;
    final open = report?['openCount'] ?? 0;
    final closed = report?['closedCount'] ?? 0;
    final cleaning = report?['cleaningCount'] ?? 0;
    final linen = report?['linenCount'] ?? 0;
    final avg = report?['avgResponseSeconds'];

    _colHeader(summary, 3, 0, 'Metric');
    _colHeader(summary, 3, 1, 'Count');
    _cell(summary, 4, 0, 'Total Issues');
    _cell(summary, 4, 1, '$total');
    _cell(summary, 5, 0, 'Open');
    _cell(summary, 5, 1, '$open', color: 'DE980A');
    _cell(summary, 6, 0, 'Closed');
    _cell(summary, 6, 1, '$closed', color: '2E7D32');
    _cell(summary, 7, 0, 'Cleaning Issues');
    _cell(summary, 7, 1, '$cleaning', color: '1A9DF8');
    _cell(summary, 8, 0, 'Linen Issues');
    _cell(summary, 8, 1, '$linen', color: '7B1FA2');
    _cell(summary, 9, 0, 'Avg Response Time');
    _cell(summary, 9, 1, avg != null ? _fmtResponse(avg as int) : '-');

    _blankRow(summary, 10);
    _colHeader(summary, 11, 0, 'Issue Type');
    _colHeader(summary, 11, 1, 'Count');

    final byType = <String, int>{};
    for (final r in issues) {
      final t = r['issue_type'] ?? 'unknown';
      byType[t] = (byType[t] ?? 0) + 1;
    }
    int row = 12;
    byType.forEach((type, count) {
      _cell(summary, row, 0, _formatType(type));
      _cell(summary, row, 1, '$count');
      row++;
    });

    final details = excel['Details'];
    final headers = ['Train No', 'Coach', 'Compartment', 'Issue Type', 'Status', 'Opened At', 'Closed At', 'Response Time'];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(details, 0, i, headers[i]);
    }
    for (var r = 0; r < issues.length; r++) {
      final req = issues[r];
      _cell(details, r + 1, 0, '${req['train_no'] ?? ''}');
      _cell(details, r + 1, 1, '${req['coach_no'] ?? ''}');
      _cell(details, r + 1, 2, '${req['compartment_no'] ?? ''}');
      _cell(details, r + 1, 3, _formatType('${req['issue_type'] ?? ''}'));
      _cell(details, r + 1, 4, '${req['status'] == 'closed' ? 'Closed' : 'Open'}',
          color: req['status'] == 'closed' ? '2E7D32' : 'DE980A');
      _cell(details, r + 1, 5, _fmtDateTime('${req['opened_at'] ?? ''}'));
      _cell(details, r + 1, 6, _fmtDateTime('${req['closed_at'] ?? ''}'));
      _cell(details, r + 1, 7, _fmtResponse(req['response_seconds'] as int?));
    }

    for (final sheet in [summary, details]) {
      sheet.setColumnWidth(0, 22);
      sheet.setColumnWidth(1, 18);
      sheet.setColumnWidth(2, 18);
      sheet.setColumnWidth(3, 14);
      sheet.setColumnWidth(4, 14);
      sheet.setColumnWidth(5, 20);
      sheet.setColumnWidth(6, 20);
      sheet.setColumnWidth(7, 18);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'PassengerServiceRequest_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  static Future<File> _buildPdf(List<Map<String, dynamic>> issues,
      {Map<String, dynamic>? report}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final total = report?['totalCount'] ?? issues.length;
    final open = report?['openCount'] ?? 0;
    final closed = report?['closedCount'] ?? 0;
    final cleaning = report?['cleaningCount'] ?? 0;
    final linen = report?['linenCount'] ?? 0;
    final avg = report?['avgResponseSeconds'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Passenger Service Request',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text(
                'Total: $total  |  Open: $open  |  Closed: $closed  |  Cleaning: $cleaning  |  Linen: $linen  |  Avg Response: ${avg != null ? _fmtResponse(avg as int) : '-'}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 16),

            pw.TableHelper.fromTextArray(
              headers: ['Train', 'Coach', 'Comp.', 'Type', 'Status', 'Opened', 'Closed', 'Response'],
              data: issues.map((r) => [
                '${r['train_no'] ?? ''}',
                '${r['coach_no'] ?? ''}',
                '${r['compartment_no'] ?? ''}',
                _formatType('${r['issue_type'] ?? ''}'),
                r['status'] == 'closed' ? 'Closed' : 'Open',
                _fmtDateTime('${r['opened_at'] ?? ''}'),
                _fmtDateTime('${r['closed_at'] ?? ''}'),
                _fmtResponse(r['response_seconds'] as int?),
              ]).toList(),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.Text('Report generated on ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'PassengerServiceRequest_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _formatType(String type) {
    switch (type) {
      case 'linen': return 'Linen';
      case 'cleaning': return 'Cleaning';
      default: return type;
    }
  }

  static String _fmtResponse(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)} min';
    return '${(seconds / 3600).toStringAsFixed(2)} hr';
  }

  static String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
    } catch (_) {
      return raw.isNotEmpty ? raw : '-';
    }
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static void _header(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(bold: true, fontSize: 13, fontColorHex: ExcelColor.fromHexString('#1565C0'));
  }

  static void _colHeader(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 11,
    );
  }

  static void _cell(Sheet sheet, int row, int col, String text, {String? color}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    if (color != null) {
      cell.cellStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#$color'), bold: true, fontSize: 11);
    } else {
      cell.cellStyle = CellStyle(fontSize: 11);
    }
  }

  static void _blankRow(Sheet sheet, int row) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('');
  }

  static void _showSuccess(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text('Report Ready', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger service request report generated successfully.',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Text(path.split('/').last,
                  style: const TextStyle(fontSize: 11, color: ColorConstants.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: const TextStyle(color: ColorConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () {
              Navigator.pop(context);
              OpenFile.open(path);
            },
            child: const Text('Open File',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)], text: 'Passenger Service Request');
            },
            child: const Text('Share',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static Widget _formatOption(
      BuildContext context, String label, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}