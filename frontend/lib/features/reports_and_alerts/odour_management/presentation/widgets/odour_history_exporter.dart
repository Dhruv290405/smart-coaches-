import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/models/odour_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/repository/odour_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/shared/report_pdf_theme.dart';
import 'history_file_saver_stub.dart'
    if (dart.library.io) 'history_file_saver_io.dart'
    if (dart.library.html) 'history_file_saver_web.dart';

int _smartBucketMinutes(DateTime start, DateTime end) {
  final days = end.difference(start).inDays;
  if (days <= 7) return 5;
  if (days <= 14) return 10;
  if (days <= 30) return 15;
  return 30;
}

class OdourHistoryExporter {
  static Future<void> export(
    BuildContext context,
    OdourCoachModel toilet,
    List<OdourHistoryPoint> points,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No history data to export for this period')),
      );
      return;
    }

    final int bucketMinutes = _smartBucketMinutes(startDate, endDate);

    final String? format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Export Format', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _formatOption(ctx, 'Excel (.xlsx)', 'xlsx', Icons.table_chart, Colors.green),
            const SizedBox(height: 12),
            _formatOption(ctx, 'PDF', 'pdf', Icons.picture_as_pdf, Colors.red),
          ],
        ),
      ),
    );
    if (format == null || !context.mounted) return;

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
              Text('Fetching data & generating report...',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('${endDate.difference(startDate).inDays}-day report at $bucketMinutes-min intervals',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    try {
      List<OdourHistoryPoint> exportPoints;
      int totalRaw = points.length;
      int? usedBucket;

      final aggResult = await OdourRepository().getAggregatedHistory(
        toilet.deviceId,
        toilet.section,
        startDate: startDate,
        endDate: endDate,
        bucketMinutes: bucketMinutes,
      );
      if (aggResult != null && aggResult['buckets'] is List && (aggResult['buckets'] as List).isNotEmpty) {
        exportPoints = (aggResult['buckets'] as List)
            .map((e) => OdourHistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList();
        totalRaw = (aggResult['totalRaw'] as int?) ?? points.length;
        usedBucket = bucketMinutes;
      } else {
        exportPoints = points;
      }

      final List<int> bytes;
      final String fileName;
      final label = toilet.deviceId;
      final coach = toilet.coachNumber;
      final train = '${toilet.trainNumber} - ${toilet.trainName}';
      final days = endDate.difference(startDate).inDays;

      if (format == 'xlsx') {
        bytes = await compute(_buildExcelBytesIsolate, _ExcelParams(
          label: label, coach: coach, train: train,
          points: exportPoints, startDate: startDate, endDate: endDate,
          totalRaw: totalRaw, bucketMinutes: usedBucket,
        ));
        fileName = 'BODR_History_${label}_${_fileDate(startDate)}_${_fileDate(endDate)}.xlsx';
      } else {
        bytes = await compute(_buildPdfBytesIsolate, _PdfParams(
          label: label, coach: coach, train: train,
          points: exportPoints, startDate: startDate, endDate: endDate,
          totalRaw: totalRaw, bucketMinutes: usedBucket, periodDays: days,
        ));
        fileName = 'BODR_History_${label}_${_fileDate(startDate)}_${_fileDate(endDate)}.pdf';
      }
      final savedPath = await saveExportBytes(bytes, fileName);

      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      _showSuccess(context, savedPath);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating export: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static String _fileDate(DateTime d) => DateFormat('yyyyMMdd').format(d);

  static void _showSuccess(BuildContext context, String path) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: $path'), backgroundColor: Colors.green),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export Ready'),
        content: Text('History exported successfully to: $path'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => openExportedFile(path), child: const Text('Open')),
          ElevatedButton(onPressed: () => shareExportedFile(path), child: const Text('Share')),
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

class _ExcelParams {
  final String label, coach, train;
  final List<OdourHistoryPoint> points;
  final DateTime startDate, endDate;
  final int totalRaw;
  final int? bucketMinutes;
  _ExcelParams({required this.label, required this.coach, required this.train,
    required this.points, required this.startDate, required this.endDate,
    required this.totalRaw, this.bucketMinutes});
}

class _PdfParams {
  final String label, coach, train;
  final List<OdourHistoryPoint> points;
  final DateTime startDate, endDate;
  final int totalRaw;
  final int? bucketMinutes;
  final int periodDays;
  _PdfParams({required this.label, required this.coach, required this.train,
    required this.points, required this.startDate, required this.endDate,
    required this.totalRaw, this.bucketMinutes, required this.periodDays});
}

// ---------------------------------------------------------------------------
// Helpers shared by isolate functions
// ---------------------------------------------------------------------------

String _toIst(String raw) {
  try {
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(normalized).toLocal());
  } catch (_) {
    return raw;
  }
}

String _dayLabel(String raw) {
  try {
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateFormat('dd MMM yyyy (EEEE)').format(DateTime.parse(normalized).toLocal());
  } catch (_) {
    return raw;
  }
}

String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

// ---------------------------------------------------------------------------
// compute() entry points — MUST be top-level functions
// ---------------------------------------------------------------------------

List<int> _buildExcelBytesIsolate(_ExcelParams p) {
  final excel = Excel.createExcel();
  final sheet = excel['History'];
  excel.setDefaultSheet('History');

  void header(int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(bold: true, fontSize: 12);
  }
  void colHeader(int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#1565C0'), fontColorHex: ExcelColor.fromHexString('#FFFFFF'));
  }
  void cell(int row, int col, String text) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = TextCellValue(text);
  }

  final coverage = p.bucketMinutes != null
      ? '${p.bucketMinutes}-min intervals | ${p.totalRaw} raw readings | 100% time coverage'
      : '${p.points.length} readings';
  header(0, 0, 'Bad Odour History — ${p.coach} (${p.label})');
  header(1, 0, 'Train: ${p.train}');
  header(2, 0, 'Period: ${_fmtDate(p.startDate)} -> ${_fmtDate(p.endDate)} | $coverage');
  header(3, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');

  final headers = ['S.No.', 'Timestamp (IST)', 'Status', 'Hygiene Score (%)', 'VOC', 'NH3 (ppm)', 'H2S (ppm)', 'CH4 (ppm)', 'Temperature (C)', 'Humidity (%)'];
  for (var i = 0; i < headers.length; i++) {
    colHeader(5, i, headers[i]);
  }

  for (var i = 0; i < p.points.length; i++) {
    final pt = p.points[i];
    final row = 6 + i;
    cell(row, 0, (i + 1).toString());
    cell(row, 1, _toIst(pt.timestamp));
    cell(row, 2, pt.status);
    cell(row, 3, pt.hygieneScore.toStringAsFixed(0));
    cell(row, 4, pt.voc.toStringAsFixed(2));
    cell(row, 5, pt.nh3.toStringAsFixed(2));
    cell(row, 6, pt.h2s.toStringAsFixed(2));
    cell(row, 7, pt.methane.toStringAsFixed(2));
    cell(row, 8, pt.temperature.toStringAsFixed(1));
    cell(row, 9, pt.humidity.toStringAsFixed(0));
  }

  return excel.encode()!;
}

Future<List<int>> _buildPdfBytesIsolate(_PdfParams p) async {
  final pdf = pw.Document();
  final aggNote = p.bucketMinutes != null
      ? '${p.bucketMinutes}-min intervals | ${p.totalRaw} raw readings | 100% time coverage'
      : '${p.points.length} readings';

  // Group points by day for day-wise sections
  final Map<String, List<_PdfRow>> dayGroups = {};
  for (var i = 0; i < p.points.length; i++) {
    final pt = p.points[i];
    final dayKey = _dayLabel(pt.timestamp);
    dayGroups.putIfAbsent(dayKey, () => []);
    dayGroups[dayKey]!.add(_PdfRow(
      index: i + 1,
      timestamp: _toIst(pt.timestamp),
      status: pt.status,
      hygiene: pt.hygieneScore.toStringAsFixed(0),
      voc: pt.voc.toStringAsFixed(2),
      nh3: pt.nh3.toStringAsFixed(2),
      h2s: pt.h2s.toStringAsFixed(2),
      methane: pt.methane.toStringAsFixed(2),
    ));
  }

  // Cover page with summary
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) => [
        ...ReportPdfTheme.header(
          title: 'Bad Odour History — ${p.coach} (${p.label})',
          summary: 'Train: ${p.train} | Period: ${_fmtDate(p.startDate)} -> ${_fmtDate(p.endDate)}\n$aggNote',
          generatedAt: DateTime.now(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Report Contents: ${dayGroups.length} days | ${p.points.length} data rows',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Day', 'Readings'],
          data: dayGroups.entries.map((e) => [e.key, e.value.length.toString()]).toList(),
          headerStyle: ReportPdfTheme.tableHeader,
          headerDecoration: ReportPdfTheme.tableHeaderDecoration,
          cellStyle: ReportPdfTheme.tableCellStyle,
          cellHeight: 20,
        ),
      ],
    ),
  );

  // One section per day
  for (final entry in dayGroups.entries) {
    final dayLabel = entry.key;
    final rows = entry.value;
    final tableData = rows.map((r) => [
      r.index.toString(), r.timestamp, r.status, r.hygiene,
      r.voc, r.nh3, r.h2s, r.methane,
    ]).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(dayLabel, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('${p.coach} (${p.label})', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ),
        build: (pw.Context context) => [
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Timestamp (IST)', 'Status', 'Hygiene %', 'VOC', 'NH3', 'H2S', 'CH4'],
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

  return await pdf.save();
}

class _PdfRow {
  final int index;
  final String timestamp, status, hygiene, voc, nh3, h2s, methane;
  _PdfRow({required this.index, required this.timestamp, required this.status,
    required this.hygiene, required this.voc, required this.nh3,
    required this.h2s, required this.methane});
}
