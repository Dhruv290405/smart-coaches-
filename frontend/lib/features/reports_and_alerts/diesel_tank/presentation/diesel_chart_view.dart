import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/datasources/diesel_data_service.dart';
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
  final DieselDataService _dataService = DieselDataService(
    baseUrl: ApiConstants.devUrl,
  );
  String selectedPeriod = 'Live';
  DateTimeRange? customRange;
  List<DieselHistoryPoint> _history = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  DateTimeRange _rangeForPeriod() {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'Live':
        return DateTimeRange(start: now.subtract(const Duration(hours: 1)), end: now);
      case '7 Days':
        return DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
      case '30 Days':
        return DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
      case 'Custom':
        return customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            );
      default:
        return DateTimeRange(start: now.subtract(const Duration(hours: 1)), end: now);
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      final range = _rangeForPeriod();
      final history = await _dataService.fetchDieselHistory(
        widget.tank.sensorId,
        fromDate: range.start,
        toDate: range.end,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _history = [];
        _isLoadingHistory = false;
        _historyError = 'Unable to load diesel history.';
      });
    }
  }

  Future<void> _onPeriodChanged(String value) async {
    if (value == 'Custom') {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
        initialDateRange: customRange,
      );
      if (range == null || !mounted) return;
      setState(() {
        customRange = range;
        selectedPeriod = value;
      });
    } else {
      setState(() => selectedPeriod = value);
    }
    await _loadHistory();
  }

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
          onChanged: _onPeriodChanged,
        ),
        if (selectedPeriod == 'Custom' && customRange != null) ...[
          const SizedBox(height: 4),
          Text(
            '${DateFormat('dd MMM yyyy').format(customRange!.start)} - '
            '${DateFormat('dd MMM yyyy').format(customRange!.end)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: ColorConstants.textSecondary,
            ),
          ),
        ],
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
    if (_isLoadingHistory) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: const CircularProgressIndicator(strokeWidth: 3),
      );
    }
    if (_historyError != null || _history.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Text(
          _historyError ?? 'No history available for this period',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: ColorConstants.textSecondary,
          ),
        ),
      );
    }

    final spots = List<FlSpot>.generate(
      _history.length,
      (i) => FlSpot(i.toDouble(), _history[i].percentage),
    );
    final maxX = _history.length > 1 ? (_history.length - 1).toDouble() : 1.0;
    final interval = _history.length <= 1
        ? 1.0
        : (_history.length / 4).ceilToDouble();
    final labelFormat = DateFormat('dd MMM\nHH:mm');

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
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: ColorConstants.divider,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: interval,
                  reservedSize: 34,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if (index < 0 || index >= _history.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labelFormat.format(_history[index].timestamp),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 8),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: maxX,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: _history.length > 2,
                color: Colors.green,
                barWidth: 2,
                dotData: FlDotData(show: _history.length <= 20),
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
                    final index = spot.x
                        .round()
                        .clamp(0, _history.length - 1)
                        .toInt();
                    return LineTooltipItem(
                      '${DateFormat('dd MMM HH:mm').format(_history[index].timestamp)}\n'
                      '${spot.y.toStringAsFixed(1)}%',
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
