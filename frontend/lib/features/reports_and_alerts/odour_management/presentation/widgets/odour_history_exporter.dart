import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/models/odour_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/shared/report_pdf_theme.dart';
import 'history_file_saver_stub.dart'
    if (dart.library.io) 'history_file_saver_io.dart'
    if (dart.library.html) 'history_file_saver_web.dart';

/// Exports the history currently shown on [OdourHistoryScreen] (one device,
/// the selected 7/30/Custom period) — mirrors [OdourReportGenerator]'s
/// format choice + Excel/PDF builders, scoped to a single device.
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
              Text('Generating export...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );

    try {
      final List<int> bytes;
      final String fileName;
      if (format == 'xlsx') {
        bytes = _buildExcelBytes(toilet, points, startDate, endDate);
        fileName = 'BODR_History_${toilet.deviceId}_${_fileDate(startDate)}_${_fileDate(endDate)}.xlsx';
      } else {
        bytes = await _buildPdfBytes(toilet, points, startDate, endDate);
        fileName = 'BODR_History_${toilet.deviceId}_${_fileDate(startDate)}_${_fileDate(endDate)}.pdf';
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

  static String _toIst(String raw) {
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(normalized).toLocal());
    } catch (_) {
      return raw;
    }
  }

  static String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  static String _fileDate(DateTime d) => DateFormat('yyyyMMdd').format(d);

  static List<int> _buildExcelBytes(
    OdourCoachModel toilet,
    List<OdourHistoryPoint> points,
    DateTime startDate,
    DateTime endDate,
  ) {
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

    header(0, 0, 'Bad Odour History — ${toilet.coachNumber} (${toilet.deviceId})');
    header(1, 0, 'Train: ${toilet.trainNumber} - ${toilet.trainName}');
    header(2, 0, 'Period: ${_fmtDate(startDate)} -> ${_fmtDate(endDate)}');
    header(3, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');

    final headers = ['S.No.', 'Timestamp (IST)', 'Status', 'Hygiene Score (%)', 'VOC', 'NH3 (ppm)', 'H2S (ppm)', 'CH4 (ppm)', 'Temperature (C)', 'Humidity (%)'];
    for (var i = 0; i < headers.length; i++) {
      colHeader(5, i, headers[i]);
    }

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final row = 6 + i;
      cell(row, 0, (i + 1).toString());
      cell(row, 1, _toIst(p.timestamp));
      cell(row, 2, p.status);
      cell(row, 3, p.hygieneScore.toStringAsFixed(0));
      cell(row, 4, p.voc.toStringAsFixed(2));
      cell(row, 5, p.nh3.toStringAsFixed(2));
      cell(row, 6, p.h2s.toStringAsFixed(2));
      cell(row, 7, p.methane.toStringAsFixed(2));
      cell(row, 8, p.temperature.toStringAsFixed(1));
      cell(row, 9, p.humidity.toStringAsFixed(0));
    }

    return excel.encode()!;
  }

  static Future<List<int>> _buildPdfBytes(
    OdourCoachModel toilet,
    List<OdourHistoryPoint> points,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();
    final tableData = <List<String>>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      tableData.add([
        (i + 1).toString(),
        _toIst(p.timestamp),
        p.status,
        p.hygieneScore.toStringAsFixed(0),
        p.voc.toStringAsFixed(2),
        p.nh3.toStringAsFixed(2),
        p.h2s.toStringAsFixed(2),
        p.methane.toStringAsFixed(2),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          ...ReportPdfTheme.header(
            title: 'Bad Odour History — ${toilet.coachNumber} (${toilet.deviceId})',
            summary: 'Train: ${toilet.trainNumber} - ${toilet.trainName} | Period: ${_fmtDate(startDate)} -> ${_fmtDate(endDate)} | Readings: ${points.length}',
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

    return pdf.save();
  }

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
