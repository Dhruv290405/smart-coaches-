import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import '../data/datasources/wli_data_service.dart';
import '../data/models/water_tank_model.dart';

class FullTankHistory extends StatefulWidget {
  final WaterTankModel coach;

  const FullTankHistory({super.key, required this.coach});

  @override
  State<FullTankHistory> createState() => _FullTankHistoryState();
}

class _FullTankHistoryState extends State<FullTankHistory> {
  int _selectedSensorIndex = 0;
  String selectedPeriod = 'Live';

  final WliDataService _dataService = WliDataService(baseUrl: ApiConstants.devUrl);
  List<Map<String, dynamic>> _history = [];
  bool _loadingHistory = false;

  bool get _isOverhead => widget.coach.placement.type == 'OVERHEAD';

  WliAsset get _currentAsset => widget.coach.assets[_selectedSensorIndex];

  int get _periodDays {
    switch (selectedPeriod) {
      case '7 Days':
        return 7;
      case '30 Days':
        return 30;
      case '1 Day':
      case 'Live':
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final token = GetIt.I<Prefs>().token;
      final data = await _dataService.fetchHistory(
        deviceId: widget.coach.source.deviceId,
        coachId: widget.coach.location.coachId,
        days: _periodDays,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _history = data;
        _loadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _history = [];
        _loadingHistory = false;
      });
    }
  }

  Color _getStatusColor(double percent) {
    if (percent < 20) return ColorConstants.statusCritical;
    if (percent < 40) return ColorConstants.statusWarning;
    return ColorConstants.statusGood;
  }

  String _getStatus(double percent) {
    if (percent < 20) return 'Critical';
    if (percent < 40) return 'Warning';
    return 'Good';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.coach.location.coachName} – History',
          style: AppTextStyles.header1,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isOverhead) ...[
                _buildSensorTabs(),
                const SizedBox(height: 20),
              ],
              _buildCurrentLevelCard(),
              const SizedBox(height: 20),
              _buildPeriodFilter(),
              const SizedBox(height: 20),
              _buildDarkChartCard(),
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildHistoryTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTabs() {
    final sensors = ['Front End', 'Rear End'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: List.generate(sensors.length, (i) {
          final isSelected = _selectedSensorIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSensorIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? ColorConstants.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    sensors[i],
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected ? ColorConstants.white : ColorConstants.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    final percent = _currentAsset.percentFull;
    final statusColor = _getStatusColor(percent);
    final status = _getStatus(percent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_currentAsset.assetName}: ${percent.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.textPrimary,
                  ),
                ),
              ),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(status, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: statusColor)),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 14,
                    backgroundColor: ColorConstants.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip('${_currentAsset.volumeLiters.toStringAsFixed(1)} L'),
              const SizedBox(width: 8),
              _infoChip('${_currentAsset.levelCm.toStringAsFixed(1)} cm'),
              const SizedBox(width: 8),
              _infoChip('Raw: ${_currentAsset.rawValue}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.coach.location.coachName} | ${widget.coach.placement.type}',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ColorConstants.divider,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: AppTextStyles.bodySmall),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Live', '1 Day', '7 Days', '30 Days'];
    return Row(
      children: periods.map((period) {
        final isSelected = selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              setState(() => selectedPeriod = period);
              _loadHistory();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstants.white : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: isSelected ? ColorConstants.primary : ColorConstants.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                period,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDarkChartCard() {
    final percent = _currentAsset.percentFull;
    final spots = _chartSpots(percent);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WATER LEVEL OVER TIME',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _loadingHistory
                          ? 'LOADING $selectedPeriod HISTORY...'
                          : 'Y-AXIS: FILL % | X-AXIS: TIME (${_history.length} pts)',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _legendItem('Rising', const Color(0xFF059669)),
              _legendItem('Dropping', const Color(0xFFDC2626)),
              _legendItem('Stable', const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'FILL LEVEL (%)',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildWaterLineChart(spots)),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'TIME',
              style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the chart points from real history when available; otherwise fall
  /// back to a synthetic ramp so the chart is never empty.
  List<FlSpot> _chartSpots(double currentPercent) {
    if (_history.isNotEmpty) {
      final points = _history.length > 60
          ? List.generate(60, (i) => _history[((_history.length - 1) * i / 59).round()])
          : _history;
      return List.generate(
        points.length,
        (i) => FlSpot(i.toDouble(), (points[i]['percentFull'] as double).clamp(0, 100)),
      );
    }
    return _generateDemoSpots(currentPercent);
  }

  /// Up to 7 evenly spaced time labels derived from the loaded history.
  List<String> _chartTimeLabels() {
    const fallback = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'];
    if (_history.isEmpty) return fallback;
    final n = _history.length;
    return List.generate(7, (i) {
      final idx = ((n - 1) * i / 6).round().clamp(0, n - 1);
      return _fmtClock(_history[idx]['timestamp']?.toString() ?? '');
    });
  }

  String _fmtClock(String raw) {
    try {
      final dt = raw.contains('T') ? DateTime.parse(raw) : DateTime.parse(raw.replaceFirst(' ', 'T'));
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length >= 16 ? raw.substring(11, 16) : raw;
    }
  }

  List<FlSpot> _generateDemoSpots(double currentPercent) {
    final base = currentPercent.clamp(10.0, 100.0);
    return [
      FlSpot(0, (base * 0.2).clamp(5, 100)),
      FlSpot(1, (base * 0.35).clamp(5, 100)),
      FlSpot(2, (base * 0.5).clamp(5, 100)),
      FlSpot(3, (base * 0.6).clamp(5, 100)),
      FlSpot(4, (base * 0.75).clamp(5, 100)),
      FlSpot(5, (base * 0.85).clamp(5, 100)),
      FlSpot(6, base),
    ];
  }

  Widget _buildWaterLineChart(List<FlSpot> spots) {
    final labels = _chartTimeLabels();
    final tickInterval = spots.length > 1 ? (spots.length - 1) / 6 : 1.0;
    final bottomInterval = tickInterval <= 1 ? 1.0 : tickInterval;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: bottomInterval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFF334155),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: const Color(0xFF334155),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: bottomInterval,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= spots.length) return const SizedBox.shrink();
                  final labelIndex = labels.length == 1 ? 0 : ((labels.length - 1) * i / (spots.length - 1)).round().clamp(0, labels.length - 1).toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[labelIndex],
                      style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 8),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Color(0xFF334155), width: 1),
              left: BorderSide(color: Color(0xFF334155), width: 1),
            ),
          ),
          lineBarsData: _buildColoredSegments(spots),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildColoredSegments(List<FlSpot> spots) {
    final bars = <LineChartBarData>[];
    for (int i = 0; i < spots.length - 1; i++) {
      final current = spots[i].y;
      final next = spots[i + 1].y;
      Color color = const Color(0xFF94A3B8);
      if (next > current + 1) color = const Color(0xFF059669);
      if (next < current - 1) color = const Color(0xFFDC2626);

      bars.add(LineChartBarData(
        spots: [spots[i], spots[i + 1]],
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(
          show: i == 0,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
      ));
    }
    return bars;
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatsCards() {
    final percent = _currentAsset.percentFull;
    return Column(
      children: [
        Row(
          children: [
            _buildStatItem('Current Level', '${percent.toStringAsFixed(1)}%', _getStatusColor(percent)),
            const SizedBox(width: 12),
            _buildStatItem('Volume', '${_currentAsset.volumeLiters.toStringAsFixed(1)} L', ColorConstants.primary),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatItem('Level (cm)', '${_currentAsset.levelCm.toStringAsFixed(1)} cm', ColorConstants.statusGood),
            const SizedBox(width: 12),
            _buildStatItem('Raw Value', '${_currentAsset.rawValue}', ColorConstants.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: AppTextStyles.bodyMedium)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    final historyData = _historyTableRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Level History', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date & Time', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text('Fill Level', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (historyData.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No history for the selected period'),
                ),
              ...historyData.map((entry) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: ColorConstants.divider, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry['date']!, style: AppTextStyles.bodyMedium),
                        Text(entry['level']!, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              'View all',
              style: AppTextStyles.bodyLarge.copyWith(color: ColorConstants.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _historyTableRows() {
    if (_history.isEmpty) return [];
    final recent = _history.length > 10
        ? _history.sublist(_history.length - 10).reversed.toList()
        : _history.reversed.toList();
    return recent
        .map((e) => {
              'date': _fmtDateTime(e['timestamp']?.toString() ?? ''),
              'level': '${(e['percentFull'] as double).toStringAsFixed(0)}%',
            })
        .toList();
  }

  String _fmtDateTime(String raw) {
    try {
      final dt = raw.contains('T') ? DateTime.parse(raw) : DateTime.parse(raw.replaceFirst(' ', 'T'));
      final local = dt.toLocal();
      return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}, '
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}