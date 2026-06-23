import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class FsdsReportGenerator {
  static Future<void> generate(BuildContext context, List<FsdsAssetModel> assets, {String title = 'FSDS Monitoring Report'}) async {
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

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: ColorConstants.primary),
              SizedBox(height: 16),
              Text('Generating FSDS Report...', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(assets, title: title);
      } else {
        file = await _buildPdf(assets, title: title);
      }
      
      if (context.mounted) Navigator.pop(context); // close loading

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

  static Future<File> _buildExcel(List<FsdsAssetModel> assets, {String title = 'FSDS Monitoring Report'}) async {
    final excel = Excel.createExcel();
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, title);
    _header(summary, 1, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');

    final headers = ['Asset Name', 'Location', 'Smoke Level', 'Light Value', 'Timestamp', 'Status'];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(summary, 3, i, headers[i]);
    }

    for (var r = 0; r < assets.length; r++) {
      final a = assets[r];
      final row = 4 + r;
      _cell(summary, row, 0, a.assetName);
      _cell(summary, row, 1, a.locName);
      _cell(summary, row, 2, '${a.smokeLevel}');
      _cell(summary, row, 3, '${a.lightValue}');
      _cell(summary, row, 4, a.timestamp);
      _cell(summary, row, 5, a.isSmokeDetected ? 'ALERT' : 'NORMAL');
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'FSDS_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> _buildPdf(List<FsdsAssetModel> assets, {String title = 'FSDS Monitoring Report'}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text(title)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Asset', 'Location', 'Smoke', 'Light', 'Status'],
            data: assets.map((a) => [a.assetName, a.locName, '${a.smokeLevel}', '${a.lightValue}', a.isSmokeDetected ? 'ALERT' : 'NORMAL']).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'FSDS_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

  static void _showSuccess(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Ready'),
        content: Text('FSDS report generated at: $path'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => OpenFile.open(path), child: const Text('Open')),
        ],
      ),
    );
  }

  static Widget _formatOption(BuildContext context, String label, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
