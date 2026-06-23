import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/widgets/current_level_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/widgets/tank_info_section.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/widgets/view_history_button.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../../../core/widgets/update_info.dart';
import '../data/models/diesel_tank_model.dart';
import 'diesel_tank_history.dart';

class DieselChartView extends StatefulWidget {
  final DieselTankModel tank;

  const DieselChartView({super.key, required this.tank});

  @override
  State<DieselChartView> createState() => _DieselChartViewState();
}

class _DieselChartViewState extends State<DieselChartView> {
  String selectedPeriod = 'Live';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.dieselLevelTrend, style: AppTextStyles.header2),
        const SizedBox(height: 16),

        CurrentLevelCard(
          percentage: widget.tank.percentage,
          status: widget.tank.status,
          subtitle: 'Loco: ${widget.tank.trainName}',
        ),
        const SizedBox(height: 16),

        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (val) => setState(() => selectedPeriod = val),
        ),
        const SizedBox(height: 16),

        _buildLineChart(),
        const SizedBox(height: 12),

        UpdateInfo(
          lastUpdated: widget.tank.getFormattedDate(),
          refilledBy: widget.tank.refilledBy,
        ),
        const SizedBox(height: 24),

        TankInfoSection(title: AppStrings.dieselTankInfo, tank: widget.tank),
        const SizedBox(height: 20),

        ViewHistoryButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DieselTankHistory(tank: widget.tank),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1000,
              getDrawingHorizontalLine: (value) => FlLine(
                color: ColorConstants.divider,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}L',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    const labels = [
                      '09:00 AM',
                      '11:00 AM',
                      '08:00 PM',
                      'Now'
                    ];
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[value.toInt()],
                          style:
                              AppTextStyles.bodySmall.copyWith(fontSize: 9),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 3,
            minY: 0,
            maxY: 5000,
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 500),
                  FlSpot(0.5, 800),
                  FlSpot(1, 1500),
                  FlSpot(1.5, 1200),
                  FlSpot(2, 2500),
                  FlSpot(2.5, 3500),
                  FlSpot(3, 250),
                ],
                isCurved: true,
                color: Colors.green,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: Colors.green,
                    strokeWidth: 0,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withValues(alpha: 0.3),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      'Fuel: ${spot.y.toInt()} L',
                      AppTextStyles.bodySmall.copyWith(
                        color: ColorConstants.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
