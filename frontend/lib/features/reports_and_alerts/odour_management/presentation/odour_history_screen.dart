import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import '../data/models/odour_model.dart';
import '../data/repository/odour_repository.dart';
import 'widgets/odour_history_exporter.dart';

class OdourHistoryScreen extends StatefulWidget {
  final OdourCoachModel toilet;
  const OdourHistoryScreen({super.key, required this.toilet});

  @override
  State<OdourHistoryScreen> createState() => _OdourHistoryScreenState();
}

class _OdourHistoryScreenState extends State<OdourHistoryScreen> {
  String _selectedPeriod = '7 Days';
  DateTimeRange? _customRange;
  bool _isLoading = true;
  String? _error;
  List<OdourHistoryPoint> _points = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _startDate {
    final now = DateTime.now();
    if (_selectedPeriod == '7 Days') return now.subtract(const Duration(days: 7));
    if (_selectedPeriod == '30 Days') return now.subtract(const Duration(days: 30));
    if (_customRange != null) return _customRange!.start;
    return now.subtract(const Duration(days: 7));
  }

  DateTime get _endDate {
    if (_selectedPeriod == 'Custom' && _customRange != null) return _customRange!.end;
    return DateTime.now();
  }

  int _smartBucketMinutes(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days <= 7) return 5;
    if (days <= 14) return 10;
    if (days <= 30) return 15;
    return 30;
  }

  int? _totalRaw;

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = OdourRepository();
      final bucketMin = _smartBucketMinutes(_startDate, _endDate);

      List<OdourHistoryPoint> points = [];
      int? rawCount;

      final aggResult = await repo.getAggregatedHistory(
        widget.toilet.deviceId,
        widget.toilet.section,
        startDate: _startDate,
        endDate: _endDate,
        bucketMinutes: bucketMin,
      );
      if (aggResult != null && aggResult['buckets'] is List && (aggResult['buckets'] as List).isNotEmpty) {
        points = (aggResult['buckets'] as List)
            .map((e) => OdourHistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList();
        rawCount = (aggResult['totalRaw'] as int?) ?? points.length;
      } else {
        points = await repo.getOdourHistory(
          widget.toilet.deviceId,
          widget.toilet.section,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      points.sort((a, b) {
        final ta = DateTime.tryParse(a.timestamp);
        final tb = DateTime.tryParse(b.timestamp);
        if (ta == null || tb == null) return 0;
        return tb.compareTo(ta);
      });
      if (mounted) {
        setState(() {
          _points = points;
          _totalRaw = rawCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: now,
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: ColorConstants.primary)),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _selectedPeriod = 'Custom';
      });
      _load();
    }
  }

  String _fmtDisplay(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _fmtTimestamp(String raw) {
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(normalized).toLocal());
    } catch (_) {
      return raw;
    }
  }

  Color _hygieneColor(double hygiene) {
    if (hygiene <= 20) return const Color(0xFFD32F2F);
    if (hygiene <= 40) return const Color(0xFFBE8B22);
    return const Color(0xFF2E7D32);
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.toilet.coachNumber} - History Logs', style: AppTextStyles.header1),
            if (_totalRaw != null && !_isLoading)
              Text(
                '${_points.length} intervals from $_totalRaw readings',
                style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textTertiary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: ColorConstants.primary),
            tooltip: 'Export history',
            onPressed: _points.isEmpty
                ? null
                : () => OdourHistoryExporter.export(context, widget.toilet, _points, _startDate, _endDate),
          ),
          const SizedBox(width: 4),
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
                _load();
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
                style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (_points.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48, color: ColorConstants.iconGrey),
            const SizedBox(height: 12),
            Text('No history in this period', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: ColorConstants.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _points.length,
        itemBuilder: (context, index) => _buildHistoryCard(_points[index]),
      ),
    );
  }

  Widget _buildHistoryCard(OdourHistoryPoint point) {
    final hygiene = point.hygieneScore;
    final level = point.status;
    final color = _hygieneColor(hygiene);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(children: [
              const Icon(Icons.access_time, size: 14, color: ColorConstants.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _fmtTimestamp(point.timestamp),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(level.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _detailTile('Hygiene Score', '${hygiene.toStringAsFixed(0)}%', color)),
                  const SizedBox(width: 12),
                  Expanded(child: _detailTile('VOC', point.voc.toStringAsFixed(2), ColorConstants.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _detailTile('NH₃ (ppm)', point.nh3.toStringAsFixed(2), ColorConstants.textPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: _detailTile('H₂S (ppm)', point.h2s.toStringAsFixed(2), ColorConstants.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _detailTile('CH₄ (ppm)', point.methane.toStringAsFixed(2), ColorConstants.textPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: _detailTile('Temp / Humidity', '${point.temperature.toStringAsFixed(1)}°C / ${point.humidity.toStringAsFixed(0)}%', ColorConstants.textPrimary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}
