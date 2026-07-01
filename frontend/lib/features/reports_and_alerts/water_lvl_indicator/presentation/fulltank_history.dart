import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
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

  bool get _isOverhead => widget.coach.placement.type == 'OVERHEAD';

  WliAsset get _currentAsset => widget.coach.assets[_selectedSensorIndex];

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
          Text(
            '${widget.coach.location.coachName} | ${widget.coach.placement.type}',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
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
            onTap: () => setState(() => selectedPeriod = period),
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
    final demoSpots = _generateDemoSpots(percent);

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
                      'Y-AXIS: FILL % | X-AXIS: TIME',
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
              Expanded(child: _buildWaterLineChart(demoSpots)),
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
            verticalInterval: 1,
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const labels = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'];
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
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
    return Row(
      children: [
        _buildStatItem('Current Level', '${percent.toStringAsFixed(1)}%', _getStatusColor(percent)),
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
    final historyData = [
      {'date': 'Yesterday, 10:45 AM', 'level': '${(_currentAsset.percentFull * 0.85).toStringAsFixed(0)}%'},
      {'date': '08/02/2026, 12:45 PM', 'level': '${(_currentAsset.percentFull * 0.6).toStringAsFixed(0)}%'},
      {'date': '07/02/2026, 09:45 AM', 'level': '${(_currentAsset.percentFull * 0.4).toStringAsFixed(0)}%'},
      {'date': '06/02/2026, 06:45 PM', 'level': '${(_currentAsset.percentFull * 0.7).toStringAsFixed(0)}%'},
      {'date': '05/02/2026, 04:45 PM', 'level': '${(_currentAsset.percentFull * 0.5).toStringAsFixed(0)}%'},
      {'date': '04/02/2026, 03:45 PM', 'level': '${(_currentAsset.percentFull * 0.3).toStringAsFixed(0)}%'},
    ];

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
}