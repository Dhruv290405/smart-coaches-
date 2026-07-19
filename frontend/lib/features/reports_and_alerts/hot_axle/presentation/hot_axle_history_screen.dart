import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
      final isHams = widget.coach.coachType == 'HAMS' || widget.coach.coachNumber.startsWith('Master:');
      final params = <String, dynamic>{
        'coachNumber': widget.coach.coachNumber,
        'coachType': widget.coach.coachType,
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

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return const Color(0xFFBE8B22);
      case 'critical':
        return const Color(0xFFD32F2F);
      default:
        return ColorConstants.iconGrey;
    }
  }

  static String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(normalized).toLocal());
    } catch (_) {
      return raw;
    }
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
        title: Text(
          widget.axleNumber != null
              ? 'Axle ${widget.axleNumber} - History'
              : widget.deviceId != null
                  ? '${widget.deviceId} - History'
                  : '${widget.coach.coachNumber} - History',
          style: AppTextStyles.header1,
        ),
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
                  fontSize: 12,
                  color: ColorConstants.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
          return _buildHistoryCard(_items[index]);
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.primary,
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
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatTimestamp(item.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textPrimary,
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
                // Max temp highlight
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Temp',
                          style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary),
                        ),
                        Text(
                          '${item.maxTemp.toStringAsFixed(1)}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textSecondary,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorConstants.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary),
          ),
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
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
          ),
          Text(
            '${temp.toStringAsFixed(1)}°',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHot ? const Color(0xFFD32F2F) : ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
