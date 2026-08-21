import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_history_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class HotAxleHistoryScreen extends StatefulWidget {
  final HotAxleCoachModel coach;
  final int? axleNumber;
  final String? deviceId;
  const HotAxleHistoryScreen({super.key, required this.coach, this.axleNumber, this.deviceId});

  @override
  State<HotAxleHistoryScreen> createState() => _HotAxleHistoryScreenState();
}

class _HotAxleHistoryScreenState extends State<HotAxleHistoryScreen> {
  String _selectedPeriod = '7 Days';
  DateTimeRange? _customRange;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  final List<HotAxleHistoryItem> _items = [];
  int _currentPage = 1;
  int _totalPages = 1;

  /// True when this screen is for a specific axle (not the full history)
  bool get _isParticularAxle => widget.axleNumber != null || widget.deviceId != null;

  @override
  void initState() {
    super.initState();
    _loadHistory(reset: true);
  }

  String get _startDate {
    final now = DateTime.now();
    if (_selectedPeriod == '7 Days') {
      return _fmtDate(now.subtract(const Duration(days: 7)));
    } else if (_selectedPeriod == '30 Days') {
      return _fmtDate(now.subtract(const Duration(days: 30)));
    } else if (_customRange != null) {
      return _fmtDate(_customRange!.start);
    }
    return _fmtDate(now.subtract(const Duration(days: 7)));
  }

