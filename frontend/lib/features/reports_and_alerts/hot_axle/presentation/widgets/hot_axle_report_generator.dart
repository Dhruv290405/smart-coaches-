import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_dummy_data.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HotAxleReportGenerator {
  static Future<void> generate(BuildContext context, List<HotAxleCoachModel> coaches) async {
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

    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 3, 12),
      initialDateRange: DateTimeRange(start: DateTime(2026, 3, 5), end: DateTime(2026, 3, 12)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: ColorConstants.primary)),
        child: child!,
      ),
    );
    if (range == null) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: ColorConstants.primary),
            const SizedBox(height: 16),
            Text('Generating Hot Axle Report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('${_fmt(range.start)} → ${_fmt(range.end)}', style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary)),
          ]),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(coaches, range);
      } else {
        file = await _buildPdf(coaches);
      }

      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      _showSuccess(context, file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  static Future<File> _buildPdf(List<HotAxleCoachModel> coaches) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('Hot Axle Monitoring Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Coach No.', 'Status', 'Max Temp', 'Axles Issue'],
          data: coaches.map((c) => [c.coachNumber, c.status, c.maxTemp, '${c.axlesIssue}']).toList(),
        ),
      ],
    ));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/HotAxle_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> _buildExcel(List<HotAxleCoachModel> coaches, DateTimeRange range) async {
    final excel = Excel.createExcel();

    final summary = excel['Coach Summary'];
    excel.setDefaultSheet('Coach Summary');

    _hdr(summary, 0, 0, 'Hot Axle Monitoring Report — ${HotAxleDummyData.trainName}');
    _hdr(summary, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _hdr(summary, 2, 0, 'Generated: ${_fmt(DateTime(2026, 3, 12))} | Last Updated: ${HotAxleDummyData.lastUpdated}');
    _blank(summary, 3);

    final h1 = ['Coach No.', 'Status', 'Max Temp (°C)', 'Axles Monitored', 'Axles With Issue', 'Last Updated'];
    for (var i = 0; i < h1.length; i++) {
      _col(summary, 4, i, h1[i]);
    }

    for (var r = 0; r < coaches.length; r++) {
      final c   = coaches[r];
      final row = 5 + r;
      final statusColor = c.status == 'Critical' ? 'D32F2F' : c.status == 'Warning' ? 'BE8B22' : '2E7D32';
      _cell(summary, row, 0, c.coachNumber);
      _cell(summary, row, 1, c.status,             color: statusColor);
      _cell(summary, row, 2, '${c.maxTemp.toStringAsFixed(1)}°C', color: c.axlesIssue > 0 ? statusColor : null);
      _cell(summary, row, 3, '${c.axlesMonitored}');
      _cell(summary, row, 4, '${c.axlesIssue}',    color: c.axlesIssue > 0 ? statusColor : null);
      _cell(summary, row, 5, c.updateTime);
    }

    final totalRow = 5 + coaches.length + 1;
    final good     = coaches.where((c) => c.status == 'Good').length;
    final warning  = coaches.where((c) => c.status == 'Warning').length;
    final critical = coaches.where((c) => c.status == 'Critical').length;
    final issues   = coaches.fold(0, (sum, c) => sum + c.axlesIssue);
    _col(summary, totalRow,     0, 'Total Coaches'); _cell(summary, totalRow,     1, '${coaches.length}');
    _col(summary, totalRow + 1, 0, 'Good');          _cell(summary, totalRow + 1, 1, '$good',    color: '2E7D32');
    _col(summary, totalRow + 2, 0, 'Warning');       _cell(summary, totalRow + 2, 1, '$warning', color: 'BE8B22');
    _col(summary, totalRow + 3, 0, 'Critical');      _cell(summary, totalRow + 3, 1, '$critical',color: 'D32F2F');
    _col(summary, totalRow + 4, 0, 'Total Axle Issues'); _cell(summary, totalRow + 4, 1, '$issues', color: issues > 0 ? 'D32F2F' : null);

    final axleSheet = excel['Axle Details'];
    _hdr(axleSheet, 0, 0, 'Individual Axle Status — All Coaches');
    _blank(axleSheet, 1);

    final h2 = ['Coach No.', 'Axle No.', 'Sensor ID', 'Status', 'Max Temp', 'Current Temp', 'Speed', 'Detected At', 'Location', 'Last Maintenance'];
    for (var i = 0; i < h2.length; i++) {
      _col(axleSheet, 2, i, h2[i]);
    }

    int axleRow = 3;
    for (final coach in coaches) {
      for (final axle in coach.axles) {
        final sc = axle.status == 'Critical' ? 'D32F2F' : axle.status == 'Warning' ? 'BE8B22' : null;
        _cell(axleSheet, axleRow, 0, coach.coachNumber);
        _cell(axleSheet, axleRow, 1, 'Axle ${axle.axleNumber}');
        _cell(axleSheet, axleRow, 2, axle.sensorId);
        _cell(axleSheet, axleRow, 3, axle.status,          color: sc);
        _cell(axleSheet, axleRow, 4, axle.maxTemp,         color: sc);
        _cell(axleSheet, axleRow, 5, axle.currentTemp);
        _cell(axleSheet, axleRow, 6, axle.speed);
        _cell(axleSheet, axleRow, 7, axle.detectedAt.isEmpty ? '-' : axle.detectedAt);
        _cell(axleSheet, axleRow, 8, axle.location.isEmpty ? '-' : axle.location);
        _cell(axleSheet, axleRow, 9, axle.lastMaintenance);
        axleRow++;
      }
    }

    final histSheet = excel['Overheat History'];
    _hdr(histSheet, 0, 0, 'Axle Overheat History — ${HotAxleDummyData.trainName}');
    _hdr(histSheet, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _blank(histSheet, 2);

    final h3 = ['Coach No.', 'Axle No.', 'Sensor ID', 'Max Temp', 'Status', 'Speed', 'Detected At', 'Location'];
    for (var i = 0; i < h3.length; i++) {
      _col(histSheet, 3, i, h3[i]);
    }

    int histRow = 4;
    for (final coach in coaches) {
      final entries = HotAxleDummyData.getHistory(coach.coachNumber, 'Custom', from: range.start, to: range.end);
      for (final e in entries) {
        final sc = e.status == 'Critical' ? 'D32F2F' : e.status == 'Warning' ? 'BE8B22' : null;
        _cell(histSheet, histRow, 0, e.coachNumber);
        _cell(histSheet, histRow, 1, 'Axle ${e.axleNumber}');
        _cell(histSheet, histRow, 2, e.sensorId);
        _cell(histSheet, histRow, 3, e.maxTemp,    color: sc);
        _cell(histSheet, histRow, 4, e.status,     color: sc);
        _cell(histSheet, histRow, 5, e.speed);
        _cell(histSheet, histRow, 6, e.detectedAt);
        _cell(histSheet, histRow, 7, e.location);
        histRow++;
      }
    }

    for (final sh in [summary, axleSheet, histSheet]) {
      for (var c = 0; c < 10; c++) {
        sh.setColumnWidth(c, 20);
      }
    }

    final dir  = await getApplicationDocumentsDirectory();
    final name = 'HotAxle_Report_${_fmt(range.start)}_to_${_fmt(range.end)}.xlsx'.replaceAll('/', '-');
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  static void _hdr(Sheet s, int r, int c, String t) {
    final cell = s.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
    cell.value = TextCellValue(t);
    cell.cellStyle = CellStyle(bold: true, fontSize: 13, fontColorHex: ExcelColor.fromHexString('#1565C0'));
  }

  static void _col(Sheet s, int r, int c, String t) {
    final cell = s.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
    cell.value = TextCellValue(t);
    cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#1565C0'), fontColorHex: ExcelColor.fromHexString('#FFFFFF'), fontSize: 11);
  }

  static void _cell(Sheet s, int r, int c, String t, {String? color}) {
    final cell = s.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
    cell.value = TextCellValue(t);
    cell.cellStyle = color != null
        ? CellStyle(fontColorHex: ExcelColor.fromHexString('#$color'), bold: true, fontSize: 11)
        : CellStyle(fontSize: 11);
  }

  static void _blank(Sheet s, int r) => s.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r)).value = TextCellValue('');

  static String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static void _showSuccess(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text('Report Ready', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hot Axle Excel report generated.', style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 8),
          Text('Includes:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _feat('Coach Summary (status + max temp)'),
          _feat('Individual Axle Details (all 160 axles)'),
          _feat('Overheat History (date filtered)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text(path.split('/').last, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.poppins(color: ColorConstants.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () { Navigator.pop(context); OpenFile.open(path); },
            child: Text('Open File', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)], text: 'Hot Axle Monitoring Report');
            },
            child: Text('Share', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

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

  static Widget _feat(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      const Icon(Icons.check, size: 14, color: Color(0xFF2E7D32)),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.poppins(fontSize: 12)),
    ]),
  );
}
