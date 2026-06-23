import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';
import '../data/models/hot_axle_model.dart';

class HotAxleChartView extends StatefulWidget {
  final List<HotAxleCoachModel> coaches;
  const HotAxleChartView({super.key, required this.coaches});

  @override
  State<HotAxleChartView> createState() => _HotAxleChartViewState();
}

class _HotAxleChartViewState extends State<HotAxleChartView> {
  String selectedPeriod = 'Live';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Temperature Trends', style: AppTextStyles.header2),
            Flexible(
              child: PeriodFilter(
                selected: selectedPeriod,
                periods: const ['Live', '7 Days', '30 Days'],
                onChanged: (v) => setState(() => selectedPeriod = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 20,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => const FlLine(color: ColorConstants.divider, strokeWidth: 1),
                getDrawingVerticalLine: (value) => const FlLine(color: ColorConstants.divider, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      String text = '';
                      if (selectedPeriod == 'Live') {
                        text = '${value.toInt()}:00';
                      } else {
                        text = 'Day ${value.toInt()}';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textTertiary)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}°C', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textTertiary));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: selectedPeriod == 'Live' ? 12 : (selectedPeriod == '7 Days' ? 7 : 30),
              minY: 0,
              maxY: 120,
              clipData: const FlClipData.all(),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(),
                  isCurved: true,
                  gradient: const LinearGradient(colors: [ColorConstants.primary, Color(0xFFFF5252)]),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [ColorConstants.primary.withValues(alpha: 0.2), ColorConstants.primary.withValues(alpha: 0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  List<FlSpot> _generateSpots() {
    // Dummy chronological data showing temperature fluctuations
    if (selectedPeriod == 'Live') {
      return const [
        FlSpot(0, 45), FlSpot(1, 48), FlSpot(2, 52), FlSpot(3, 50),
        FlSpot(4, 55), FlSpot(5, 65), FlSpot(6, 75), FlSpot(7, 85),
        FlSpot(8, 80), FlSpot(9, 70), FlSpot(10, 60), FlSpot(11, 55), FlSpot(12, 50),
      ];
    } else if (selectedPeriod == '7 Days') {
      return const [
        FlSpot(0, 40), FlSpot(1, 42), FlSpot(2, 60), FlSpot(3, 45),
        FlSpot(4, 38), FlSpot(5, 55), FlSpot(6, 40), FlSpot(7, 45),
      ];
    } else {
      return List.generate(31, (i) => FlSpot(i.toDouble(), 40 + (i % 10).toDouble() * 4));
    }
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('Critical Temp', const Color(0xFFFF5252)),
        const SizedBox(width: 16),
        _legendItem('Normal Temp', ColorConstants.primary),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
