import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class AcpReportGenerator {
  static Future<void> generate(BuildContext context, List<AcpCoachModel> coaches, {String title = 'ACP Monitoring Report'}) async {
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

    // Show loading
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
              const SizedBox(height: 4),
              Text(
                '${_fmt(range.start)} → ${_fmt(range.end)}',
                style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary),
              ),
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

  static Future<File> _buildExcel(List<AcpCoachModel> coaches, DateTimeRange range, {String title = 'ACP Monitoring Report'}) async {
    final excel = Excel.createExcel();
    final now = DateTime.now();

    // ─── Sheet 1: Summary ────────────────────────────────────────────────────
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, title);
    _header(summary, 1, 0, 'Generated: ${_fmt(now)} ${DateFormat('HH:mm:ss').format(now)}');
    _header(summary, 2, 0, 'Total Coaches in Report: ${coaches.length}');
    _blankRow(summary, 3);

    final headers = [
      'Coach No.', 'Tech Coach (Unique ID)', 'Device ID', 'Train No.',
      'Location', 'Status', 'Today Count', 'Total Count', 'Last Trigger', 'Last Updated',
    ];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(summary, 4, i, headers[i]);
    }

    for (var r = 0; r < coaches.length; r++) {
      final c = coaches[r];
      final row = 5 + r;
      _cell(summary, row, 0, c.coachNumber);
      _cell(summary, row, 1, c.sensorId);
      _cell(summary, row, 2, c.deviceId);
      _cell(summary, row, 3, c.trainNo);
      _cell(summary, row, 4, c.location);
      _cell(summary, row, 5, c.statusLabel.toUpperCase(),
          color: c.isChainPulled ? 'D32F2F' : '2E7D32');
      _cell(summary, row, 6, '${c.todayCount}',
          color: c.todayCount > 0 ? 'D32F2F' : null);
      _cell(summary, row, 7, '${c.totalCount}');
      _cell(summary, row, 8, c.lastTrigger ?? 'N/A',
          color: c.lastTrigger != null ? 'D32F2F' : null);
      _cell(summary, row, 9, c.updateTime);
    }

    final totalRow = 5 + coaches.length + 1;
    _colHeader(summary, totalRow, 0, 'Total Coaches');
    _cell(summary, totalRow, 1, '${coaches.length}');
    _colHeader(summary, totalRow + 1, 0, 'Pulled');
    _cell(summary, totalRow + 1, 1, '${coaches.where((c) => c.isChainPulled).length}', color: 'D32F2F');
    _colHeader(summary, totalRow + 2, 0, 'Not Pulled');
    _cell(summary, totalRow + 2, 1, '${coaches.where((c) => !c.isChainPulled).length}', color: '2E7D32');

    // Set column widths
    for (final sheet in [summary]) {
      sheet.setColumnWidth(0, 16);
      sheet.setColumnWidth(1, 20);
      sheet.setColumnWidth(2, 18);
      sheet.setColumnWidth(3, 14);
      sheet.setColumnWidth(4, 16);
      sheet.setColumnWidth(5, 14);
      sheet.setColumnWidth(6, 14);
      sheet.setColumnWidth(7, 22);
      sheet.setColumnWidth(8, 22);
      sheet.setColumnWidth(9, 22);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'ACP_Report_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  static Future<File> _buildPdf(List<AcpCoachModel> coaches, {String title = 'ACP Monitoring Report'}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final pulledCoaches = coaches.where((c) => c.isChainPulled).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(now), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text('Total Coaches: ${coaches.length}  |  Pulled: ${pulledCoaches.length}  |  Not Pulled: ${coaches.length - pulledCoaches.length}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 16),

            // All coaches table
            pw.Text('Coach Summary', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Coach No.', 'Tech Coach ID', 'Device ID', 'Train No.', 'Location', 'Status', 'Today', 'Total', 'Last Trigger'],
              data: coaches.map((c) => [
                c.coachNumber,
                c.sensorId,
                c.deviceId,
                c.trainNo,
                c.location,
                c.statusLabel.toUpperCase(),
                '${c.todayCount}',
                '${c.totalCount}',
                c.lastTrigger != null
                    ? _fmtDatetime(c.lastTrigger!)
                    : 'N/A',
              ]).toList(),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 24,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
              },
            ),

            if (pulledCoaches.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text('Chain Pulled Coaches', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Coach No.', 'Tech Coach ID', 'Device ID', 'Train No.', 'Location', 'Today', 'Total', 'Last Trigger', 'Last Updated'],
                data: pulledCoaches.map((c) => [
                  c.coachNumber,
                  c.sensorId,
                  c.deviceId,
                  c.trainNo,
                  c.location,
                  '${c.todayCount}',
                  '${c.totalCount}',
                  c.lastTrigger != null ? _fmtDatetime(c.lastTrigger!) : 'N/A',
                  _fmtDatetime(c.updateTime),
                ]).toList(),
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellHeight: 24,
              ),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total Incidents Today: ${coaches.fold(0, (sum, c) => sum + c.todayCount)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'ACP_Report_${DateFormat('dd-MM-yyyy_HH-mm').format(now)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _fmtDatetime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  static void _header(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.fromHexString('#1565C0'),
    );
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
      cell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#$color'),
        bold: true,
        fontSize: 11,
      );
    } else {
      cell.cellStyle = CellStyle(fontSize: 11);
    }
  }

  static void _blankRow(Sheet sheet, int row) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('');
  }

  static String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
            _reportFeature('Coach Status Summary'),
            _reportFeature('Chain Pull History'),
            _reportFeature('Date-wise Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Text(path.split('/').last, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
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
            child: Text('Open File', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)], text: 'ACP Monitoring Report');
            },
            child: Text('Share', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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

  static Widget _formatOption(BuildContext context, String label, String value, IconData icon, Color color) {
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