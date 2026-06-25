import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/models/diesel_tank_model.dart';

class DieselReportGenerator {
  static Future<void> generate(BuildContext context, List<DieselTankModel> tanks) async {
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: ColorConstants.primary),
            const SizedBox(height: 16),
            Text('Generating Diesel Report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );

    try {
      File file;
      if (format == 'xlsx') {
        file = await _buildExcel(tanks);
      } else {
        file = await _buildPdf(tanks);
      }
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      _showSuccess(context, file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  static Future<File> _buildPdf(List<DieselTankModel> tanks) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Header(level: 0, text: 'Diesel Level Report', textStyle: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1A3A5C))),
        pw.Paragraph(text: 'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Loco', 'Train', 'Level %', 'Status', 'Capacity (L)', 'Consumption (L/hr)', 'Last Updated'],
          data: tanks.map((t) => [
            t.locoNumber, t.trainName, '${t.percentage}%', t.status,
            '${t.capacity}', '${t.consumptionRate}', t.getFormattedDate(),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A3A5C), borderRadius: const pw.BorderRadius.all(pw.Radius.zero)),
          cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft},
          headerAlignments: {0: pw.Alignment.center},
        ),
      ],
    ));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Diesel_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> _buildExcel(List<DieselTankModel> tanks) async {
    final excel = Excel.createExcel();
    final sheet = excel['Diesel Report'];
    excel.setDefaultSheet('Diesel Report');

    _hdr(sheet, 0, 0, 'Diesel Level Report');
    _hdr(sheet, 1, 0, 'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
    _blank(sheet, 2);

    final headers = ['Loco', 'Train', 'Level %', 'Status', 'Capacity (L)', 'Consumption (L/hr)', 'Last Updated'];
    for (var i = 0; i < headers.length; i++) {
      _col(sheet, 3, i, headers[i]);
    }

    for (var r = 0; r < tanks.length; r++) {
      final t = tanks[r];
      final row = 4 + r;
      final sc = t.status == 'Critical' ? 'D32F2F' : t.status == 'Warning' ? 'BE8B22' : '2E7D32';
      _cell(sheet, row, 0, t.locoNumber);
      _cell(sheet, row, 1, t.trainName);
      _cell(sheet, row, 2, '${t.percentage}%', color: sc);
      _cell(sheet, row, 3, t.status,            color: sc);
      _cell(sheet, row, 4, '${t.capacity}');
      _cell(sheet, row, 5, '${t.consumptionRate}');
      _cell(sheet, row, 6, t.getFormattedDate());
    }

    final totalRow = 4 + tanks.length + 1;
    final good     = tanks.where((t) => t.status == 'Good').length;
    final warning  = tanks.where((t) => t.status == 'Warning').length;
    final critical = tanks.where((t) => t.status == 'Critical').length;
    _col(sheet, totalRow,     0, 'Total Tanks');
    _cell(sheet, totalRow,     1, '${tanks.length}');
    _col(sheet, totalRow + 1, 0, 'Good');
    _cell(sheet, totalRow + 1, 1, '$good',      color: '2E7D32');
    _col(sheet, totalRow + 2, 0, 'Warning');
    _cell(sheet, totalRow + 2, 1, '$warning',   color: 'BE8B22');
    _col(sheet, totalRow + 3, 0, 'Critical');
    _cell(sheet, totalRow + 3, 1, '$critical',  color: 'D32F2F');

    for (var c = 0; c < 7; c++) {
      sheet.setColumnWidth(c, 20);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Diesel_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
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

  static Widget _formatOption(BuildContext context, String label, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

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
          Text('Diesel report generated.', style: GoogleFonts.poppins(fontSize: 13)),
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
        ],
      ),
    );
  }
}
