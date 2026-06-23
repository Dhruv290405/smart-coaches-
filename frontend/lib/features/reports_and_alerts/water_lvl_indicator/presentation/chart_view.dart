import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/water_tank_model.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';

class ChartView extends StatefulWidget {
  final List<WaterTankModel> coaches;
  const ChartView({super.key, required this.coaches});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.timeSeries;
  DateTimeRange? customRange;

  List<WaterTankModel> get filteredCoaches {
    if (selectedPeriod == 'Live') return widget.coaches;

    DateTime now = DateTime.now();
    DateTime? startDate;

    if (selectedPeriod == '7 Days') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (selectedPeriod == '30 Days') {
      startDate = now.subtract(const Duration(days: 30));
    } else if (selectedPeriod == 'Custom' && customRange != null) {
      startDate = customRange!.start;
    }

    if (startDate == null) return widget.coaches;

    return widget.coaches.where((c) {
      try {
        final t = DateTime.parse(c.timestamp);
        return t.isAfter(startDate!);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int get goodCount => filteredCoaches.where((c) => c.status == 'Good').length;
  int get warningCount => filteredCoaches.where((c) => c.status == 'Warning').length;
  int get criticalCount => filteredCoaches.where((c) => c.status == 'Critical').length;
  int get total => filteredCoaches.length;

  List<FlSpot> get timeSeriesData {
    if (selectedPeriod == 'Live') {
      final avgLevels = [72.0, 68.0, 74.0, 65.0, 80.0, 78.0, 85.0];
      return List.generate(avgLevels.length, (i) => FlSpot(i.toDouble(), avgLevels[i]));
    }
    final days = selectedPeriod == '7 Days' ? 7 : 30;
    return List.generate(days + 1, (i) {
      final val = 60.0 + (i % 5 == 0 ? 20.0 : (i % 3 == 0 ? 10.0 : 5.0));
      return FlSpot(i.toDouble(), val.clamp(0, 100));
    });
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: customRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        customRange = range;
        selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (value) async {
            if (value == 'Custom') {
              await _pickCustomRange();
            } else {
              setState(() {
                selectedPeriod = value;
                customRange = null;
              });
            }
          },
        ),

        if (selectedPeriod == 'Custom' && customRange != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_fmt(customRange!.start)}  →  ${_fmt(customRange!.end)}',
              style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Water Level Trends', style: AppTextStyles.header2)),
            _chartTypeToggle(AppStrings.timeSeries),
            const SizedBox(width: 8),
            _chartTypeToggle(AppStrings.pieChart),
          ],
        ),
        const SizedBox(height: 16),

        if (selectedChartType == AppStrings.pieChart)
          _buildPieChart()
        else
          _buildTimeSeriesChart(),

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
          border: Border.all(
            color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final hasData = goodCount > 0 || warningCount > 0 || criticalCount > 0;
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 56,
                  sections: hasData
                      ? [
                          if (goodCount > 0)
                            PieChartSectionData(value: goodCount.toDouble(), color: Colors.green, radius: 60, showTitle: false),
                          if (warningCount > 0)
                            PieChartSectionData(value: warningCount.toDouble(), color: const Color(0xFFBE8B22), radius: 60, showTitle: false),
                          if (criticalCount > 0)
                            PieChartSectionData(value: criticalCount.toDouble(), color: const Color(0xFFD32F2F), radius: 60, showTitle: false),
                        ]
                      : [
                          PieChartSectionData(value: 1, color: ColorConstants.divider, radius: 60, showTitle: false),
                        ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                  Text('Sensors', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(Colors.green, 'Good ($goodCount)'),
            const SizedBox(width: 16),
            _legend(const Color(0xFFBE8B22), 'Warning ($warningCount)'),
            const SizedBox(width: 16),
            _legend(const Color(0xFFD32F2F), 'Critical ($criticalCount)'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      );

  Widget _buildTimeSeriesChart() {
    final spots = timeSeriesData;
    final maxY = (spots.isEmpty ? 100.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10).clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12, left: 12),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 20,
              verticalInterval: selectedPeriod == 'Live' ? 1 : (selectedPeriod == '7 Days' ? 1 : 5),
              getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
              getDrawingVerticalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: selectedPeriod == 'Live' ? 1 : (selectedPeriod == '7 Days' ? 1 : 5),
                  getTitlesWidget: (value, meta) {
                    if (selectedPeriod == 'Live') {
                      final hour = (DateTime.now().hour - (6 - value.toInt())) % 24;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Day ${value.toInt()}',
                        style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: ColorConstants.divider, width: 1),
            ),
            minX: 0,
            maxX: selectedPeriod == 'Live' ? 6 : (selectedPeriod == '7 Days' ? 7 : 30),
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [ColorConstants.primary, Color(0xFF64B5F6)],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: spots.length <= 10),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      ColorConstants.primary.withValues(alpha: 0.3),
                      const Color(0xFF64B5F6).withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final goodPct = total > 0 ? (goodCount / total * 100).toStringAsFixed(1) : '0';
    final warnPct = total > 0 ? (warningCount / total * 100).toStringAsFixed(1) : '0';
    final critPct = total > 0 ? (criticalCount / total * 100).toStringAsFixed(1) : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Sensors', style: AppTextStyles.bodyMedium),
              Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow('Good', '$goodCount  ($goodPct%)', Colors.green),
          const SizedBox(height: 6),
          _buildStatRow('Warning', '$warningCount  ($warnPct%)', const Color(0xFFBE8B22)),
          const SizedBox(height: 6),
          _buildStatRow('Critical', '$criticalCount  ($critPct%)', const Color(0xFFD32F2F)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? goodCount / total : 0,
              minHeight: 8,
              backgroundColor: ColorConstants.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}