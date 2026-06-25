import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/models/odour_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class OdourReportGenerator {
  static Future<void> generate(BuildContext context, List<OdourCoachModel> coaches, {String title = 'Odour Monitoring Report'}) async {
    final String? format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Report Format', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
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

    final range = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 1)),
      end: DateTime.now(),
    );

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
              Text('Generating Report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(coaches, range, title: title);
      } else {
        file = await _buildPdf(coaches, title: title);
      }
      
      if (context.mounted) Navigator.pop(context);

      if (!context.mounted) return;
      _showSuccess(context, file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<File> _buildExcel(List<OdourCoachModel> coaches, DateTimeRange range, {String title = 'Odour Monitoring Report'}) async {
    final excel = Excel.createExcel();
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, title);
    _header(summary, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _blankRow(summary, 2);

    final headers = ['Coach No.', 'Train', 'Type', 'Toilet Position', 'Status', 'Reading (ppm)'];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(summary, 3, i, headers[i]);
    }

    int row = 4;
    for (final c in coaches) {
      for (final t in c.toilets) {
        _cell(summary, row, 0, c.coachNumber);
        _cell(summary, row, 1, c.trainNumber);
        _cell(summary, row, 2, c.coachType);
        _cell(summary, row, 3, t.position);
        _cell(summary, row, 4, t.status);
        _cell(summary, row, 5, '${t.reading}');
        row++;
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Odour_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> _buildPdf(List<OdourCoachModel> coaches, {String title = 'Odour Monitoring Report'}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Coach', 'Train', 'Type', 'Position', 'Status', 'Reading'],
            data: coaches.expand((c) => c.toilets.map((t) => [c.coachNumber, c.trainNumber, c.coachType, t.position, t.status, '${t.reading} ppm'])).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Odour_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static void _header(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(bold: true, fontSize: 12);
  }

  static void _colHeader(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#1565C0'), fontColorHex: ExcelColor.fromHexString('#FFFFFF'));
  }

  static void _cell(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
  }

  static void _blankRow(Sheet sheet, int row) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('');
  }

  static String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  static void _showSuccess(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Ready'),
        content: Text('Odour monitoring report generated successfully at: $path'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => OpenFile.open(path), child: const Text('Open')),
          ElevatedButton(onPressed: () => Share.shareXFiles([XFile(path)]), child: const Text('Share')),
        ],
      ),
    );
  }

  static Widget _formatOption(BuildContext context, String label, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
