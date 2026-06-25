import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import '../../data/models/odour_model.dart';

class OdourChartView extends StatefulWidget {
  final List<OdourCoachModel> coaches;
  const OdourChartView({super.key, required this.coaches});

  @override
  State<OdourChartView> createState() => _OdourChartViewState();
}

class _OdourChartViewState extends State<OdourChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.timeSeries;
  DateTimeRange? customRange;

  List<OdourCoachModel> get filteredCoaches {
    if (selectedPeriod == 'Live') return widget.coaches;
    DateTime now = DateTime.now();
    DateTime? startDate;
    if (selectedPeriod == '7 Days') startDate = now.subtract(const Duration(days: 7));
    else if (selectedPeriod == '30 Days') startDate = now.subtract(const Duration(days: 30));
    else if (selectedPeriod == 'Custom' && customRange != null) startDate = customRange!.start;
    if (startDate == null) return widget.coaches;
    return widget.coaches.where((c) {
      return c.toilets.any((t) => t.isRecent);
    }).toList();
  }

  int get totalCoaches => filteredCoaches.length;
  int get alertCoaches => filteredCoaches.where((c) => c.hasActiveAlert).length;
  int get normalCoaches => totalCoaches - alertCoaches;
  int get totalToilets => filteredCoaches.fold(0, (sum, c) => sum + c.toilets.length);
  int get badToilets => filteredCoaches.fold(0, (sum, c) => sum + c.alertCount);

  List<FlSpot> get timeSeriesData {
    if (selectedPeriod == 'Live') {
      return [
        const FlSpot(0, 1), const FlSpot(1, 2), const FlSpot(2, 1), const FlSpot(3, 3),
        const FlSpot(4, 2), const FlSpot(5, 4), const FlSpot(6, 2), FlSpot(7, badToilets.toDouble()),
      ];
    } else {
      int days = selectedPeriod == '7 Days' ? 7 : 30;
      return List.generate(days + 1, (i) {
        double val = (i % 5 == 0) ? badToilets.toDouble() : (i % 3 == 0) ? 2.0 : 1.0;
        return FlSpot(i.toDouble(), val);
      });
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
    if (widget.coaches.isEmpty) return const SizedBox.shrink();
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
            Expanded(child: Text('Odour Overview', style: AppTextStyles.header2)),
            _chartTypeToggle(AppStrings.timeSeries),
            const SizedBox(width: 8),
            _chartTypeToggle(AppStrings.pieChart),
          ],
        ),
        const SizedBox(height: 16),
        selectedChartType == AppStrings.pieChart ? _buildPieChart() : _buildTimeSeriesChart(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildCoachTable(),
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
                PieChartSectionData(value: normalCoaches.toDouble(), color: Colors.green, radius: 60, showTitle: false),
                PieChartSectionData(value: alertCoaches.toDouble(), color: const Color(0xFFD32F2F), radius: 60, showTitle: false),
              ])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$totalCoaches', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('Coaches', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(Colors.green, 'Normal ($normalCoaches)'), const SizedBox(width: 20),
          _legend(const Color(0xFFD32F2F), 'Alert ($alertCoaches)'),
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
        _buildStatRow('Coaches with Alert', '$alertCoaches', const Color(0xFFD32F2F)),
        const SizedBox(height: 8),
        _buildStatRow('Normal Coaches', '$normalCoaches', Colors.green),
        const SizedBox(height: 8),
        _buildStatRow('Total Toilets Monitored', '$totalToilets', ColorConstants.primary),
        const SizedBox(height: 8),
        _buildStatRow('Bad Odour Toilets', '$badToilets', const Color(0xFFD32F2F)),
      ]),
    );
  }

  Widget _buildStatRow(String l, String v, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Text(l, style: AppTextStyles.bodyMedium)]),
    Text(v, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
  ]);

  Widget _buildCoachTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coach Summary', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...filteredCoaches.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(flex: 2, child: Text(c.coachNumber, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))),
              Expanded(flex: 2, child: Text(c.trainNumber, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary))),
              Expanded(
                flex: 3,
                child: Row(children: c.toilets.map((t) => Container(
                  width: 14, height: 14, margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: t.isBad ? const Color(0xFFD32F2F) : (t.reading > 40 ? const Color(0xFFBE8B22) : Colors.green),
                    shape: BoxShape.circle,
                  ),
                )).toList()),
              ),
              Text('${c.averageReading.toStringAsFixed(0)} ppm', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
            ]),
          )),
        ],
      ),
    );
  }
}
