import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../../../core/widgets/update_info.dart';
import '../data/models/bc_pressure_model.dart';

class BCCoachDetail extends StatefulWidget {
  final BCPressureModel coach;
  const BCCoachDetail({super.key, required this.coach});

  @override
  State<BCCoachDetail> createState() => _BCCoachDetailState();
}

class _BCCoachDetailState extends State<BCCoachDetail> {
  String livePeriod = '1 hr';
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':     return Colors.green;
      case 'warning':  return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default:         return ColorConstants.iconGrey;
    }
  }

  List<BCPressureReading> get _historyReadings {
    final abnormal = widget.coach.readings.where((r) {
      final p = r.currentPressure;
      return p > 5.2 || p < 4.5;
    }).toList();
    if (abnormal.isEmpty && widget.coach.readings.isNotEmpty) {
      return [widget.coach.readings.first];
    }
    return abnormal;
  }

  List<FlSpot> get _liveSpots => List.generate(
    widget.coach.readings.length.clamp(0, 50),
    (i) => FlSpot(i.toDouble(), widget.coach.readings[i].currentPressure),
  );

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: ColorConstants.primary)),
        child: child!,
      ),
    );
    if (range != null) setState(() { customRange = range; selectedPeriod = 'Custom'; });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.coach.status);
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text('${widget.coach.coachNumber} - BC Pressure', style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrainInfoCard(),
              const SizedBox(height: 16),
              _buildPressureStatusBar(statusColor),
              const SizedBox(height: 16),
              _card(child: _buildBrakeTiming()),
              const SizedBox(height: 16),
              _card(child: _buildLivePressure()),
              const SizedBox(height: 12),
              const UpdateInfo(lastUpdated: '12 Mar, 2026 | 10:46 AM', refilledBy: 'Ramesh Kumar'),
              const SizedBox(height: 16),
              _card(child: _buildSensorInfo()),
              const SizedBox(height: 16),
              _card(child: _buildHistory()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
    decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
    child: child,
  );

  Widget _buildTrainInfoCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ColorConstants.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SvgPicture.asset(AppIcons.train, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.primary, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Text('Train ${widget.coach.trainNumber}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
      ]),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
        child: Text('${widget.coach.getFormattedLastUpdated()}', style: AppTextStyles.bodySmall),
      ),
    ]),
  );

  Widget _buildPressureStatusBar(Color statusColor) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: statusColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Pressure: ${widget.coach.pressure} Kg/cm²', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
        Text('• ${widget.coach.status}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor)),
      ],
    ),
  );

  Widget _buildBrakeTiming() {
    final isCritical = widget.coach.status == 'Critical';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brake Timing', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        InfoRow(label: 'Brake Applied Time', value: isCritical ? 'N/A' : (widget.coach.brakeApplied.isEmpty ? 'N/A' : widget.coach.brakeApplied)),
        InfoRow(label: 'Brake Release Time', value: isCritical ? 'N/A' : (widget.coach.brakeReleased.isEmpty ? 'Delayed' : widget.coach.brakeReleased)),
        const InfoRow(label: 'Brake Response Time', value: '9 sec', isLast: true),
        if (widget.coach.warningMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor(widget.coach.status).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: _statusColor(widget.coach.status), size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.coach.warningMessage!, style: AppTextStyles.bodySmall.copyWith(color: _statusColor(widget.coach.status), fontWeight: FontWeight.w500))),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _buildLivePressure() {
    final spots  = _liveSpots;
    final maxX   = spots.isNotEmpty ? spots.last.x : 4.0;
    final isCrit = widget.coach.status == 'Critical';
    final color  = isCrit ? Colors.red : Colors.green;
    final xLabels = widget.coach.readings.map((r) {
      final ts = r.timestamp;
      return ts.length >= 16 ? ts.substring(11, 16) : ts;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Pressure', style: AppTextStyles.header2),
            Flexible(
              child: PeriodFilter(
                selected: livePeriod,
                periods: const ['1 hr', '2 hr', '6 hr', '12 hr'],
                onChanged: (val) => setState(() => livePeriod = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (_) => FlLine(color: ColorConstants.divider, strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text('Kg/cm²', style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                axisNameSize: 20,
                sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 25, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: AppTextStyles.bodySmall)),
              ),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < xLabels.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(xLabels[idx], style: AppTextStyles.bodySmall.copyWith(fontSize: 8)));
                  return const SizedBox.shrink();
                },
              )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: maxX, minY: 0, maxY: 5.5,
            lineBarsData: [LineChartBarData(
              spots: spots, isCurved: true, color: color, barWidth: 2,
              dotData: FlDotData(show: true, getDotPainter: (spot, _, __, index) => FlDotCirclePainter(radius: spot.y < 1.5 ? 5 : 3, color: spot.y < 1.5 ? Colors.red : color, strokeWidth: 0)),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)])),
            )],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${s.y.toStringAsFixed(1)} Kg/cm²', AppTextStyles.bodySmall.copyWith(color: ColorConstants.textPrimary, fontWeight: FontWeight.w500))).toList(),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSensorInfo() {
    final id = int.tryParse(widget.coach.coachNumber.replaceAll('Coach ', '')) ?? 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Info', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        InfoRow(label: 'Sensor ID', value: 'BC-B7-${id.toString().padLeft(2, '0')}'),
        const InfoRow(label: 'Data Frequency', value: '0.5 sec'),
        const InfoRow(label: 'Last Received', value: '10:46:18 AM'),
        InfoRow(label: 'Location', value: widget.coach.coachNumber, isLast: true),
      ],
    );
  }

  Widget _buildHistory() {
    final entries = _historyReadings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.coach.coachNumber} (Pressure Readings)', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              Icon(Icons.history, size: 44, color: ColorConstants.textTertiary),
              const SizedBox(height: 8),
              Text('No readings available', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
            ]),
          ))
        else
          ...entries.map((e) => _buildReadingCard(e)),
      ],
    );
  }

  Widget _buildReadingCard(BCPressureReading e) {
    final pressure = e.currentPressure;
    final status = pressure > 5.2 || pressure < 4.5 ? 'Critical' : (pressure > 5.1 || pressure < 4.7 ? 'Warning' : 'Good');
    final statusColor = _statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider),
      ),
      child: Column(children: [
        _hRow('Pressure', '${e.currentPressure} Kg/cm²', color: statusColor),
        const Divider(color: ColorConstants.divider),
        _hRow('Status', status, color: statusColor),
        const Divider(color: ColorConstants.divider),
        _hRow('Brake Applied', e.brakeAppliedTime),
        const Divider(color: ColorConstants.divider),
        _hRow('Brake Released', e.brakeReleasedTime),
        const Divider(color: ColorConstants.divider),
        _hRow('Response Time', '${e.brakeResponseTime}s'),
        const Divider(color: ColorConstants.divider),
        _hRow('Timestamp', e.timestamp),
      ]),
    );
  }

  Widget _hRow(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: color ?? ColorConstants.textPrimary)),
      ],
    ),
  );

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}