  String get _endDate {
    if (_selectedPeriod == 'Custom' && _customRange != null) {
      return _fmtDate(_customRange!.end);
    }
    return _fmtDate(DateTime.now());
  }

  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _loadHistory({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _items.clear();
        _currentPage = 1;
        _totalPages = 1;
      });
    } else {
      setState(() { _isLoadingMore = true; });
    }

    try {
      final page = reset ? 1 : _currentPage + 1;
      final isHams = widget.coach.isHamsCoach;
      final params = <String, dynamic>{
        'coachNumber': widget.coach.coachNumber,
        'coachType': isHams ? 'HAMS' : widget.coach.coachType,
        'coachDeviceId': widget.coach.deviceId,
        'startDate': _startDate,
        'endDate': _endDate,
        'page': page,
        'limit': 30,
      };
      if (widget.deviceId != null) {
        params['deviceId'] = widget.deviceId;
      } else if (widget.axleNumber != null && !isHams) {
        params['axleNumber'] = widget.axleNumber.toString();
      }
      final resp = await getIt<ApiClient>().get('/hot-axle/history', queryParams: params);
      final parsed = HotAxleHistoryResponse.fromJson(resp as Map<String, dynamic>);
      setState(() {
        if (reset) _items.clear();
        _items.addAll(parsed.data ?? []);
        _currentPage = parsed.meta?.currentPage ?? page;
        _totalPages = parsed.meta?.totalPages ?? 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _selectedPeriod = 'Custom';
      });
      _loadHistory(reset: true);
    }
  }

  // ─── Report Generation ─────────────────────────────────────────────────────

  Future<void> _generateReport() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No history data to export'), backgroundColor: Colors.orange),
      );
      return;
    }

    final String? format = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Report Format',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
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
    if (format == null || !context.mounted) return;

    // Show loading dialog
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
            Text('Generating Report…',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );

    try {
      final File file;
      if (format == 'xlsx') {
        file = await _buildExcel();
      } else {
        file = await _buildPdf();
      }
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) _showSuccess(file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<File> _buildExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['History'];
    excel.setDefaultSheet('History');

    final title = _isParticularAxle
        ? 'Axle History — ${widget.deviceId ?? 'Axle ${widget.axleNumber}'}'
        : 'All Axle History — ${widget.coach.coachNumber}';

    void hdr(int r, int c, String t) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
      cell.value = TextCellValue(t);
      cell.cellStyle = CellStyle(bold: true, fontSize: 13, fontColorHex: ExcelColor.fromHexString('#1565C0'));
    }

    void col(int r, int c, String t) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
      cell.value = TextCellValue(t);
      cell.cellStyle = CellStyle(bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          fontSize: 11);
    }

    void cell(int r, int c, String t, {String? color}) {
      final ce = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
      ce.value = TextCellValue(t);
      ce.cellStyle = color != null
          ? CellStyle(fontColorHex: ExcelColor.fromHexString('#$color'), bold: true, fontSize: 11)
          : CellStyle(fontSize: 11);
    }

    hdr(0, 0, title);
    hdr(1, 0, 'Period: $_startDate  →  $_endDate');
    hdr(2, 0, 'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('');

    if (_isParticularAxle) {
      final headers = ['Timestamp', 'Axle Temperature (°C)', 'Temperature Status', 'Battery Voltage (V)', 'Battery Status'];
      for (var i = 0; i < headers.length; i++) col(4, i, headers[i]);
      for (var r = 0; r < _items.length; r++) {
        final item = _items[r];
        final axleTemp = item.maxTemp;
        final sc = item.status == 'Critical' ? 'D32F2F' : item.status == 'Warning' ? 'BE8B22' : null;
        cell(5 + r, 0, _formatTimestampRaw(item.timestamp));
        cell(5 + r, 1, '${axleTemp.toStringAsFixed(1)}°C', color: sc);
        cell(5 + r, 2, item.status, color: sc);
        cell(5 + r, 3, '${item.batteryVoltage.toStringAsFixed(2)} V');
        cell(5 + r, 4, item.batteryStatus);
      }
      for (var c = 0; c < 5; c++) sheet.setColumnWidth(c, 24);
    } else {
      final headers = ['Timestamp', 'Device/Coach', 'Status', 'Max Temp (°C)',
          'A1-1', 'A1-2', 'A2-1', 'A2-2', 'A3-1', 'A3-2', 'A4-1', 'A4-2',
          'Battery %', 'Signal'];
      for (var i = 0; i < headers.length; i++) col(4, i, headers[i]);
      for (var r = 0; r < _items.length; r++) {
        final item = _items[r];
        final sc = item.status == 'Critical' ? 'D32F2F' : item.status == 'Warning' ? 'BE8B22' : null;
        cell(5 + r, 0, _formatTimestampRaw(item.timestamp));
        cell(5 + r, 1, item.deviceId ?? item.coachNumber ?? '');
        cell(5 + r, 2, item.status, color: sc);
        cell(5 + r, 3, '${item.maxTemp.toStringAsFixed(1)}°C', color: sc);
        cell(5 + r, 4, '${item.a11Temp.toStringAsFixed(1)}');
        cell(5 + r, 5, '${item.a12Temp.toStringAsFixed(1)}');
        cell(5 + r, 6, '${item.a21Temp.toStringAsFixed(1)}');
        cell(5 + r, 7, '${item.a22Temp.toStringAsFixed(1)}');
        cell(5 + r, 8, '${item.a31Temp.toStringAsFixed(1)}');
        cell(5 + r, 9, '${item.a32Temp.toStringAsFixed(1)}');
        cell(5 + r, 10, '${item.a41Temp.toStringAsFixed(1)}');
        cell(5 + r, 11, '${item.a42Temp.toStringAsFixed(1)}');
        cell(5 + r, 12, '${item.batteryPercentage}%');
        cell(5 + r, 13, '${item.signalStrength} dBm');
      }
      for (var c = 0; c < 14; c++) sheet.setColumnWidth(c, 18);
    }

    final dir = await getApplicationDocumentsDirectory();
    final label = (_isParticularAxle
        ? (widget.deviceId ?? 'Axle${widget.axleNumber}')
        : widget.coach.coachNumber).replaceAll(RegExp(r'[:/\\]'), '_');
    final file = File('${dir.path}/HotAxle_History_${label}_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> _buildPdf() async {
    final pdf = pw.Document();
    final title = _isParticularAxle
        ? 'Axle History — ${widget.deviceId ?? 'Axle ${widget.axleNumber}'}'
        : 'All Axle History — ${widget.coach.coachNumber}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Period: $_startDate → $_endDate  |  Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 16),
          if (_isParticularAxle)
            pw.TableHelper.fromTextArray(
              headers: ['Timestamp', 'Axle Temp (°C)', 'Status', 'Battery Voltage', 'Battery Status'],
              data: _items.map((item) => [
                _formatTimestampRaw(item.timestamp),
                '${item.maxTemp.toStringAsFixed(1)}°C',
                item.status,
                '${item.batteryVoltage.toStringAsFixed(2)} V',
                item.batteryStatus,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Timestamp', 'Device', 'Status', 'Max Temp', 'A1-1','A1-2','A2-1','A2-2','A3-1','A3-2','A4-1','A4-2','Bat%'],
              data: _items.map((item) => [
                _formatTimestampRaw(item.timestamp),
                item.deviceId ?? item.coachNumber ?? '',
                item.status,
                '${item.maxTemp.toStringAsFixed(1)}°C',
                '${item.a11Temp.toStringAsFixed(1)}',
                '${item.a12Temp.toStringAsFixed(1)}',
                '${item.a21Temp.toStringAsFixed(1)}',
                '${item.a22Temp.toStringAsFixed(1)}',
                '${item.a31Temp.toStringAsFixed(1)}',
                '${item.a32Temp.toStringAsFixed(1)}',
                '${item.a41Temp.toStringAsFixed(1)}',
                '${item.a42Temp.toStringAsFixed(1)}',
                '${item.batteryPercentage}%',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
            ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final label = (_isParticularAxle
        ? (widget.deviceId ?? 'Axle${widget.axleNumber}')
        : widget.coach.coachNumber).replaceAll(RegExp(r'[:/\\]'), '_');
    final file = File('${dir.path}/HotAxle_History_${label}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  void _showSuccess(String path) {
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
          Text('History report generated successfully.',
              style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text(path.split('/').last,
                style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins(color: ColorConstants.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () { Navigator.pop(context); OpenFile.open(path); },
            child: Text('Open File', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)], text: 'Hot Axle History Report');
            },
            child: Text('Share', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _formatOption(BuildContext ctx, String label, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ]),
      ),
    );
  }

  // ─── Status helpers ─────────────────────────────────────────────────────────

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default: return ColorConstants.iconGrey;
    }
  }

  static String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(normalized).toLocal());
    } catch (_) { return raw; }
  }

  static String _formatTimestampRaw(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(normalized).toLocal());
    } catch (_) { return raw; }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(
          widget.axleNumber != null
              ? 'Axle ${widget.axleNumber} - History'
              : widget.deviceId != null
                  ? '${widget.deviceId} - History'
                  : '${widget.coach.coachNumber} - History',
          style: AppTextStyles.header1,
        ),
        actions: [
          IconButton(
            tooltip: 'Generate Report',
            icon: const Icon(Icons.download_rounded, color: ColorConstants.primary),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: ColorConstants.scaffoldBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PeriodFilter(
            selected: _selectedPeriod,
            periods: const ['7 Days', '30 Days', 'Custom'],
            onChanged: (val) async {
              if (val == 'Custom') {
                await _pickCustomRange();
              } else {
                setState(() {
                  _selectedPeriod = val;
                  _customRange = null;
                });
                _loadHistory(reset: true);
              }
            },
          ),
          if (_selectedPeriod == 'Custom' && _customRange != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_fmtDisplay(_customRange!.start)}  →  ${_fmtDisplay(_customRange!.end)}',
                style: GoogleFonts.poppins(
                  fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Generate Report button inline
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.file_download_outlined, size: 18, color: ColorConstants.primary),
              label: Text(
                'Generate Report (${_items.length} records)',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstants.primary),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: ColorConstants.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ColorConstants.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: ColorConstants.iconGrey),
              const SizedBox(height: 12),
              Text('Failed to load history', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _loadHistory(reset: true),
                style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48, color: ColorConstants.iconGrey),
            const SizedBox(height: 12),
            Text(
              'No history in this period',
              style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistory(reset: true),
      color: ColorConstants.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _items.length + (_currentPage < _totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _buildShowMoreButton();
          }
          // Show different card based on context
          return _isParticularAxle
              ? _buildParticularAxleCard(_items[index])
              : _buildHistoryCard(_items[index]);
        },
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: ColorConstants.primary)
            : OutlinedButton.icon(
                onPressed: () => _loadHistory(reset: false),
                icon: const Icon(Icons.expand_more, color: ColorConstants.primary),
                label: Text(
                  'Show More',
                  style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500, color: ColorConstants.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: const BorderSide(color: ColorConstants.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
      ),
    );
  }

  // ─── Particular Axle Card (simplified) ──────────────────────────────────────

  Widget _buildParticularAxleCard(HotAxleHistoryItem item) {
    final axleTemp = item.maxTemp;
    final statusColor = _statusColor(item.status);
    final batStatusColor = item.batteryStatus.toLowerCase() == 'low'
        ? const Color(0xFFD32F2F)
        : item.batteryStatus.toLowerCase() == 'high'
            ? Colors.green
            : const Color(0xFFBE8B22);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: timestamp + status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.access_time, size: 14, color: ColorConstants.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatTimestamp(item.timestamp),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary),
                ),
              ),
              _buildStatusBadge(item.status, statusColor),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: Axle temp + Temp status
                Row(children: [
                  Expanded(child: _detailTile(
                    icon: Icons.thermostat,
                    label: 'Axle Temperature',
                    value: '${axleTemp.toStringAsFixed(1)}°C',
                    valueColor: axleTemp > 60 ? statusColor : null,
                    iconColor: axleTemp > 60 ? statusColor : ColorConstants.primary,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _detailTile(
                    icon: Icons.info_outline,
                    label: 'Temperature Status',
                    value: item.status,
                    valueColor: statusColor,
                    iconColor: statusColor,
                  )),
                ]),
                const SizedBox(height: 12),
                const Divider(color: ColorConstants.divider, height: 1),
                const SizedBox(height: 12),
                // Row 2: Battery voltage + Battery status
                Row(children: [
                  Expanded(child: _detailTile(
                    icon: Icons.bolt,
                    label: 'Battery Voltage',
                    value: '${item.batteryVoltage.toStringAsFixed(2)} V',
                    iconColor: ColorConstants.primary,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _detailTile(
                    icon: Icons.battery_charging_full,
                    label: 'Battery Status',
                    value: item.batteryStatus,
                    valueColor: batStatusColor,
                    iconColor: batStatusColor,
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 13, color: iconColor ?? ColorConstants.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Full History Card (all axles) ───────────────────────────────────────────

  Widget _buildHistoryCard(HotAxleHistoryItem item) {
    final statusColor = _statusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatTimestamp(item.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(item.status, statusColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max Temp',
                            style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
                        Text(
                          '${item.maxTemp.toStringAsFixed(1)}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: item.maxTemp > 60 ? statusColor : ColorConstants.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildInfoPill(Icons.battery_charging_full, '${item.batteryPercentage}%'),
                    const SizedBox(width: 8),
                    _buildInfoPill(Icons.signal_cellular_alt, '${item.signalStrength} dBm'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: ColorConstants.divider),
                const SizedBox(height: 8),
                Text(
                  'Axle Temperatures (°C)',
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  children: [
                    _axleCell('A1-1', item.a11Temp),
                    _axleCell('A1-2', item.a12Temp),
                    _axleCell('A2-1', item.a21Temp),
                    _axleCell('A2-2', item.a22Temp),
                    _axleCell('A3-1', item.a31Temp),
                    _axleCell('A3-2', item.a32Temp),
                    _axleCell('A4-1', item.a41Temp),
                    _axleCell('A4-2', item.a42Temp),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorConstants.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
        ],
      ),
    );
  }

  Widget _axleCell(String label, double temp) {
    final isHot = temp > 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isHot ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
          Text(
            '${temp.toStringAsFixed(1)}°',
            style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: isHot ? const Color(0xFFD32F2F) : ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
