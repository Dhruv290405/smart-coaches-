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

    final int bucketMinutes = endDate.difference(startDate).inDays > 7 ? 15 : 5;

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

    if (points.length > 5000) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Large Dataset', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
          content: Text(
            '${NumberFormat('#,###').format(points.length)} readings found.\n\n'
            'Data will be aggregated into ${bucketMinutes}-minute summaries '
            'for a fast, reliable export.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
    }

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
              Text('Fetching aggregated data & generating export...',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Summarising into ${bucketMinutes}-min intervals',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    try {
      List<OdourHistoryPoint> exportPoints;
      int totalRaw = points.length;

      if (points.length > 2000) {
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
        } else {
          exportPoints = points;
        }
      } else {
        exportPoints = points;
      }

      final List<int> bytes;
      final String fileName;
      final label = toilet.deviceId;
      final coach = toilet.coachNumber;
      final train = '${toilet.trainNumber} - ${toilet.trainName}';

      if (format == 'xlsx') {
        bytes = await compute(_buildExcelBytesIsolate, _ExcelParams(
          label: label, coach: coach, train: train,
          points: exportPoints, startDate: startDate, endDate: endDate,
          totalRaw: totalRaw, bucketMinutes: exportPoints.length < points.length ? bucketMinutes : null,
        ));
        fileName = 'BODR_History_${label}_${_fileDate(startDate)}_${_fileDate(endDate)}.xlsx';
      } else {
        bytes = await compute(_buildPdfBytesIsolate, _PdfParams(
          label: label, coach: coach, train: train,
          points: exportPoints, startDate: startDate, endDate: endDate,
          totalRaw: totalRaw, bucketMinutes: exportPoints.length < points.length ? bucketMinutes : null,
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
// Data classes for compute() isolate (must be top-level or static)
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
  _PdfParams({required this.label, required this.coach, required this.train,
    required this.points, required this.startDate, required this.endDate,
    required this.totalRaw, this.bucketMinutes});
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

  final aggNote = p.bucketMinutes != null ? ' (${p.bucketMinutes}-min avg, ${p.totalRaw} raw readings)' : '';
  header(0, 0, 'Bad Odour History — ${p.coach} (${p.label})$aggNote');
  header(1, 0, 'Train: ${p.train}');
  header(2, 0, 'Period: ${_fmtDate(p.startDate)} -> ${_fmtDate(p.endDate)}');
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
  final maxPdfRows = 500;
  final display = p.points.length > maxPdfRows ? p.points.sublist(0, maxPdfRows) : p.points;
  final truncated = p.points.length > maxPdfRows;

  final tableData = <List<String>>[];
  for (var i = 0; i < display.length; i++) {
    final pt = display[i];
    tableData.add([
      (i + 1).toString(),
      _toIst(pt.timestamp),
      pt.status,
      pt.hygieneScore.toStringAsFixed(0),
      pt.voc.toStringAsFixed(2),
      pt.nh3.toStringAsFixed(2),
      pt.h2s.toStringAsFixed(2),
      pt.methane.toStringAsFixed(2),
    ]);
  }

  final aggNote = p.bucketMinutes != null ? ' | ${p.bucketMinutes}-min aggregated' : '';
  final truncNote = truncated ? ' (showing first $maxPdfRows rows — use Excel for full data)' : '';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) => [
        ...ReportPdfTheme.header(
          title: 'Bad Odour History — ${p.coach} (${p.label})',
          summary: 'Train: ${p.train} | Period: ${_fmtDate(p.startDate)} -> ${_fmtDate(p.endDate)} | '
              'Readings: ${p.totalRaw}$aggNote$truncNote',
          generatedAt: DateTime.now(),
        ),
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

  return await pdf.save();
}
