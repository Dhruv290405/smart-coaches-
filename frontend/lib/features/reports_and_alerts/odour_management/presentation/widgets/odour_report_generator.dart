import 'dart:io';
import 'package:flutter/foundation.dart';
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

int _smartBucketMinutes(DateTime start, DateTime end) {
  final days = end.difference(start).inDays;
  if (days <= 7) return 5;
  if (days <= 14) return 10;
  if (days <= 30) return 15;
  return 30;
}

class OdourReportGenerator {
  static Future<void> generate(BuildContext context, List<OdourCoachModel> coaches, {String title = 'Odour Monitoring Report'}) async {
    final now = DateTime.now();
    final period = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (period == null || !context.mounted) return;

    final adjustedPeriod = DateTimeRange(
      start: period.start,
      end: DateTime(period.end.year, period.end.month, period.end.day, 23, 59, 59),
    );

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

    final int bucketMinutes = _smartBucketMinutes(adjustedPeriod.start, adjustedPeriod.end);

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
              Text('Fetching aggregated data & generating report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Summarising into $bucketMinutes-min intervals', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    try {
      final repo = OdourRepository();

      Map<String, dynamic>? reportData = await repo.getAggregatedReportData(
        adjustedPeriod.start, adjustedPeriod.end, bucketMinutes: bucketMinutes,
      );

      if (!context.mounted) return;

      if (reportData == null || reportData['devices'] == null || (reportData['devices'] as List).isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data available for the selected period'), backgroundColor: Colors.orange),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();

      File file;
      if (format == 'xlsx') {
        final bytes = await compute(_buildExcelReportIsolate, _ReportExcelParams(
          reportData: reportData,
          rangeStart: adjustedPeriod.start,
          rangeEnd: adjustedPeriod.end,
          title: title,
          bucketMinutes: reportData.containsKey('bucketMinutes') ? (reportData['bucketMinutes'] as int?) : null,
        ));
        final fileName = 'Odour_Report_${_fileDate(adjustedPeriod.start)}_${_fileDate(adjustedPeriod.end)}.xlsx';
        file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
      } else {
        final bytes = await compute(_buildPdfReportIsolate, _ReportPdfParams(
          reportData: reportData,
          rangeStart: adjustedPeriod.start,
          rangeEnd: adjustedPeriod.end,
          title: title,
          bucketMinutes: reportData.containsKey('bucketMinutes') ? (reportData['bucketMinutes'] as int?) : null,
        ));
        final fileName = 'Odour_Report_${_fileDate(adjustedPeriod.start)}_${_fileDate(adjustedPeriod.end)}.pdf';
        file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
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

// ---------------------------------------------------------------------------
// Data classes for compute() isolate
// ---------------------------------------------------------------------------

class _ReportExcelParams {
  final Map<String, dynamic> reportData;
  final DateTime rangeStart, rangeEnd;
  final String title;
  final int? bucketMinutes;
  _ReportExcelParams({required this.reportData, required this.rangeStart, required this.rangeEnd, required this.title, this.bucketMinutes});
}

class _ReportPdfParams {
  final Map<String, dynamic> reportData;
  final DateTime rangeStart, rangeEnd;
  final String title;
  final int? bucketMinutes;
  _ReportPdfParams({required this.reportData, required this.rangeStart, required this.rangeEnd, required this.title, this.bucketMinutes});
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _toIst(String? ts) {
  if (ts == null || ts.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(ts).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
  } catch (_) {
    return ts;
  }
}

String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

String _dayLabel(String? ts) {
  if (ts == null || ts.isEmpty) return 'Unknown';
  try {
    final normalized = ts.contains('T') ? ts : ts.replaceFirst(' ', 'T');
    return DateFormat('dd MMM yyyy (EEEE)').format(DateTime.parse(normalized).toLocal());
  } catch (_) {
    return ts;
  }
}

void _header(Sheet sheet, int row, int col, String text) {
  final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  cell.value = TextCellValue(text);
  cell.cellStyle = CellStyle(bold: true, fontSize: 12);
}

void _colHeader(Sheet sheet, int row, int col, String text) {
  final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  cell.value = TextCellValue(text);
  cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#1565C0'), fontColorHex: ExcelColor.fromHexString('#FFFFFF'));
}

void _cell(Sheet sheet, int row, int col, String text) {
  final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  cell.value = TextCellValue(text);
}

void _blankRow(Sheet sheet, int row) {
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('');
}

// ---------------------------------------------------------------------------
// compute() entry points — MUST be top-level functions
// ---------------------------------------------------------------------------

List<int> _buildExcelReportIsolate(_ReportExcelParams p) {
  final excel = Excel.createExcel();
  final summary = excel['Summary'];
  excel.setDefaultSheet('Summary');

  final devices = (p.reportData['devices'] as List).cast<String>();
  final data = p.reportData['data'] as Map<String, dynamic>;
  final aggNote = p.bucketMinutes != null ? ' (${p.bucketMinutes}-min aggregated)' : '';

  _header(summary, 0, 0, 'Indian Railways — Smart Coach Monitoring System');
  _header(summary, 1, 0, 'Bad Odour Monitoring Report$aggNote');
  _header(summary, 2, 0, 'Period: ${_fmtDate(p.rangeStart)}  →  ${_fmtDate(p.rangeEnd)}');
  _header(summary, 3, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} IST');
  _blankRow(summary, 4);

  final summaryHeaders = ['Device ID', 'Coach No.', 'Train No.', 'Coach Type', 'Location', 'Total Readings', 'Avg Odour Index', 'Max Odour Index', 'Critical Count'];
  for (var i = 0; i < summaryHeaders.length; i++) {
    _colHeader(summary, 5, i, summaryHeaders[i]);
  }

  var summaryRow = 6;
  for (final deviceId in devices) {
    final devData = data[deviceId] as Map<String, dynamic>?;
    if (devData == null) continue;
    final rows = (devData['rows'] as List?) ?? [];
    final totalRaw = (devData['totalRaw'] as int?) ?? rows.length;

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
    _cell(summary, summaryRow, 5, totalRaw.toString());
    _cell(summary, summaryRow, 6, avgIndex.toStringAsFixed(2));
    _cell(summary, summaryRow, 7, maxIndex.toStringAsFixed(2));
    _cell(summary, summaryRow, 8, criticalCount.toString());
    summaryRow++;
  }

  for (final deviceId in devices) {
    final devData = data[deviceId] as Map<String, dynamic>?;
    if (devData == null) continue;
    final rows = (devData['rows'] as List?) ?? [];
    final totalRaw = (devData['totalRaw'] as int?) ?? rows.length;

    final sheetName = deviceId.length > 31 ? deviceId.substring(0, 31) : deviceId;
    final sheet = excel[sheetName];

    _header(sheet, 0, 0, 'Device: $deviceId');
    _header(sheet, 1, 0, 'Coach No: ${devData['coach_no'] ?? '--'} | Train: ${devData['train_no'] ?? '--'}');
    _header(sheet, 2, 0, 'Rows: ${rows.length}${p.bucketMinutes != null ? ' buckets (${totalRaw} raw readings)' : ' readings'}');
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

  return excel.encode()!;
}

Future<List<int>> _buildPdfReportIsolate(_ReportPdfParams p) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final devices = (p.reportData['devices'] as List).cast<String>();
  final data = p.reportData['data'] as Map<String, dynamic>;
  final aggNote = p.bucketMinutes != null ? ' | ${p.bucketMinutes}-min aggregated' : '';

  final summaryRows = <List<String>>[];
  for (final deviceId in devices) {
    final devData = data[deviceId] as Map<String, dynamic>?;
    if (devData == null) continue;
    final rows = (devData['rows'] as List?) ?? [];
    final totalRaw = (devData['totalRaw'] as int?) ?? rows.length;
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
      totalRaw.toString(),
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
          title: 'Bad Odour Monitoring Report',
          summary: 'Devices: ${devices.length}$aggNote',
          generatedAt: now,
          periodStart: p.rangeStart,
          periodEnd: p.rangeEnd,
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
    final totalRaw = (devData['totalRaw'] as int?) ?? rows.length;

    // Group rows by day for structured PDF
    final Map<String, List<List<String>>> dayGroups = {};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i] as Map<String, dynamic>;
      final vocVal = (r['voc'] as num?)?.toDouble() ?? 0;
      final dayKey = _dayLabel(r['timestamp']?.toString());
      dayGroups.putIfAbsent(dayKey, () => []);
      dayGroups[dayKey]!.add([
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

    for (final dayEntry in dayGroups.entries) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (pw.Context context) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${dayEntry.key}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('$deviceId — ${devData['coach_no'] ?? '--'} | Train: ${devData['train_no'] ?? '--'}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ),
          footer: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('$totalRaw raw readings$aggNote',
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
          ),
          build: (pw.Context context) => [
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Timestamp (IST)', 'Odour Index', 'Level', 'VOC', 'NH3', 'H2S', 'CH4'],
              data: dayEntry.value,
              headerStyle: ReportPdfTheme.tableHeader,
              headerDecoration: ReportPdfTheme.tableHeaderDecoration,
              cellStyle: ReportPdfTheme.tableCellStyle,
              cellHeight: 18,
            ),
          ],
        ),
      );
    }
  }

  return await pdf.save();
}
