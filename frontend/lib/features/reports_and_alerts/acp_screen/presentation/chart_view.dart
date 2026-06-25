import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/acp_model.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/repositories/chart_repository.dart';
import '../../../../core/widgets/chart_data_helper.dart';
import '../../../../core/widgets/period_filter.dart';

class AcpChartView extends StatefulWidget {
  final List<AcpCoachModel> coaches;
  const AcpChartView({super.key, required this.coaches});

  @override
  State<AcpChartView> createState() => _AcpChartViewState();
}

class _AcpChartViewState extends State<AcpChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.timeSeries;
  DateTimeRange? customRange;

  // Filter coaches based on the selected period
  List<AcpCoachModel> get filteredCoaches {
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
        final updateTime = DateTime.parse(c.updateTime);
        return updateTime.isAfter(startDate!);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int get onlineCount => filteredCoaches.where((c) => c.isOn).length;
  int get offlineCount => filteredCoaches.where((c) => !c.isOn).length;
  int get total => filteredCoaches.length;

  // Dynamic Time Series data based on period
  List<FlSpot> _spots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      final raw = await ChartRepository.getAcpData();
      _spots = ChartDataHelper.fromTimestampValues(raw);
    } catch (e) {
      // ignore errors for now, keep empty list
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<FlSpot> get timeSeriesData => _spots;


  // Keep existing custom range picker unchanged
  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 3, 12),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 12),
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
        customRange = range;
        selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCoaches = filteredCoaches;

    if (currentCoaches.isEmpty && widget.coaches.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
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
              const SizedBox(height: 24),
              Icon(Icons.history, size: 64, color: ColorConstants.textTertiary),
              const SizedBox(height: 16),
              Text('No activity recorded in this period', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
            ],
          ),
        ),
      );
    }

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
            Expanded(child: Text('Recently Triggered Timelines', style: AppTextStyles.header2)),
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
                  sections: [
                    PieChartSectionData(
                      value: (onlineCount == 0 && offlineCount == 0) ? 1 : onlineCount.toDouble(),
                      color: (onlineCount == 0 && offlineCount == 0) ? ColorConstants.divider : const Color(0xFF34C700),
                      radius: 60,
                      showTitle: false,
                    ),
                    if (onlineCount > 0 || offlineCount > 0)
                      PieChartSectionData(
                        value: offlineCount.toDouble(),
                        color: const Color(0xFFFF3B30),
                        radius: 60,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                  Text('Total', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFF34C700), 'Online ($onlineCount)'),
            const SizedBox(width: 20),
            _legend(const Color(0xFFFF3B30), 'Offline ($offlineCount)'),
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
              horizontalInterval: 1,
              verticalInterval: selectedPeriod == 'Live' ? 1 : (selectedPeriod == '7 Days' ? 1 : 5),
              getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
              getDrawingVerticalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: selectedPeriod == 'Live' ? 1 : (selectedPeriod == '7 Days' ? 1 : 5),
                  getTitlesWidget: (value, meta) {
                    if (selectedPeriod == 'Live') {
                      final hour = (DateTime.now().hour - (7 - value.toInt())) % 24;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Day ${value.toInt()}',
                          style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                        ),
                      );
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: ColorConstants.divider, width: 1),
            ),
            minX: 0,
            maxX: selectedPeriod == 'Live' ? 7 : (selectedPeriod == '7 Days' ? 7 : 30),
            minY: 0,
            maxY: (spots.isEmpty ? 5 : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1).toDouble().clamp(5, 100)),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [ColorConstants.primary, Color(0xFF64B5F6)],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: spots.length < 10),
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
    final onPct = total > 0 ? (onlineCount / total * 100).toStringAsFixed(1) : '0';
    final offPct = total > 0 ? (offlineCount / total * 100).toStringAsFixed(1) : '0';
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
              Text('Total Coaches', style: AppTextStyles.bodyMedium),
              Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow('Online', '$onlineCount  ($onPct%)', const Color(0xFF34C700)),
          const SizedBox(height: 8),
          _buildStatRow('Offline', '$offlineCount  ($offPct%)', const Color(0xFFFF3B30)),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? onlineCount / total : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFFF3B30),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34C700)),
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