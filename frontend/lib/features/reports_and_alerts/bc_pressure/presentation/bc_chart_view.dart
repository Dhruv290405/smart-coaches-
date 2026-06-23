import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/datasource/bc_dummy_data.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';

class BCChartView extends StatefulWidget {
  const BCChartView({super.key});

  @override
  State<BCChartView> createState() => _BCChartViewState();
}

class _BCChartViewState extends State<BCChartView> {
  String selectedPeriod = 'Live';
  String selectedCoach  = 'Coach 4';

  final List<String> coaches = List.generate(20, (i) => 'Coach ${i + 1}');

  Map<String, dynamic> get _data =>
      BCDummyData.getChartData(selectedCoach, selectedPeriod);

  List<FlSpot> get _spots => (_data['spots'] as List)
      .map((s) => FlSpot((s[0] as num).toDouble(), (s[1] as num).toDouble()))
      .toList();

  List<String> get _xLabels => (_data['xLabels'] as List).cast<String>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsCards(),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.bcPressureTrend, style: AppTextStyles.header2),
            _buildCoachSelector(),
          ],
        ),
        const SizedBox(height: 16),

        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '1 min', '5 mins', '30 mins', '1 hr', '2 hr', '6 hr', '12 hr'],
          onChanged: (val) => setState(() => selectedPeriod = val),
        ),
        const SizedBox(height: 16),

        _buildLineChart(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            _statItem('Highest', '${_data['highest']} kg/cm²', ColorConstants.primary),
            const SizedBox(width: 12),
            _statItem('Lowest',  '${_data['lowest']} kg/cm²',  const Color(0xFFD32F2F)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statItem('Average', '${_data['average']} kg/cm²', ColorConstants.primary),
            const SizedBox(width: 12),
            _statItem('Brake Count', '${_data['brakeCount']} times', ColorConstants.primary),
          ],
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: AppTextStyles.bodyMedium)),
            const SizedBox(width: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: ColorConstants.primary, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCoach,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: ColorConstants.white, size: 18),
          style: AppTextStyles.badge,
          dropdownColor: ColorConstants.primary,
          items: coaches.map((c) => DropdownMenuItem(
            value: c,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.train, color: ColorConstants.white, size: 14),
              const SizedBox(width: 4),
              Text(c, style: AppTextStyles.badge),
            ]),
          )).toList(),
          onChanged: (val) { if (val != null) setState(() => selectedCoach = val); },
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = _spots;
    final maxX  = spots.isNotEmpty ? spots.last.x : 4.0;
    final isCritical = double.tryParse(_data['lowest'].toString())! < 1.5;
    final lineColor = isCritical ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider, width: 1),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text('Kg/cm²', style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 25,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: AppTextStyles.bodySmall),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxX / (_xLabels.length - 1),
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final step = maxX / (_xLabels.length > 1 ? _xLabels.length - 1 : 1);
                    final idx = (value / step).round();
                    if (idx >= 0 && idx < _xLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_xLabels[idx], style: AppTextStyles.bodySmall.copyWith(fontSize: 9, color: ColorConstants.textSecondary)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: maxX,
            minY: 0, maxY: 5.5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final isLow = spot.y < 1.5;
                    return FlDotCirclePainter(
                      radius: isLow ? 5 : 3,
                      color: isLow ? Colors.red : lineColor,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [lineColor.withValues(alpha: 0.3), lineColor.withValues(alpha: 0.05)],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => ColorConstants.white,
                tooltipBorder: BorderSide(color: ColorConstants.divider, width: 1),
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} Kg/cm²',
                  GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = BCDummyData.getSummary(selectedPeriod);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Column(
        children: [
          _summaryRow('Total Coaches', '${summary['total']}', null),
          const SizedBox(height: 6),
          _summaryRow('Good',     '${summary['good']}',     Colors.green),
          const SizedBox(height: 6),
          _summaryRow('Warning',  '${summary['warning']}',  const Color(0xFFBE8B22)),
          const SizedBox(height: 6),
          _summaryRow('Critical', '${summary['critical']}', const Color(0xFFD32F2F)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color? dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          if (dotColor != null) ...[
            Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ]),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}