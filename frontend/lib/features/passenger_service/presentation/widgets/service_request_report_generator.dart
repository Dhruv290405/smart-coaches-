import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ServiceRequestReportGenerator {
  static Future<void> generate(
    BuildContext context,
    List<Map<String, dynamic>> requests, {
    String title = 'Passenger Service Request Report',
  }) async {
    final String? format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Report Format',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
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
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(requests, title: title);
      } else {
        file = await _buildPdf(requests, title: title);
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

  static Future<File> _buildExcel(List<Map<String, dynamic>> requests,
      {String title = 'Service Request Report'}) async {
    final excel = Excel.createExcel();
    final now = DateTime.now();

    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, title);
    _header(summary, 1, 0, 'Generated: ${_fmt(now)} ${DateFormat('HH:mm:ss').format(now)}');
    _blankRow(summary, 2);

    final total = requests.length;
    final pending = requests.where((r) => r['status'] == 'pending').length;
    final inProgress = requests.where((r) => r['status'] == 'in_progress').length;
    final resolved = requests.where((r) => r['status'] == 'resolved').length;

    _colHeader(summary, 3, 0, 'Metric');
    _colHeader(summary, 3, 1, 'Count');
    _cell(summary, 4, 0, 'Total Requests');
    _cell(summary, 4, 1, '$total');
    _cell(summary, 5, 0, 'Pending');
    _cell(summary, 5, 1, '$pending', color: 'DE980A');
    _cell(summary, 6, 0, 'In Progress');
    _cell(summary, 6, 1, '$inProgress', color: '1A9DF8');
    _cell(summary, 7, 0, 'Resolved');
    _cell(summary, 7, 1, '$resolved', color: '2E7D32');

    _blankRow(summary, 8);
    _colHeader(summary, 9, 0, 'Service Type');
    _colHeader(summary, 9, 1, 'Count');

    final byType = <String, int>{};
    for (final r in requests) {
      final t = r['service_type'] ?? 'unknown';
      byType[t] = (byType[t] ?? 0) + 1;
    }
    int row = 10;
    byType.forEach((type, count) {
      _cell(summary, row, 0, _formatServiceType(type));
      _cell(summary, row, 1, '$count');
      row++;
    });

    final details = excel['Details'];
    final headers = ['ID', 'Train No', 'Coach', 'Seat/Berth', 'Service Type', 'Status', 'Description', 'Passenger', 'Phone', 'Created At', 'Resolved At'];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(details, 0, i, headers[i]);
    }
    for (var r = 0; r < requests.length; r++) {
      final req = requests[r];
      _cell(details, r + 1, 0, '${req['id'] ?? ''}');
      _cell(details, r + 1, 1, '${req['train_no'] ?? ''}');
      _cell(details, r + 1, 2, '${req['coach_no'] ?? ''}');
      _cell(details, r + 1, 3, '${req['seat_berth'] ?? ''}');
      _cell(details, r + 1, 4, _formatServiceType('${req['service_type'] ?? ''}'));
      _cell(details, r + 1, 5, _formatStatus('${req['status'] ?? ''}'),
          color: _statusColor('${req['status'] ?? ''}'));
      _cell(details, r + 1, 6, '${req['description'] ?? ''}');
      _cell(details, r + 1, 7, '${req['passenger_name'] ?? ''}');
      _cell(details, r + 1, 8, '${req['passenger_phone'] ?? ''}');
      _cell(details, r + 1, 9, _fmtDateTime('${req['created_at'] ?? ''}'));
      _cell(details, r + 1, 10, _fmtDateTime('${req['resolved_at'] ?? ''}'));
    }

    for (final sheet in [summary, details]) {
      sheet.setColumnWidth(0, 22);
      sheet.setColumnWidth(1, 18);
      sheet.setColumnWidth(2, 14);
      sheet.setColumnWidth(3, 14);
      sheet.setColumnWidth(4, 18);
      sheet.setColumnWidth(5, 14);
      sheet.setColumnWidth(6, 30);
      sheet.setColumnWidth(7, 18);
      sheet.setColumnWidth(8, 16);
      sheet.setColumnWidth(9, 20);
      sheet.setColumnWidth(10, 20);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'ServiceRequest_Report_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  static Future<File> _buildPdf(List<Map<String, dynamic>> requests,
      {String title = 'Service Request Report'}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final total = requests.length;
    final pending = requests.where((r) => r['status'] == 'pending').length;
    final resolved = requests.where((r) => r['status'] == 'resolved').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('Total: $total  |  Pending: $pending  |  Resolved: $resolved',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 16),

            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Train', 'Coach', 'Seat', 'Type', 'Status', 'Created', 'Resolved'],
              data: requests.map((r) => [
                '${r['id'] ?? ''}',
                '${r['train_no'] ?? ''}',
                '${r['coach_no'] ?? ''}',
                '${r['seat_berth'] ?? ''}',
                _formatServiceType('${r['service_type'] ?? ''}'),
                _formatStatus('${r['status'] ?? ''}'),
                _fmtDateTime('${r['created_at'] ?? ''}'),
                _fmtDateTime('${r['resolved_at'] ?? ''}'),
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
    final fileName = 'ServiceRequest_Report_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _formatServiceType(String type) {
    switch (type) {
      case 'toilet_cleaning': return 'Toilet Cleaning';
      case 'linen_issue': return 'Linen Issue';
      case 'others': return 'Others';
      default: return type;
    }
  }

  static String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }

  static String _statusColor(String status) {
    switch (status) {
      case 'pending': return 'DE980A';
      case 'in_progress': return '1A9DF8';
      case 'resolved': return '2E7D32';
      default: return '000000';
    }
  }

  static String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yy HH:mm').format(dt);
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
            Text('Report Ready', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report generated successfully.', style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 8),
            Text('Includes:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            _reportFeature('Summary (Total / Pending / Resolved)'),
            _reportFeature('Service Type Breakdown'),
            _reportFeature('Full Request Details'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Text(path.split('/').last,
                  style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: ColorConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () {
              Navigator.pop(context);
              OpenFile.open(path);
            },
            child: Text('Open File',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)], text: 'Service Request Report');
            },
            child: Text('Share',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static Widget _reportFeature(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.check, size: 14, color: Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    ),
  );

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
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
