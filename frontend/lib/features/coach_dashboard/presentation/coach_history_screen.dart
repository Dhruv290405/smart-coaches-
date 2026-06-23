import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_coach_history_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import '../../../core/di/inject.dart';
import '../../../core/widgets/period_filter.dart';

class CoachHistoryScreen extends StatefulWidget {
  final String coachNo;
  final String deviceId;

  const CoachHistoryScreen({
    super.key,
    required this.coachNo,
    this.deviceId = 'N/A',
  });

  @override
  State<CoachHistoryScreen> createState() => _CoachHistoryScreenState();
}

class _CoachHistoryScreenState extends State<CoachHistoryScreen> {
  String _selectedPeriod = '7 Days';
  DateTimeRange? _customRange;
  List<AcpCoachHistoryEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  String _periodStartDate() {
    final now = DateTime.now();
    if (_selectedPeriod == '7 Days') {
      return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
    } else if (_selectedPeriod == '30 Days') {
      return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
    } else if (_selectedPeriod == 'Custom' && _customRange != null) {
      return DateFormat('yyyy-MM-dd').format(_customRange!.start);
    }
    return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
  }

  String _periodEndDate() {
    if (_selectedPeriod == 'Custom' && _customRange != null) {
      return DateFormat('yyyy-MM-dd').format(_customRange!.end);
    }
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await getIt<AcpRepository>().getAcpCoachHistory(
        coachId: widget.coachNo,
        fromDate: _periodStartDate(),
        toDate: _periodEndDate(),
      );
      setState(() {
        _entries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _selectedPeriod = 'Custom';
      });
      _fetchHistory();
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(
          'ACP History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_railway, color: Colors.white70, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coach No', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
              Text(widget.coachNo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (widget.deviceId != 'N/A') ...[
                const SizedBox(height: 2),
                Text('Device ID: ${widget.deviceId}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.coachNo} — Chain Pull History',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          PeriodFilter(
            selected: _selectedPeriod,
            periods: const ['7 Days', '30 Days', 'Custom'],
            onChanged: (value) async {
              if (value == 'Custom') {
                await _pickCustomRange();
              } else {
                setState(() {
                  _selectedPeriod = value;
                  _customRange = null;
                });
                _fetchHistory();
              }
            },
          ),
          if (_selectedPeriod == 'Custom' && _customRange != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_fmt(_customRange!.start)}  →  ${_fmt(_customRange!.end)}',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF2563EB), fontWeight: FontWeight.w500),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Failed to load history', style: GoogleFonts.poppins(color: Colors.red)),
                  ],
                ),
              ),
            )
          else if (_entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No history in this period', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_entries.length, (i) => _buildHistoryCard(_entries[i], i + 1)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AcpCoachHistoryEntry entry, int index) {
    final formattedTime = entry.eventTime != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(entry.eventDate)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildRow('Coach No', widget.coachNo),
                _buildRow('Device ID', widget.deviceId),
                const Divider(color: Color(0xFFE2E8F0)),
                _buildRow('Today Count', entry.todayPullsCount?.toString() ?? 'N/A'),
                _buildRow('Total Count', entry.totalLifetimePulls?.toString() ?? 'N/A'),
                const Divider(color: Color(0xFFE2E8F0)),
                _buildRow('Location', entry.trainLocation ?? 'N/A'),
                _buildRow('Updated At', formattedTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
