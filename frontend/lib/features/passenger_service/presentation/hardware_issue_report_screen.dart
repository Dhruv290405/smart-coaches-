import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/features/passenger_service/presentation/widgets/hardware_issue_report_generator.dart';
import 'package:smart_coach_new/features/passenger_service/presentation/hardware_issue_simulator_screen.dart';

class HardwareIssueReportScreen extends StatefulWidget {
  const HardwareIssueReportScreen({super.key});

  @override
  State<HardwareIssueReportScreen> createState() => _HardwareIssueReportScreenState();
}

class _HardwareIssueReportScreenState extends State<HardwareIssueReportScreen> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  Map<String, dynamic>? _report;
  bool _isLoading = false;

  String _selectedTrain = 'All Trains';
  String _selectedCoach = 'All Coach Types';
  String _selectedCompartment = 'All Compartments';
  String _selectedUniqueId = 'All Unique IDs';

  final List<Map<String, dynamic>> _devices = [];
  final List<String> _trainNumbers = ['All Trains'];
  final List<String> _coachTypes = ['All Coach Types'];
  final List<String> _compartments = ['All Compartments'];
  final List<String> _uniqueIds = ['All Unique IDs'];

  static const Color _cleaningColor = Color(0xFF1A9DF8);
  static const Color _linenColor = Color(0xFF8E2DE2);

  @override
  void initState() {
    super.initState();
    _loadMapping();
    _fetchReport();
  }

  Future<void> _loadMapping() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.devUrl}/hardware-issues/mapping'),
        headers: {
          'Content-Type': 'application/json',
          if (GetIt.I<Prefs>().token != null)
            'Authorization': 'Bearer ${GetIt.I<Prefs>().token}',
        },
      );
      if (response.statusCode != 200) return;
      final body = jsonDecode(response.body);
      final devices = List<Map<String, dynamic>>.from(body['data']?['devices'] ?? []);
      if (devices.isEmpty) return;
      _devices
        ..clear()
        ..addAll(devices);
      final trains = devices.map((d) => '${d['train_no'] ?? ''}').where((e) => e.isNotEmpty).toSet().toList()..sort();
      setState(() {
        _trainNumbers
          ..clear()
          ..add('All Trains')
          ..addAll(trains);
      });
      _rebuildCascade();
    } catch (_) {}
  }

  void _rebuildCascade() {
    final train = _selectedTrain == 'All Trains' ? null : _selectedTrain;
    final coach = _selectedCoach == 'All Coach Types' ? null : _selectedCoach;
    final comp = _selectedCompartment == 'All Compartments' ? null : _selectedCompartment;

    final trainDevices = train == null ? _devices : _devices.where((d) => '${d['train_no'] ?? ''}' == train).toList();
    final coachDevices = coach == null ? trainDevices : trainDevices.where((d) => '${d['coach_no'] ?? ''}' == coach).toList();
    final compDevices = comp == null ? coachDevices : coachDevices.where((d) => '${d['compartment_no'] ?? ''}' == comp).toList();

    setState(() {
      _coachTypes
        ..clear()
        ..add('All Coach Types')
        ..addAll(trainDevices.map((d) => '${d['coach_no'] ?? ''}').where((e) => e.isNotEmpty).toSet().toList()..sort());
      _compartments
        ..clear()
        ..add('All Compartments')
        ..addAll(coachDevices.map((d) => '${d['compartment_no'] ?? ''}').where((e) => e.isNotEmpty).toSet().toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b))));
      _uniqueIds
        ..clear()
        ..add('All Unique IDs')
        ..addAll(compDevices.map((d) => '${d['device_id'] ?? ''}').where((e) => e.isNotEmpty).toSet().toList()..sort());
    });
  }

  void _onTrainChanged(String v) {
    setState(() {
      _selectedTrain = v;
      _selectedCoach = 'All Coach Types';
      _selectedCompartment = 'All Compartments';
      _selectedUniqueId = 'All Unique IDs';
    });
    _rebuildCascade();
    _fetchReport();
  }

  void _onCoachChanged(String v) {
    setState(() {
      _selectedCoach = v;
      _selectedCompartment = 'All Compartments';
      _selectedUniqueId = 'All Unique IDs';
    });
    _rebuildCascade();
    _fetchReport();
  }

  void _onCompartmentChanged(String v) {
    setState(() {
      _selectedCompartment = v;
      _selectedUniqueId = 'All Unique IDs';
    });
    _rebuildCascade();
    _fetchReport();
  }

  void _onUniqueIdChanged(String v) {
    setState(() => _selectedUniqueId = v);
    _fetchReport();
  }

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _selectedTrain = 'All Trains';
      _selectedCoach = 'All Coach Types';
      _selectedCompartment = 'All Compartments';
      _selectedUniqueId = 'All Unique IDs';
    });
    _rebuildCascade();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    Loader.show();
    try {
      final params = <String, String>{};
      if (_dateFrom != null) params['dateFrom'] = _dateFrom!.toUtc().toIso8601String();
      if (_dateTo != null) params['dateTo'] = _dateTo!.toUtc().add(const Duration(days: 1)).toIso8601String();
      if (_selectedTrain != 'All Trains') params['trainNo'] = _selectedTrain;
      if (_selectedCoach != 'All Coach Types') params['coachNo'] = _selectedCoach;
      if (_selectedCompartment != 'All Compartments') params['compartmentNo'] = _selectedCompartment;
      if (_selectedUniqueId != 'All Unique IDs') {
        params['deviceId'] = _selectedUniqueId;
      }

      String url = '${ApiConstants.devUrl}/hardware-issues/report';
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        if (GetIt.I<Prefs>().token != null)
          'Authorization': 'Bearer ${GetIt.I<Prefs>().token}',
      });

      Loader.dismiss();
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() => _report = body['data']);
      } else {
        ToastMessageUtils.showMessage(context, 'Failed to load report');
      }
    } catch (e) {
      Loader.dismiss();
      setState(() => _isLoading = false);
      ToastMessageUtils.showMessage(context, 'Network error');
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_dateFrom ?? DateTime.now().subtract(const Duration(days: 7)))
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      _fetchReport();
    }
  }

  String _fmtResponse(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)} min';
    return '${(seconds / 3600).toStringAsFixed(2)} hr';
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Service Request Report', style: AppTextStyles.header1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_button, color: ColorConstants.primary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HardwareIssueSimulatorScreen()),
            ),
            tooltip: 'Device Simulator',
          ),
          if (_report != null && ((_report!['requests'] as List?)?.isNotEmpty ?? false))
            IconButton(
              icon: const Icon(Icons.file_download, color: ColorConstants.primary),
              onPressed: () {
                final requests = List<Map<String, dynamic>>.from(_report!['requests']);
                HardwareIssueReportGenerator.generate(context, requests, report: _report);
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorConstants.primary))
: _report == null
                  ? const Center(child: Text('No data'))
                  : RefreshIndicator(
                  onRefresh: _fetchReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(child: _buildFiltersSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildKpiSection(),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildSectionCard(child: _buildIssueByDaySection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildSectionCard(child: _buildTypePieSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildSectionCard(child: _buildPeakTimeSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildSectionCard(child: _buildResponseSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildIssuesTable(),
                        const SizedBox(height: AppDimensions.paddingLarge),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ----------------------------- FILTERS -----------------------------

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: AppTextStyles.header2.copyWith(color: ColorConstants.primary),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(children: [
                  const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Clear Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.primary,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _dateField(isFrom: true)),
            const SizedBox(width: 8),
            Expanded(child: _dateField(isFrom: false)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterDropdown(
                label: 'Train Number',
                value: _selectedTrain,
                items: _trainNumbers,
                onChanged: (v) => _onTrainChanged(v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Type',
                value: _selectedCoach,
                items: _coachTypes,
                onChanged: (v) => _onCoachChanged(v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterDropdown(
                label: 'Compartment',
                value: _selectedCompartment,
                items: _compartments,
                onChanged: (v) => _onCompartmentChanged(v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Unique ID',
                value: _selectedUniqueId,
                items: _uniqueIds,
                onChanged: (v) => _onUniqueIdChanged(v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateField({required bool isFrom}) {
    final isSet = isFrom ? _dateFrom != null : _dateTo != null;
    final value = isFrom
        ? (_dateFrom != null ? DateFormat('dd MMM yyyy').format(_dateFrom!) : 'From Date')
        : (_dateTo != null ? DateFormat('dd MMM yyyy').format(_dateTo!) : 'To Date');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isFrom ? 'From Date' : 'To Date', style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(isFrom: isFrom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: isSet ? ColorConstants.primary : ColorConstants.divider,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: ColorConstants.iconGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSet ? ColorConstants.textPrimary : ColorConstants.textSecondary,
                      fontWeight: isSet ? FontWeight.w500 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------- KPI CARDS -----------------------------

  Widget _buildKpiSection() {
    final r = _report!;
    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              'Total Requests',
              '${r['totalCount'] ?? 0}',
              ColorConstants.primary,
              Icons.assignment_outlined,
            ),
            const SizedBox(width: 12),
            _kpiCard(
              'Open',
              '${r['openCount'] ?? 0}',
              ColorConstants.statusWarning,
              Icons.error_outline,
            ),
            const SizedBox(width: 12),
            _kpiCard(
              'Resolved',
              '${r['closedCount'] ?? 0}',
              const Color(0xFF2E7D32),
              Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _kpiCard(
              'Cleaning',
              '${r['cleaningCount'] ?? 0}',
              _cleaningColor,
              Icons.cleaning_services_outlined,
            ),
            const SizedBox(width: 12),
            _kpiCard(
              'Linen',
              '${r['linenCount'] ?? 0}',
              _linenColor,
              Icons.bed_outlined,
            ),
            const SizedBox(width: 12),
            _kpiCard(
              'Avg Response',
              _fmtResponse(r['avgResponseSeconds'] as int?),
              const Color(0xFFE64A19),
              Icons.timer_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: ColorConstants.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- ISSUES PER DAY -----------------------------

  Widget _buildIssueByDaySection() {
    final byDay = List<Map<String, dynamic>>.from(_report!['byDay'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Issues Per Day', style: AppTextStyles.header2),
            Text(
              '${byDay.length} days',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (byDay.isEmpty)
          _emptyChart('No issues in the selected period')
        else
          SizedBox(
            height: 200,
            child: _buildDayBarChart(byDay),
          ),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  Widget _buildDayBarChart(List<Map<String, dynamic>> byDay) {
    final maxVal = byDay.fold<int>(0, (m, d) {
      final t = (d['total'] ?? 0) as int;
      return t > m ? t : m;
    });
    final maxY = ((maxVal == 0 ? 4 : maxVal) + 1).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _niceInterval(maxVal),
          getDrawingHorizontalLine: (value) => FlLine(
            color: ColorConstants.divider,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = byDay[group.x.toInt()];
              final label = rodIndex == 0 ? 'Cleaning' : 'Linen';
              final color = rodIndex == 0 ? _cleaningColor : _linenColor;
              return BarTooltipItem(
                '${DateFormat('dd MMM').format(DateTime.parse('${day['date']}'))}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                children: [
                  TextSpan(
                    text: '$label: ${rod.toY.toInt()}',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _niceInterval(maxVal),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= byDay.length) return const SizedBox.shrink();
                final raw = '${byDay[idx]['date'] ?? ''}';
                String label;
                try {
                  label = DateFormat('dd MMM').format(DateTime.parse(raw));
                } catch (_) {
                  label = raw;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: byDay.asMap().entries.map((e) {
          final idx = e.key;
          final d = e.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: ((d['cleaning'] ?? 0) as int).toDouble(),
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                gradient: LinearGradient(
                  colors: [_cleaningColor, _cleaningColor.withValues(alpha: 0.6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              BarChartRodData(
                toY: ((d['linen'] ?? 0) as int).toDouble(),
                width: 14,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                gradient: LinearGradient(
                  colors: [_linenColor, _linenColor.withValues(alpha: 0.6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _niceInterval(int maxVal) {
    if (maxVal <= 4) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    return 10;
  }

  // ----------------------------- TYPE DISTRIBUTION -----------------------------

  Widget _buildTypePieSection() {
    final r = _report!;
    final total = (r['totalCount'] ?? 0) as int;
    final cleaning = (r['cleaningCount'] ?? 0) as int;
    final linen = (r['linenCount'] ?? 0) as int;
    final cleaningPct = total == 0 ? 0.0 : cleaning / total;
    final linenPct = total == 0 ? 0.0 : linen / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Issue Type Distribution', style: AppTextStyles.header2),
            Text(
              '$total issues',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorConstants.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (total == 0)
          _emptyChart('No issues in the selected period')
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _typeGauge(
                      color: _cleaningColor,
                      icon: Icons.cleaning_services_outlined,
                      label: 'Cleaning',
                      value: cleaning,
                      percent: cleaningPct,
                      highlighted: cleaning >= linen,
                      onTap: () => _showTypeDetail('Cleaning', cleaning, cleaningPct),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeGauge(
                      color: _linenColor,
                      icon: Icons.bed_outlined,
                      label: 'Linen',
                      value: linen,
                      percent: linenPct,
                      highlighted: linen > cleaning,
                      onTap: () => _showTypeDetail('Linen', linen, linenPct),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildProportionBar(cleaningPct, linenPct),
            ],
          ),
      ],
    );
  }

  Widget _typeGauge({
    required Color color,
    required IconData icon,
    required String label,
    required int value,
    required double percent,
    required bool highlighted,
    required VoidCallback onTap,
  }) {
    final pctText = '${(percent * 100).round()}%';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: highlighted
                ? color.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.15),
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // background full ring
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                    ),
                  ),
                  // actual progress ring
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percent),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => CircularProgressIndicator(
                        value: v,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color.withValues(alpha: 0.12),
                        ),
                        color: color,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.14),
                        ),
                        child: Icon(icon, color: color, size: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$value',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pctText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProportionBar(double cleaningPct, double linenPct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share of total',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ColorConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: ColorConstants.divider.withValues(alpha: 0.4)),
                FractionallySizedBox(
                  widthFactor: cleaningPct,
                  child: Container(
                    color: _cleaningColor,
                    child: cleaningPct > 0.08
                        ? Center(
                            child: Text(
                              '${(cleaningPct * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _miniLegend(_cleaningColor, 'Cleaning ${(cleaningPct * 100).round()}%'),
            const SizedBox(width: 16),
            _miniLegend(_linenColor, 'Linen ${(linenPct * 100).round()}%'),
          ],
        ),
      ],
    );
  }

  Widget _miniLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  void _showTypeDetail(String label, int value, double percent) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _detailStat('Requests', '$value', ColorConstants.primary),
                  const SizedBox(width: 16),
                  _detailStat('Share', '${(percent * 100).round()}%', const Color(0xFFE64A19)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  // ----------------------------- PEAK CALL TIME -----------------------------

  Widget _buildPeakTimeSection() {
    final peak = List<Map<String, dynamic>>.from(_report!['peakHours'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Peak Call Time (per hour)', style: AppTextStyles.header2),
        const SizedBox(height: 18),
        if (peak.every((p) => (p['count'] ?? 0) == 0))
          _emptyChart('No requests recorded')
        else
          SizedBox(height: 200, child: _buildPeakLineChart(peak)),
      ],
    );
  }

  Widget _buildPeakLineChart(List<Map<String, dynamic>> peak) {
    final spots = List.generate(
      peak.length,
      (h) => FlSpot(h.toDouble(), ((peak[h]['count'] ?? 0) as num).toDouble()),
    );
    final maxVal = peak.fold<int>(0, (m, p) {
      final c = (p['count'] ?? 0) as int;
      return c > m ? c : m;
    });
    final maxY = (maxVal + 2).toDouble();
    int peakHour = 0;
    int peakCount = 0;
    for (var i = 0; i < peak.length; i++) {
      final c = (peak[i]['count'] ?? 0) as int;
      if (c > peakCount) {
        peakCount = c;
        peakHour = i;
      }
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _niceIntervalInterval(maxVal),
          getDrawingHorizontalLine: (value) => FlLine(
            color: ColorConstants.divider,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: ColorConstants.divider,
            strokeWidth: 1,
            dashArray: [2, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final h = spot.x.toInt();
                return LineTooltipItem(
                  '${_hourLabel(h)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${spot.y.toInt()} requests',
                      style: TextStyle(color: _cleaningColor, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 3,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _hourLabel(value.toInt()),
                  style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary),
                ),
              ),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: peakCount.toDouble(),
              color: const Color(0xFFE64A19).withValues(alpha: 0.6),
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE64A19),
                ),
                labelResolver: (_) => 'Peak ${_hourLabel(peakHour)} · $peakCount',
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            barWidth: 3,
            isStrokeCapRound: true,
            gradient: const LinearGradient(
              colors: [ColorConstants.primary, Color(0xFF64B5F6)],
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isPeak = spot.x.toInt() == peakHour;
                return FlDotCirclePainter(
                  radius: isPeak ? 5 : 3,
                  color: spot.y == 0
                      ? Colors.transparent
                      : (isPeak ? const Color(0xFFE64A19) : ColorConstants.primary),
                  strokeWidth: isPeak ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  ColorConstants.primary.withValues(alpha: 0.25),
                  ColorConstants.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _niceIntervalInterval(int maxVal) {
    if (maxVal <= 4) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    return 10;
  }

  String _hourLabel(int h) {
    if (h == 0) return '12 AM';
    if (h == 12) return '12 PM';
    return h < 12 ? '$h AM' : '${h == 24 ? 12 : h - 12} PM';
  }

  // ----------------------------- RESPONSE TIME -----------------------------

  Widget _buildResponseSection() {
    final r = _report!;
    final avg = r['avgResponseSeconds'] as int?;
    final open = (r['openCount'] ?? 0) as int;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE64A19).withValues(alpha: 0.2),
                const Color(0xFFE64A19).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.timer_outlined, color: Color(0xFFE64A19), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Average Response Time', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                avg == null ? 'No resolved issues yet' : _fmtResponse(avg),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ColorConstants.statusWarning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Text(
            '$open open',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorConstants.statusWarning,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------- ISSUES TABLE -----------------------------

  Widget _buildIssuesTable() {
    final requests = List<Map<String, dynamic>>.from(_report!['requests'] ?? []);
    if (requests.isEmpty) {
      return _buildSectionCard(
        child: _emptyChart('No issues found for the selected filters'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Issue Details', style: AppTextStyles.header2),
            Text(
              '${requests.length} shown',
              style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                ColorConstants.primary.withValues(alpha: 0.08),
              ),
              dataRowMinHeight: 44,
              dataRowMaxHeight: 56,
              headingTextStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
              columns: const [
                DataColumn(label: Text('Coach')),
                DataColumn(label: Text('Compartment')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Requested')),
                DataColumn(label: Text('Resolved')),
                DataColumn(label: Text('Response')),
              ],
              rows: requests.take(60).map((r) {
                final status = '${r['status'] ?? ''}';
                final isClosed = status == 'closed';
                final statusColor =
                    isClosed ? const Color(0xFF2E7D32) : ColorConstants.statusWarning;
                return DataRow(
                  cells: [
                    DataCell(Text('${r['coach_no'] ?? ''}', style: AppTextStyles.coachNumber)),
                    DataCell(Text('${r['compartment_no'] ?? ''}', style: AppTextStyles.bodyMedium)),
                    DataCell(Text(_formatType('${r['issue_type'] ?? ''}'), style: AppTextStyles.bodyMedium)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isClosed ? 'Resolved' : 'Open',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(_fmtDateTime('${r['opened_at'] ?? ''}'), style: AppTextStyles.bodySmall)),
                    DataCell(Text(_fmtDateTime('${r['closed_at'] ?? ''}'), style: AppTextStyles.bodySmall)),
                    DataCell(
                      Text(
                        _fmtResponse(r['response_seconds'] as int?),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primary,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(_cleaningColor, 'Cleaning'),
        const SizedBox(width: 24),
        _legendDot(_linenColor, 'Linen'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _emptyChart(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(message, style: AppTextStyles.bodyMedium),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'linen':
        return 'Linen';
      case 'cleaning':
        return 'Cleaning';
      default:
        return type;
    }
  }

  String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM, hh:mm:ss a').format(dt);
    } catch (_) {
      return raw.isNotEmpty ? raw : '-';
    }
  }
}