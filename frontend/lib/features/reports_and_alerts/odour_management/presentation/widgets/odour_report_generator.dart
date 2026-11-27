import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/models/odour_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/repository/odour_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:smart_coach_new/features/reports_and_alerts/shared/report_pdf_theme.dart';

class OdourReportGenerator {
  static Future<void> generate(BuildContext context, List<OdourCoachModel> coaches, {String title = 'Odour Monitoring Report'}) async {
    final period = await _showPeriodPicker(context);
    if (period == null) return;
    if (!context.mounted) return;

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
              Text('Fetching data & generating report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('This may take a moment for large date ranges', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    try {
      final repo = OdourRepository();
      final reportData = await repo.getReportData(period.start, period.end);

      if (!context.mounted) return;

      if (reportData == null || reportData['devices'] == null || (reportData['devices'] as List).isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data available for the selected period'), backgroundColor: Colors.orange),
        );
        return;
      }

      File file;
      if (format == 'xlsx') {
        file = await _buildExcelReport(coaches, reportData, period, title: title);
      } else {
        file = await _buildPdfReport(coaches, reportData, period, title: title);
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

  static Future<DateTimeRange?> _showPeriodPicker(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Report Period', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _periodOption(ctx, 'Last 7 Days', Icons.calendar_view_week, Colors.blue, () => Navigator.pop(ctx, '7')),
            const SizedBox(height: 10),
            _periodOption(ctx, 'Last 30 Days', Icons.calendar_month, Colors.indigo, () => Navigator.pop(ctx, '30')),
            const SizedBox(height: 10),
            _periodOption(ctx, 'Custom Date Range', Icons.date_range, Colors.deepPurple, () => Navigator.pop(ctx, 'custom')),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return null;

    final now = DateTime.now();
    if (choice == '7') {
      return DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
    }
    if (choice == '30') {
      return DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return DateTimeRange(
      start: picked.start,
      end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
    );
  }

  static Widget _periodOption(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  static String _toIst(String? ts) {
    if (ts == null || ts.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(ts).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
    } catch (_) {
      return ts;
    }
  }

  static Future<File> _buildExcelReport(
    List<OdourCoachModel> coaches,
    Map<String, dynamic> reportData,
    DateTimeRange range,
    {String title = 'Odour Monitoring Report'}
  ) async {
    final excel = Excel.createExcel();
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    final devices = (reportData['devices'] as List).cast<String>();
    final data = reportData['data'] as Map<String, dynamic>;

    _header(summary, 0, 0, title);
    _header(summary, 1, 0, 'Period: ${_fmtDate(range.start)}  →  ${_fmtDate(range.end)}');
    _header(summary, 2, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
    _blankRow(summary, 3);

    final summaryHeaders = ['Device ID', 'Coach No.', 'Train No.', 'Coach Type', 'Location', 'Total Readings', 'Avg Odour Index', 'Max Odour Index', 'Critical Count'];
    for (var i = 0; i < summaryHeaders.length; i++) {
      _colHeader(summary, 4, i, summaryHeaders[i]);
    }

    var summaryRow = 5;
    for (final deviceId in devices) {
      final devData = data[deviceId] as Map<String, dynamic>?;
      if (devData == null) continue;
      final rows = (devData['rows'] as List?) ?? [];

      double avgIndex = 0;
      double maxIndex = 0;
      int criticalCount = 0;
      for (final r in rows) {
        final idx = (r['odour_index'] as num?)?.toDouble() ?? 0;
        avgIndex += idx;
        if (idx > maxIndex) maxIndex = idx;
        if (idx >= 250) criticalCount++;
      }
      if (rows.isNotEmpty) avgIndex /= rows.length;

      _cell(summary, summaryRow, 0, deviceId);
      _cell(summary, summaryRow, 1, devData['coach_no']?.toString() ?? '--');
      _cell(summary, summaryRow, 2, devData['train_no']?.toString() ?? '--');
      _cell(summary, summaryRow, 3, devData['coach_type']?.toString() ?? '--');
      _cell(summary, summaryRow, 4, devData['location']?.toString() ?? '--');
      _cell(summary, summaryRow, 5, rows.length.toString());
      _cell(summary, summaryRow, 6, avgIndex.toStringAsFixed(2));
      _cell(summary, summaryRow, 7, maxIndex.toStringAsFixed(2));
      _cell(summary, summaryRow, 8, criticalCount.toString());
      summaryRow++;
    }

    for (final deviceId in devices) {
      final devData = data[deviceId] as Map<String, dynamic>?;
      if (devData == null) continue;
      final rows = (devData['rows'] as List?) ?? [];

      final sheetName = deviceId.length > 31 ? deviceId.substring(0, 31) : deviceId;
      final sheet = excel[sheetName];

      _header(sheet, 0, 0, 'Device: $deviceId');
      _header(sheet, 1, 0, 'Coach No: ${devData['coach_no'] ?? '--'} | Train: ${devData['train_no'] ?? '--'}');
      _header(sheet, 2, 0, 'Total Readings: ${rows.length}');
      _blankRow(sheet, 3);

      final dataHeaders = ['S.No.', 'Timestamp (IST)', 'Odour Index', 'Level', 'VOC', 'NH3 (ppm)', 'H2S (ppm)', 'CH4 (ppm)', 'Temperature', 'Humidity'];
      for (var i = 0; i < dataHeaders.length; i++) {
        _colHeader(sheet, 4, i, dataHeaders[i]);
      }

      for (var i = 0; i < rows.length; i++) {
        final r = rows[i] as Map<String, dynamic>;
        final vocVal = (r['voc'] as num?)?.toDouble() ?? 0;
        final row = 5 + i;
        _cell(sheet, row, 0, (i + 1).toString());
        _cell(sheet, row, 1, _toIst(r['timestamp']?.toString()));
        _cell(sheet, row, 2, vocVal.toStringAsFixed(0));
        _cell(sheet, row, 3, OdourIndex.level(vocVal));
        _cell(sheet, row, 4, vocVal.toStringAsFixed(0));
        _cell(sheet, row, 5, (r['nh3'] ?? 0).toString());
        _cell(sheet, row, 6, (r['h2s'] ?? 0).toString());
        _cell(sheet, row, 7, (r['methane'] ?? 0).toString());
        _cell(sheet, row, 8, (r['temperature'] ?? 0).toString());
        _cell(sheet, row, 9, (r['humidity'] ?? 0).toString());
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Odour_Report_${_fileDate(range.start)}_${_fileDate(range.end)}.xlsx';
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> _buildPdfReport(
    List<OdourCoachModel> coaches,
    Map<String, dynamic> reportData,
    DateTimeRange range,
    {String title = 'Odour Monitoring Report'}
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final devices = (reportData['devices'] as List).cast<String>();
    final data = reportData['data'] as Map<String, dynamic>;

    final summaryRows = <List<String>>[];
    for (final deviceId in devices) {
      final devData = data[deviceId] as Map<String, dynamic>?;
      if (devData == null) continue;
      final rows = (devData['rows'] as List?) ?? [];
      double avgIndex = 0, maxIndex = 0;
      int criticalCount = 0;
      for (final r in rows) {
        final idx = (r['odour_index'] as num?)?.toDouble() ?? 0;
        avgIndex += idx;
        if (idx > maxIndex) maxIndex = idx;
        if (idx >= 250) criticalCount++;
      }
      if (rows.isNotEmpty) avgIndex /= rows.length;
      summaryRows.add([
        deviceId,
        devData['coach_no']?.toString() ?? '--',
        devData['train_no']?.toString() ?? '--',
        rows.length.toString(),
        avgIndex.toStringAsFixed(2),
        maxIndex.toStringAsFixed(2),
        criticalCount.toString(),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) => [
          ...ReportPdfTheme.header(
            title: title,
            summary: 'Period: ${_fmtDate(range.start)} → ${_fmtDate(range.end)} | Devices: ${devices.length}',
            generatedAt: now,
          ),
          pw.Text('Device Summary', style: ReportPdfTheme.sectionTitle),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Device ID', 'Coach No.', 'Train No.', 'Readings', 'Avg Index', 'Max Index', 'Critical'],
            data: summaryRows,
            headerStyle: ReportPdfTheme.tableHeader,
            headerDecoration: ReportPdfTheme.tableHeaderDecoration,
            cellStyle: ReportPdfTheme.tableCellStyle,
            cellHeight: 22,
          ),
        ],
      ),
    );

    for (final deviceId in devices) {
      final devData = data[deviceId] as Map<String, dynamic>?;
      if (devData == null) continue;
      final rows = (devData['rows'] as List?) ?? [];
      if (rows.isEmpty) continue;

      final maxPdfRows = 500;
      final displayRows = rows.length > maxPdfRows ? rows.sublist(0, maxPdfRows) : rows;
      final truncated = rows.length > maxPdfRows;

      final tableData = <List<String>>[];
      for (var i = 0; i < displayRows.length; i++) {
        final r = displayRows[i] as Map<String, dynamic>;
        final vocVal = (r['voc'] as num?)?.toDouble() ?? 0;
        tableData.add([
          (i + 1).toString(),
          _toIst(r['timestamp']?.toString()),
          vocVal.toStringAsFixed(0),
          OdourIndex.level(vocVal),
          vocVal.toStringAsFixed(0),
          (r['nh3'] ?? 0).toString(),
          (r['h2s'] ?? 0).toString(),
          (r['methane'] ?? 0).toString(),
        ]);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            pw.Text('$deviceId — ${devData['coach_no'] ?? '--'} | Train: ${devData['train_no'] ?? '--'}',
              style: ReportPdfTheme.sectionTitle),
            pw.SizedBox(height: 4),
            pw.Text('Total: ${rows.length} readings${truncated ? ' (showing first $maxPdfRows in PDF — use Excel for full data)' : ''}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Timestamp (IST)', 'Odour Index', 'Level', 'VOC', 'NH3', 'H2S', 'CH4'],
              data: tableData,
              headerStyle: ReportPdfTheme.tableHeader,
              headerDecoration: ReportPdfTheme.tableHeaderDecoration,
              cellStyle: ReportPdfTheme.tableCellStyle,
              cellHeight: 18,
            ),
          ],
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Odour_Report_${_fileDate(range.start)}_${_fileDate(range.end)}.pdf';
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

  static String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  static String _fileDate(DateTime d) => DateFormat('yyyyMMdd').format(d);

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
