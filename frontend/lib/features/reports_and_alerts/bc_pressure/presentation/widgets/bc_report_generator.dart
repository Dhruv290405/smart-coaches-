import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class BCReportGenerator {
  static Future<void> generate(BuildContext context, List<BCPressureModel> coaches) async {
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
            Text('Generating BC Report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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

  static Future<File> _buildPdf(List<BCPressureModel> coaches) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('BC Pressure Monitoring Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Coach No.', 'Pressure', 'Status', 'Brake Applied'],
          data: coaches.map((c) => [c.coachNumber, '${c.pressure}', c.status, c.brakeApplied]).toList(),
        ),
      ],
    ));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/BC_Pressure_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> _buildExcel(List<BCPressureModel> coaches, DateTimeRange range) async {
    final excel = Excel.createExcel();

    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    final trainLabel = coaches.isNotEmpty ? 'Train ${coaches.first.trainNumber}' : '';
    _hdr(summary, 0, 0, 'BC Pressure Monitoring Report${trainLabel.isNotEmpty ? ' — $trainLabel' : ''}');
    _hdr(summary, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _hdr(summary, 2, 0, 'Generated: ${_fmt(DateTime.now())} | Last Updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}');
    _blank(summary, 3);

    final h1 = ['Coach No.', 'Sensor ID', 'Pressure (Kg/cm²)', 'Status', 'Brake Applied', 'Brake Released', 'Warning', 'Last Updated'];
    for (var i = 0; i < h1.length; i++) {
      _col(summary, 4, i, h1[i]);
    }

    for (var r = 0; r < coaches.length; r++) {
      final c = coaches[r];
      final id = int.tryParse(c.coachNumber.replaceAll('Coach ', '')) ?? r + 1;
      final row = 5 + r;
      _cell(summary, row, 0, c.coachNumber);
      _cell(summary, row, 1, 'BC-B7-${id.toString().padLeft(2, '0')}');
      _cell(summary, row, 2, c.pressure.toString(), color: c.pressure < 1.5 ? 'D32F2F' : c.pressure < 3.5 ? 'BE8B22' : '2E7D32');
      _cell(summary, row, 3, c.status, color: c.status == 'Critical' ? 'D32F2F' : c.status == 'Warning' ? 'BE8B22' : '2E7D32');
      _cell(summary, row, 4, c.brakeApplied.isEmpty ? 'N/A' : c.brakeApplied);
      _cell(summary, row, 5, c.brakeReleased.isEmpty ? 'Delayed/N/A' : c.brakeReleased);
      _cell(summary, row, 6, c.warningMessage ?? '-');
      _cell(summary, row, 7, c.getFormattedLastUpdated());
    }

    final totalRow = 5 + coaches.length + 1;
    final good     = coaches.where((c) => c.status == 'Good').length;
    final warning  = coaches.where((c) => c.status == 'Warning').length;
    final critical = coaches.where((c) => c.status == 'Critical').length;
    _col(summary, totalRow,     0, 'Total');       _cell(summary, totalRow,     1, '${coaches.length}');
    _col(summary, totalRow + 1, 0, 'Good');        _cell(summary, totalRow + 1, 1, '$good',     color: '2E7D32');
    _col(summary, totalRow + 2, 0, 'Warning');     _cell(summary, totalRow + 2, 1, '$warning',  color: 'BE8B22');
    _col(summary, totalRow + 3, 0, 'Critical');    _cell(summary, totalRow + 3, 1, '$critical', color: 'D32F2F');

    final alertSheet = excel['Pressure Alerts'];
    _hdr(alertSheet, 0, 0, 'Current Pressure Alerts');
    _hdr(alertSheet, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _blank(alertSheet, 2);

    final h2 = ['Coach No.', 'Pressure (Kg/cm²)', 'Status', 'Brake Applied', 'Brake Released', 'Warning'];
    for (var i = 0; i < h2.length; i++) {
      _col(alertSheet, 3, i, h2[i]);
    }

    int alertRow = 4;
    for (final coach in coaches.where((c) => c.status != 'Good')) {
      _cell(alertSheet, alertRow, 0, coach.coachNumber);
      _cell(alertSheet, alertRow, 1, coach.pressure.toString(), color: coach.status == 'Critical' ? 'D32F2F' : 'BE8B22');
      _cell(alertSheet, alertRow, 2, coach.status, color: coach.status == 'Critical' ? 'D32F2F' : 'BE8B22');
      _cell(alertSheet, alertRow, 3, coach.brakeApplied.isEmpty ? 'N/A' : coach.brakeApplied);
      _cell(alertSheet, alertRow, 4, coach.brakeReleased.isEmpty ? 'Delayed/N/A' : coach.brakeReleased);
      _cell(alertSheet, alertRow, 5, coach.warningMessage ?? '-');
      alertRow++;
    }

    final dateSheet = excel['Summary Stats'];
    _hdr(dateSheet, 0, 0, 'BC Pressure Summary');
    _blank(dateSheet, 1);

    final goodCount     = coaches.where((c) => c.status == 'Good').length;
    final warningCount  = coaches.where((c) => c.status == 'Warning').length;
    final criticalCount = coaches.where((c) => c.status == 'Critical').length;
    final h3 = ['Metric', 'Value'];
    for (var i = 0; i < h3.length; i++) {
      _col(dateSheet, 2, i, h3[i]);
    }
    _cell(dateSheet, 3, 0, 'Total Coaches'); _cell(dateSheet, 3, 1, '${coaches.length}');
    _cell(dateSheet, 4, 0, 'Good');           _cell(dateSheet, 4, 1, '$goodCount',    color: '2E7D32');
    _cell(dateSheet, 5, 0, 'Warning');        _cell(dateSheet, 5, 1, '$warningCount', color: 'BE8B22');
    _cell(dateSheet, 6, 0, 'Critical');       _cell(dateSheet, 6, 1, '$criticalCount',color: 'D32F2F');

    for (final sh in [summary, alertSheet, dateSheet]) {
      for (var c = 0; c < 8; c++) {
        sh.setColumnWidth(c, 22);
      }
    }

    final dir  = await getApplicationDocumentsDirectory();
    final name = 'BC_Pressure_Report_${_fmt(range.start)}_to_${_fmt(range.end)}.xlsx'.replaceAll('/', '-');
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
          Text('BC Pressure Excel report generated.', style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 8),
          Text('Includes:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _feat('Coach Pressure Summary'),
          _feat('Pressure Alerts (warnings/critical)'),
          _feat('Summary Stats'),
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
              Share.shareXFiles([XFile(path)], text: 'BC Pressure Monitoring Report');
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