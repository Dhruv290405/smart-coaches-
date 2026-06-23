import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'data/models/fsds_model.dart';

class FsdsChartView extends StatefulWidget {
  final List<FsdsAssetModel> assets;
  const FsdsChartView({super.key, required this.assets});

  @override
  State<FsdsChartView> createState() => _FsdsChartViewState();
}

class _FsdsChartViewState extends State<FsdsChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.timeSeries;
  DateTimeRange? customRange;

  List<FsdsAssetModel> get filteredAssets {
    if (selectedPeriod == 'Live') return widget.assets;
    DateTime now = DateTime.now();
    DateTime? startDate;
    if (selectedPeriod == '7 Days') startDate = now.subtract(const Duration(days: 7));
    else if (selectedPeriod == '30 Days') startDate = now.subtract(const Duration(days: 30));
    else if (selectedPeriod == 'Custom' && customRange != null) startDate = customRange!.start;
    
    if (startDate == null) return widget.assets;
    return widget.assets.where((a) {
      try {
        final updateTime = DateTime.parse(a.timestamp);
        return updateTime.isAfter(startDate!);
      } catch (_) { return false; }
    }).toList();
  }

  int get alertCount => filteredAssets.where((a) => a.isSmokeDetected).length;
  int get normalCount => filteredAssets.where((a) => !a.isSmokeDetected).length;
  int get total => filteredAssets.length;

  List<FlSpot> get timeSeriesData {
    final count = filteredAssets.where((a) => a.isRecent).length;
    if (selectedPeriod == 'Live') {
      return [
        const FlSpot(0, 0), const FlSpot(1, 1), const FlSpot(2, 0), const FlSpot(3, 2),
        const FlSpot(4, 1), const FlSpot(5, 3), const FlSpot(6, 2), FlSpot(7, count.toDouble()),
      ];
    } else {
      int days = selectedPeriod == '7 Days' ? 7 : 30;
      List<FlSpot> spots = [];
      for (int i = 0; i <= days; i++) {
        double val = (i % 5 == 0) ? 4.0 : (i % 3 == 0) ? 2.0 : 1.0;
        if (i == days) val = count.toDouble(); 
        spots.add(FlSpot(i.toDouble(), val));
      }
      return spots;
    }
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context, firstDate: DateTime(2026, 1, 1), lastDate: DateTime.now(),
    );
    if (range != null) setState(() { customRange = range; selectedPeriod = 'Custom'; });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (v) async => v == 'Custom' ? await _pickCustomRange() : setState(() { selectedPeriod = v; customRange = null; }),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Smoke Level Timeline', style: AppTextStyles.header2)),
            _chartTypeToggle(AppStrings.timeSeries),
            const SizedBox(width: 8),
            _chartTypeToggle(AppStrings.pieChart),
          ],
        ),
        const SizedBox(height: 16),
        selectedChartType == AppStrings.pieChart ? _buildPieChart() : _buildTimeSeriesChart(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _chartTypeToggle(String label) {
    final isSelected = selectedChartType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedChartType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primary.withValues(alpha: 0.08) : ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: isSelected ? ColorConstants.primary : ColorConstants.divider, width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary)),
      ),
    );
  }

  Widget _buildPieChart() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 56, sections: [
                PieChartSectionData(value: alertCount.toDouble(), color: const Color(0xFFFF3B30), radius: 60, showTitle: false),
                PieChartSectionData(value: normalCount.toDouble(), color: const Color(0xFF34C700), radius: 60, showTitle: false),
              ])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('Total', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(const Color(0xFFFF3B30), 'Alerts ($alertCount)'), const SizedBox(width: 20),
          _legend(const Color(0xFF34C700), 'Normal ($normalCount)'),
        ]),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

  Widget _buildTimeSeriesChart() {
    final spots = timeSeriesData;
    return Container(
      padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12, left: 12),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: SizedBox(
        height: 220,
        child: LineChart(LineChartData(
          clipData: const FlClipData.all(),
          gridData: const FlGridData(show: true, drawVerticalLine: true, horizontalInterval: 1),
          titlesData: FlTitlesData(
            show: true, rightTitles: const AxisTitles(), topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: selectedPeriod == 'Live' ? 1 : 5, getTitlesWidget: (v, m) {
              if (selectedPeriod == 'Live') {
                final h = (DateTime.now().hour - (7 - v.toInt())) % 24;
                return Text('${h.toString().padLeft(2, '0')}:00', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary));
              }
              return Text('D ${v.toInt()}', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary));
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 28)),
          ),
          minX: 0, maxX: selectedPeriod == 'Live' ? 7 : (selectedPeriod == '7 Days' ? 7 : 30), minY: 0,
          maxY: (spots.isEmpty ? 5 : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1).toDouble().clamp(5, 100)),
          lineBarsData: [LineChartBarData(
            spots: spots, isCurved: true, gradient: const LinearGradient(colors: [Colors.red, Colors.orange]),
            barWidth: 3, dotData: FlDotData(show: spots.length < 10),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.red.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          )],
        )),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Assets', style: AppTextStyles.bodyMedium),
          Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        _buildStatRow('Alert Status', '$alertCount', const Color(0xFFFF3B30)),
        const SizedBox(height: 8),
        _buildStatRow('Normal Status', '$normalCount', const Color(0xFF34C700)),
      ]),
    );
  }

  Widget _buildStatRow(String l, String v, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Text(l, style: AppTextStyles.bodyMedium)]),
    Text(v, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
  ]);
}
