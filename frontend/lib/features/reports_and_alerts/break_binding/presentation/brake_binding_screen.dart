import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/device_id_mapper.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/presentation/widgets/pneumatic_gauge_v2.dart';
import '../data/models/coach_by_location_response.dart';
import '../data/models/pneumatic_status_model.dart';
import 'bloc/brake_binding_event.dart';
import 'bloc/brake_binding_state.dart';
import 'bloc/break_binding_bloc.dart';
import 'brake_binding_history_screen.dart';

class BrakeBindingScreen extends StatefulWidget {
  const BrakeBindingScreen({super.key});

  @override
  State<BrakeBindingScreen> createState() => _BrakeBindingScreenState();
}

class _BrakeBindingScreenState extends State<BrakeBindingScreen> {
  // Web-aligned colors
  static const Color colorBP = Color(0xFF2563EB);
  static const Color colorBC = Color(0xFFDC2626);
  static const Color colorFP = Color(0xFF059669);
  static const Color colorCR = Color(0xFFD97706);

  String _getActualId(String? deviceId) => DeviceIdMapper.resolve(deviceId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1A9DF8).withValues(alpha: 0.2),
                ),
              ),
              child: SvgPicture.asset(
                "assets/svgs/train_icon.svg",
                width: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1A9DF8),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "PNEUMATIC MONITOR",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111111),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "INDIAN RAILWAYS",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF575757),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<BrakeBindingBloc, BrakeBindingState>(
        builder: (context, state) {
          // Full-screen loading only on very first load (no coaches in cache yet)
          if (state.isLoadingCoaches && state.coachList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A9DF8)),
                  SizedBox(height: 16),
                  Text(
                    "Loading devices...",
                    style: TextStyle(color: Color(0xFF575757), fontSize: 13),
                  ),
                ],
              ),
            );
          }
          if (!state.isLoadingCoaches && state.coachList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No brake binding devices found for your location",
                    style: TextStyle(color: Color(0xFF575757), fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceDropdownRow(state),
                  const SizedBox(height: 20),
                  _buildInfoBadgeRow(state),
                  const SizedBox(height: 20),
                  _buildStatusCard(state),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildSectionTitle("PNEUMATIC GAUGES"),
                      const SizedBox(width: 6),
                      const Tooltip(
                        message:
                            "BP & CR: Standard 5.0 | FP: Standard 6.0 | BC: Standard 0.0 or 3.8",
                        child: Icon(
                          Icons.info_outline,
                          size: 10,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGaugesGrid(state),
                  const SizedBox(height: 24),
                  _buildPressureStatusEngine(state),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildSectionTitle("DIAGNOSTIC FLAGS"),
                      const SizedBox(width: 6),
                      const Tooltip(
                        message:
                            "System health monitoring for Binding, Leakage, CR stability, and DV response.",
                        child: Icon(
                          Icons.info_outline,
                          size: 10,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDiagnosticGrid(state),
                  const SizedBox(height: 24),
                  _buildTimeSeriesAnalysis(state),
                  const SizedBox(height: 24),
                  _buildRecentEvents(state),
                  const SizedBox(height: 24),
                  _buildActiveFaultsSection(state),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFaultsSection(BrakeBindingState state) {
    final allFaults = state.pneumaticStatus?.activeFaults ?? [];
    if (allFaults.isEmpty) return const SizedBox.shrink();

    final shownFaults = allFaults.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle("ACTIVE FAULTS"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => BlocProvider.value(
                      value: context.read<BrakeBindingBloc>(),
                      child: BrakeBindingHistoryScreen(
                        trainNo:
                            state.pneumaticStatus?.context?.trainNo
                                ?.toString() ??
                            "N/A",
                        deviceId: state.selectedDeviceId ?? "N/A",
                        initialEvents: state.pneumaticStatus?.recentEvents,
                        historyData: state.pneumaticStatus?.history?.data,
                        activeFaults: allFaults,
                        initialTabIndex: 1,
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                "View All",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A9DF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...shownFaults.map((f) => _buildFaultCard(f)),
      ],
    );
  }

  Widget _buildDeviceDropdownRow(BrakeBindingState state) {
    final coaches = state.coachList;
    final selected = state.selectedCoach;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SELECT MONITORING DEVICE", style: _labelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: state.isLoadingCoaches
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected?.deviceId?.toString(),
                    isExpanded: true,
                    hint: Text(
                      "Select Device",
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    ),
                    icon: const Icon(Icons.sensors, color: Color(0xFF1A9DF8), size: 20),
                    items: coaches.map((CoachByLocationItem coach) {
                      return DropdownMenuItem<String>(
                        value: coach.deviceId?.toString(),
                        child: Text(
                          coach.actualId?.toString() ?? coach.deviceId?.toString() ?? "Unknown",
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? deviceId) {
                      if (deviceId != null) {
                        final coach = coaches.firstWhere(
                          (c) => c.deviceId?.toString() == deviceId,
                          orElse: () => coaches.first,
                        );
                        context.read<BrakeBindingBloc>().add(SelectCoach(coach));
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPressureStatusEngine(BrakeBindingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsHeader(state),
          const SizedBox(height: 16),
          _buildMetricToggles(state),
          const SizedBox(height: 20),
          _buildMainChart(state),
          if (state.selectedDateRange != null) ...[
            const SizedBox(height: 12),
            _buildSelectedRangeInfo(state),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedRangeInfo(BrakeBindingState state) {
    final range = state.selectedDateRange!;
    final df = DateFormat('dd MMM');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 10, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            "Showing History: ${df.format(range.start)} - ${df.format(range.end)}",
            style: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.read<BrakeBindingBloc>().add(
              const ChangeTimeFilter("1m"),
            ),
            child: const Icon(Icons.cancel, size: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader(BrakeBindingState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pressure Status",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  "X-AXIS: TIME | Y-AXIS: PRESSURE (KG/CM²)",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF64748B),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildDateRangeButton(state),
                const SizedBox(width: 8),
                _buildTimeRangeDropdown(state),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeButton(BrakeBindingState state) {
    final bool isRangeActive = state.timeFilter == "RANGE";
    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          currentDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF1E293B),
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF0F172A),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          if (!mounted) return;
          context.read<BrakeBindingBloc>().add(ChangeDateRange(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isRangeActive
              ? const Color(0xFF1A9DF8)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.date_range,
          color: isRangeActive ? Colors.white : const Color(0xFF64748B),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildTimeRangeDropdown(BrakeBindingState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.timeFilter == "RANGE" ? null : state.timeFilter,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(Icons.history, color: Colors.white, size: 14),
          hint: Text(
            "RANGE",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
          items: ["1m", "15m", "30m", "24h", "48h"].map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val.toUpperCase(),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<BrakeBindingBloc>().add(ChangeTimeFilter(val));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMetricToggles(BrakeBindingState state) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          Tooltip(
            message:
                "Brake Pipe: Controls whole train braking. Pressure drop = Brakes Apply.",
            child: _metricCheckbox(
              "BP",
              state.showBP,
              colorBP,
              (v) => context.read<BrakeBindingBloc>().add(
                const TogglePressureFilter("BP"),
              ),
            ),
          ),
          Tooltip(
            message:
                "Brake Cylinder: Direct pressure on wheels. Higher BC = Stronger Braking.",
            child: _metricCheckbox(
              "BC",
              state.showBC,
              colorBC,
              (v) => context.read<BrakeBindingBloc>().add(
                const TogglePressureFilter("BC"),
              ),
            ),
          ),
          Tooltip(
            message:
                "Feed Pipe: Recharges brake system and auxiliary reservoirs.",
            child: _metricCheckbox(
              "FP",
              state.showFP,
              colorFP,
              (v) => context.read<BrakeBindingBloc>().add(
                const TogglePressureFilter("FP"),
              ),
            ),
          ),
          Tooltip(
            message:
                "Control Reservoir: Reference pressure for distributor valve regulation.",
            child: _metricCheckbox(
              "CR",
              state.showCR,
              colorCR,
              (v) => context.read<BrakeBindingBloc>().add(
                const TogglePressureFilter("CR"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCheckbox(
    String label,
    bool value,
    Color color,
    Function(bool?) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              color: const Color(0xFF334155),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.info_outline, size: 8, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildMainChart(BrakeBindingState state) {
    double maxX = 40;
    double interval = 10;
    String unit = "s";

    switch (state.timeFilter) {
      case "1m":
        maxX = 60;
        interval = 10;
        break;
      case "15m":
        maxX = 900;
        interval = 150;
        unit = "s";
        break;
      case "30m":
        maxX = 1800;
        interval = 300;
        unit = "s";
        break;
      case "24h":
        maxX = 86400;
        interval = 14400;
        unit = "h";
        break;
      case "48h":
        maxX = 172800;
        interval = 28800;
        unit = "h";
        break;
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 7,
          minX: 0,
          maxX: maxX,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  double displayVal = maxX - value;
                  String text = "${displayVal.toInt()}$unit";
                  if (unit == "m") text = "${(displayVal / 60).toInt()}m";
                  if (unit == "h") text = "${(displayVal / 3600).toInt()}h";

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 20,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            if (state.showBP)
              _lineData(
                state.readingsHistory
                    .map((e) => (e.bp ?? 0).toDouble())
                    .toList(),
                colorBP,
              ),
            if (state.showBC)
              _lineData(
                state.readingsHistory
                    .map((e) => (e.bc ?? 0).toDouble())
                    .toList(),
                colorBC,
              ),
            if (state.showFP)
              _lineData(
                state.readingsHistory
                    .map((e) => (e.fp ?? 0).toDouble())
                    .toList(),
                colorFP,
              ),
            if (state.showCR)
              _lineData(
                state.readingsHistory
                    .map((e) => (e.cr ?? 0).toDouble())
                    .toList(),
                colorCR,
              ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineData(List<double> values, Color color) {
    return LineChartBarData(
      spots: values
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildFaultCard(PneumaticFault fault) {
    String formattedTime = "--:--";
    try {
      if (fault.timestamp != null) {
        formattedTime = DateFormat(
          'dd MMM, HH:mm',
        ).format(DateTime.parse(fault.timestamp.toString()));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${fault.type ?? "FAULT"}",
                        style: GoogleFonts.poppins(
                          color: Colors.red[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (fault.severity ?? "ALARM").toString().toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // if (fault.description != null)
                //   Text(
                //     fault.description.toString(),
                //     style: GoogleFonts.poppins(
                //       color: Colors.red[700],
                //       fontSize: 11,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.router, size: 10, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          "Device: ${_getActualId(fault.deviceId)}",
                          style: GoogleFonts.poppins(
                            color: Colors.red[800],
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.poppins(
                        color: Colors.red[800],
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF575757).withValues(alpha: 0.6),
              fontSize: 8,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF111111),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadgeRow(BrakeBindingState state) {
    final ctx = state.pneumaticStatus?.context;
    final selectedCoach = state.selectedCoach;

    final String deviceDisplay = selectedCoach?.actualId?.toString()
        ?? selectedCoach?.deviceId?.toString()
        ?? state.selectedDeviceId
        ?? "N/A";

    final String coach = ctx?.coachNo?.toString()
        ?? selectedCoach?.coachNo?.toString()
        ?? "N/A";

    final String techId = ctx?.technicalId?.toString()
        ?? selectedCoach?.technicalId?.toString()
        ?? "N/A";

    final rawTrain = ctx?.trainNo ?? selectedCoach?.trainNo;
    final String train = (rawTrain == null || rawTrain.toString() == "NULL" || rawTrain.toString() == "null")
        ? "N/A" : rawTrain.toString();

    final rawLoc = ctx?.location ?? selectedCoach?.location;
    final String location = (rawLoc == null || rawLoc.toString() == "NULL" || rawLoc.toString() == "null")
        ? "N/A" : rawLoc.toString();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _infoBadge("Device ID", deviceDisplay),
          _infoBadge("Coach No", coach),
          _infoBadge("Tech ID", techId),
          _infoBadge("Train No", train),
          _infoBadge("Location", location),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BrakeBindingState state) {
    final status = state.status ?? "NORMAL";
    Color statusColor;
    IconData statusIcon;

    switch (status.toUpperCase()) {
      case "EMERGENCY":
      case "EMERGENCY BRAKE":
      case "BB SUSPECTED":
      case "SEVERE BB WARNING":
        statusColor = const Color(0xFFD32F2F);
        statusIcon = Icons.error;
        break;
      case "FULL SERVICE":
      case "LEAKAGE":
        statusColor = Colors.orange[800]!;
        statusIcon = Icons.warning;
        break;
      case "SERVICE":
        statusColor = Colors.orange[400]!;
        statusIcon = Icons.info_outline;
        break;
      case "BRAKE APPLIED PROGRESS":
      case "APPLIED PROGRESS":
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.trending_up;
        break;
      case "BRAKE RELEASED PROGRESS":
      case "RELEASED PROGRESS":
        statusColor = const Color(0xFF059669);
        statusIcon = Icons.trending_down;
        break;
      case "SYSTEM ISOLATED":
      case "ISOLATED":
        statusColor = Colors.purple[700]!;
        statusIcon = Icons.do_not_disturb_on;
        break;
      case "SENSOR OFFLINE":
        statusColor = Colors.blueGrey;
        statusIcon = Icons.cloud_off;
        break;
      default:
        statusColor = const Color(0xFF388E3C);
        statusIcon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Last Active: ${state.statusTime != null ? DateFormat('dd MMM, HH:mm:ss').format(state.statusTime!) : '-- ---, --:--:--'}",
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.statusDuration ?? "0 sec",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGaugesGrid(BrakeBindingState state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        Tooltip(
          message: "Brake Pipe (Standard: 5.0 kg/cm²)",
          child: PneumaticGauge(label: "BP", value: state.bpValue),
        ),
        Tooltip(
          message: "Feed Pipe (Standard: 6.0 kg/cm²)",
          child: PneumaticGauge(label: "FP", value: state.fpValue),
        ),
        Tooltip(
          message: "Brake Cylinder (Standard: 0.0 or 3.8 kg/cm²)",
          child: PneumaticGauge(
            label: "BC",
            value: state.bcValue,
            accentColor: const Color(0xFFFFC107),
          ),
        ),
        Tooltip(
          message: "Control Reservoir (Standard: 5.0 kg/cm²)",
          child: PneumaticGauge(
            label: "CR",
            value: state.crValue,
            accentColor: const Color(0xFFE91E63),
          ),
        ),
      ],
    );
  }

  static const List<String> _allFaultKeys = [
    "Brake Binding",
    "Severe Brake Binding",
    "CR Overcharging",
    "Emergency Brake",
    "DV BC Defect",
  ];

  static const Map<String, String> _faultTooltips = {
    "Brake Binding": "Potential wheel lock or brake friction during movement.",
    "Severe Brake Binding": "Severe friction or locking of the wheels.",
    "CR Overcharging": "Control Reservoir pressure exceeding safe limits.",
    "Emergency Brake": "Emergency braking event detected by the system.",
    "DV BC Defect": "Distributor Valve or Brake Cylinder response anomaly.",
  };

  Widget _buildDiagnosticGrid(BrakeBindingState state) {
    final flags = state.diagnosticFlags ?? {};
    final List<MapEntry<String, String>> entries = _allFaultKeys.map((key) {
      final value = flags[key] ?? "OK";
      return MapEntry(key, value);
    }).toList();

    return Column(
      children: [
        for (int i = 0; i < entries.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < entries.length ? 8 : 0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _diagnosticCard(entries[i].key, entries[i].value),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: i + 1 < entries.length 
                        ? _diagnosticCard(entries[i + 1].key, entries[i + 1].value) 
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _diagnosticCard(String label, String status) {
    final isCritical = status == "DETECTED" || status == "ALARM";
    final String message = _faultTooltips[label] ?? "System monitoring for $label.";

    return Tooltip(
      message: message,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isCritical ? const Color(0xFFFFEBEE) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCritical
                ? Colors.red.withValues(alpha: 0.35)
                : Colors.green.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCritical ? Icons.cancel : Icons.check_circle,
                  color: isCritical ? Colors.red : Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: isCritical ? Colors.red : Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF575757),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesAnalysis(BrakeBindingState state) {
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.train, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BRAKE CYLINDER (BC) PRESSURE OVER TIME",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "BC Pressure Range: 0 - 3 kg/cm²",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF334155)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "HISTORY VIEW: ${state.pneumaticStatus?.history?.data?.isNotEmpty == true ? DateFormat('HH:mm:ss').format(DateTime.parse(state.pneumaticStatus!.history!.data!.last.timestamp.toString())) : '00:00:00'} - ${state.pneumaticStatus?.history?.data?.isNotEmpty == true ? DateFormat('HH:mm:ss').format(DateTime.parse(state.pneumaticStatus!.history!.data!.first.timestamp.toString())) : '00:00:00'}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              _imageLegendItem("Brake Applied (BC Pressure)", const Color(0xFFDC2626)),
              _imageLegendItem("Brake Released (BC Pressure)", const Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 24),

          // Chart with Y-Axis label
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  "BC PRESSURE (kg/cm²)",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBrakingLineChart(state),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Center(
            child: Text(
              "TIME (hh:mm:ss)",
              style: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Timeline Section
          Text(
            "BRAKING TIMELINE",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineBar(state),
        ],
      ),
    );
  }

  Widget _imageLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBrakingLineChart(BrakeBindingState state) {
    final history = state.pneumaticStatus?.history?.data ?? [];
    // History is usually descending, we need ascending for chart
    final bcReadings = history.reversed.map((e) => double.tryParse(e.bc?.toString() ?? "0") ?? 0.0).toList();
    
    if (bcReadings.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No history logs available", style: TextStyle(color: Colors.white))),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 3.5,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 0.5,
            verticalInterval: (bcReadings.length / 5).clamp(1, 20),
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
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (bcReadings.length / 4).clamp(1, 50),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= history.length) return const SizedBox.shrink();
                  // reversed.toList()[index] corresponds to history[length - 1 - index]
                  final item = history[history.length - 1 - index];
                  try {
                    final time = DateFormat('HH:mm:ss').format(DateTime.parse(item.timestamp.toString()));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 8),
                      ),
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
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
          lineBarsData: _getBrakingLineBars(bcReadings),
        ),
      ),
    );
  }

  List<LineChartBarData> _getBrakingLineBars(List<double> values) {
    List<LineChartBarData> bars = [];
    if (values.length < 2) return bars;

    // We split the line into segments to have different colors
    for (int i = 0; i < values.length - 1; i++) {
      final double current = values[i];
      final double next = values[i + 1];
      
      Color color = const Color(0xFF94A3B8); // Idle
      if (next > current + 0.01) {
        color = const Color(0xFFDC2626); // Applied
      } else if (next < current - 0.01) {
        color = const Color(0xFF059669); // Released
      } else if (next > 0.1) {
        color = const Color(0xFFDC2626); // Maintain applied
      }

      bars.add(
        LineChartBarData(
          spots: [
            FlSpot(i.toDouble(), current),
            FlSpot((i + 1).toDouble(), next),
          ],
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: FlDotData(
            show: (i % 20 == 0), // Show dots occasionally for flair
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
      );
    }
    return bars;
  }

  Widget _buildTimelineBar(BrakeBindingState state) {
    final history = state.pneumaticStatus?.history?.data ?? [];
    final bcReadings = history.reversed.map((e) => double.tryParse(e.bc?.toString() ?? "0") ?? 0.0).toList();
    
    if (bcReadings.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: _getTimelineSegments(bcReadings, history.reversed.toList()),
      ),
    );
  }

  List<Widget> _getTimelineSegments(List<double> values, List<PneumaticHistoryData> rawData) {
    List<Widget> segments = [];
    if (values.isEmpty) return segments;

    int currentCount = 1;
    String currentState = _getBCState(values[0], values.length > 1 ? values[1] : values[0]);
    String startTime = rawData[0].timestamp.toString();

    for (int i = 1; i < values.length; i++) {
      String nextState = _getBCState(values[i-1], values[i]);
      if (nextState == currentState) {
        currentCount++;
      } else {
        segments.add(_segment(currentState, currentCount.toDouble(), startTime));
        currentState = nextState;
        currentCount = 1;
        startTime = rawData[i].timestamp.toString();
      }
    }
    segments.add(_segment(currentState, currentCount.toDouble(), startTime));
    return segments;
  }

  String _getBCState(double prev, double current) {
    if (current <= 0.05) return "IDLE";
    if (current > prev + 0.02) return "APPLIED";
    if (current < prev - 0.02) return "RELEASED";
    return "FULL";
  }

  Widget _segment(String state, double flex, String timestamp) {
    Color color = const Color(0xFF1E293B);
    String label = "IDLE / RUNNING";
    String formattedTime = "";
    try {
      formattedTime = DateFormat('HH:mm').format(DateTime.parse(timestamp));
    } catch (_) {}

    if (state == "APPLIED") { 
      color = const Color(0xFF7F1D1D); // Dark Red matching image
      label = "BRAKE APPLIED"; 
    }
    if (state == "FULL") { 
      color = const Color(0xFF92400E); // Dark Amber matching image
      label = "FULL BRAKE APPLIED"; 
    }
    if (state == "RELEASED") { 
      color = const Color(0xFF065F46); // Dark Green matching image
      label = "BRAKE RELEASED"; 
    }
    
    return Expanded(
      flex: flex.toInt(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: const Border(right: BorderSide(color: Color(0xFF0F172A), width: 1)),
        ),
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (flex > 12) ...[
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _trendMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEvents(BrakeBindingState state) {
    final historyData = state.pneumaticStatus?.history?.data ?? [];
    final bool hasData = historyData.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle("PNEUMATIC LOG HISTORY"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => BlocProvider.value(
                      value: context.read<BrakeBindingBloc>(),
                      child: BrakeBindingHistoryScreen(
                        trainNo:
                            (state.pneumaticStatus?.context?.trainNo != null &&
                                state.pneumaticStatus?.context?.trainNo !=
                                    "NULL")
                            ? state.pneumaticStatus!.context!.trainNo.toString()
                            : "N/A",
                        deviceId: state.selectedDeviceId?.toString() ?? "N/A",
                        historyData: historyData,
                        activeFaults: state.pneumaticStatus?.activeFaults,
                        initialTabIndex: 0,
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                "View All",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A9DF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!hasData)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No History Data",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF575757),
                  fontSize: 12,
                ),
              ),
            ),
          )
        else
          ...historyData.take(5).map((e) => _eventTileFromHistory(e)),
      ],
    );
  }

  Widget _eventTileFromHistory(PneumaticHistoryData item) {
    final status =
        item.brakeFault?.toString().toUpperCase() ??
        item.brakeStatus?.toString().toUpperCase() ??
        "NORMAL";
    Color color = _getEventColor(status);
    String formattedTime = "--:--";
    try {
      if (item.timestamp != null) {
        formattedTime = DateFormat(
          'HH:mm:ss',
        ).format(DateTime.parse(item.timestamp.toString()));
      }
    } catch (_) {}
    return _eventTileFrame(
      status: status,
      color: color,
      time: formattedTime,
      coach: item.coachNo?.toString() ?? "--",
      value: "${(item.bc ?? 0.0).toStringAsFixed(1)} BC",
      reason: item.brakeFault?.toString(),
    );
  }

  Widget _eventTileFrame({
    required String status,
    required Color color,
    required String time,
    required String coach,
    required String value,
    String? reason,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                coach,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF575757),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (reason != null && reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                reason,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getEventColor(String status) {
    if (status.contains("EMERGENCY") ||
        status.contains("FAULT") ||
        status.contains("ALARM")) {
      return const Color(0xFFD32F2F);
    }
    if (status.contains("SERVICE") || status.contains("SUSPECTED")) {
      return Colors.orange[600]!;
    }
    if (status.contains("APPLIED")) return const Color(0xFFDC2626);
    if (status.contains("RELEASED")) return const Color(0xFF059669);
    if (status.contains("ISOLATED")) return Colors.purple[700]!;
    return const Color(0xFF388E3C);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFF111111),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.poppins(
    color: Colors.grey[500],
    fontSize: 9,
    fontWeight: FontWeight.w600,
  );
}
