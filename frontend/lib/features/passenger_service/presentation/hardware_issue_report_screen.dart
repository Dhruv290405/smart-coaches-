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
  bool _filtersExpanded = true;
  bool _filtersInitialized = false;

  // Chart selection state (persistent until another point is tapped).
  int _touchedPieIndex = -1;
  int? _selectedPeakHour;
  int? _selectedRespHour;
  int? _selectedDayIndex;
  int? _selectedActivityIndex;
  String _selectedTrain = 'All Trains';
  String _selectedCoach = 'All Coach Types';
  String _selectedCompartment = 'All Compartments';
  String _selectedUniqueId = 'All Unique IDs';
  String _selectedType = 'All Types';
  String _selectedRange = 'All';

  static const List<String> _typeOptions = ['All Types', 'Linen', 'Cleaning'];
  static const List<String> _rangeOptions = ['All', 'Today', '7 Days', '30 Days', 'Custom'];

  final List<Map<String, dynamic>> _devices = [];
  final List<String> _trainNumbers = ['All Trains'];
  final List<String> _coachTypes = ['All Coach Types'];
  final List<String> _compartments = ['All Compartments'];
  final List<String> _uniqueIds = ['All Unique IDs'];

  // Enterprise palette: requested = blue, responded = green, pending = orange.
  static const Color _cleaningColor = Color(0xFF00897B);
  static const Color _linenColor = Color(0xFF5E35B1);
  static const Color _requestedColor = Color(0xFF1565C0);
  static const Color _resolvedColor = Color(0xFF2E7D32);
  static const Color _pendingColor = Color(0xFFE65100);
  static const Color _responseColor = Color(0xFFE64A19);

  @override
  void initState() {
    super.initState();
    _loadMapping();
    _fetchReport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_filtersInitialized) {
      _filtersInitialized = true;
      // Expanded on larger screens, collapsed on small mobile widths.
      _filtersExpanded = MediaQuery.of(context).size.width >= 600;
    }
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

  void _onTypeChanged(String v) {
    setState(() => _selectedType = v);
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
      _selectedType = 'All Types';
      _selectedRange = 'All';
      _selectedPeakHour = null;
      _selectedActivityIndex = null;
      _selectedRespHour = null;
      _selectedDayIndex = null;
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
      if (_selectedUniqueId != 'All Unique IDs') params['deviceId'] = _selectedUniqueId;
      if (_selectedType != 'All Types') params['issueType'] = _selectedType.toLowerCase();

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
        setState(() {
          _report = body['data'];
          _touchedPieIndex = -1;
          _selectedPeakHour = null;
          _selectedActivityIndex = null;
          _selectedRespHour = null;
          _selectedDayIndex = null;
        });
      } else {
        ToastMessageUtils.showMessage(context, 'Failed to load report');
      }
    } catch (e) {
      Loader.dismiss();
      setState(() => _isLoading = false);
      ToastMessageUtils.showMessage(context, 'Network error');
    }
  }

  Future<DateTime?> _showPicker(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await _showPicker(
      isFrom
          ? (_dateFrom ?? DateTime.now().subtract(const Duration(days: 7)))
          : (_dateTo ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
        _selectedRange = 'Custom';
      });
      _fetchReport();
    }
  }

  Future<void> _pickCustomRange() async {
    final from = await _showPicker(_dateFrom ?? DateTime.now().subtract(const Duration(days: 6)));
    if (from == null) return;
    final to = await _showPicker(_dateTo ?? DateTime.now());
    setState(() {
      _dateFrom = from;
      _dateTo = to ?? DateTime.now();
      _selectedRange = 'Custom';
    });
    _fetchReport();
  }

  void _applyRange(String range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case 'All':
        setState(() {
          _selectedRange = 'All';
          _dateFrom = null;
          _dateTo = null;
        });
        break;
      case 'Today':
        setState(() {
          _selectedRange = range;
          _dateTo = today;
          _dateFrom = today;
        });
        break;
      case '7 Days':
        setState(() {
          _selectedRange = range;
          _dateTo = today;
          _dateFrom = today.subtract(const Duration(days: 6));
        });
        break;
      case '30 Days':
        setState(() {
          _selectedRange = range;
          _dateTo = today;
          _dateFrom = today.subtract(const Duration(days: 29));
        });
        break;
      case 'Custom':
        _pickCustomRange();
        return;
    }
    _fetchReport();
  }

  // ----------------------------- FORMATTERS -----------------------------

  String _fmtResponse(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)} min';
    return '${(seconds / 3600).toStringAsFixed(2)} hr';
  }

  String _hourLabel(int h) {
    if (h == 0) return '12 AM';
    if (h == 12) return '12 PM';
    return h < 12 ? '$h AM' : '${h - 12} PM';
  }

  double _niceInterval(int maxVal) {
    if (maxVal <= 4) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    return 50;
  }

  String _formatType(String type) {
    switch (type) {
      case 'linen':
        return 'Linen';
      case 'cleaning':
        return 'Cleaning';
      default:
        return type.isEmpty ? '-' : type;
    }
  }

  String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
    } catch (_) {
      return raw.isNotEmpty ? raw : '-';
    }
  }

  String _fmtDayLabel(String raw) {
    try {
      return DateFormat('dd MMM').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ----------------------------- WIDGET HELPERS -----------------------------

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.header3),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 10.5, color: ColorConstants.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 34, color: ColorConstants.iconGrey.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
      ],
    );
  }

  Widget _infoBanner({required IconData icon, required Color color, required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- BUILD -----------------------------

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
              tooltip: 'Export report',
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading && _report == null
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
                        _sectionCard(child: _buildFiltersSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildKpiSection(),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildPeakTimeSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildActivityTimelineSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildTypeComparisonSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildIssueByDaySection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildTypePieSection()),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _sectionCard(child: _buildResponseTimeSection()),
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
          children: [
            Expanded(
              child: InkWell(
                onTap: _toggleFilters,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 18, color: ColorConstants.primary),
                      const SizedBox(width: 8),
                      Text(
                        'FILTERS',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: ColorConstants.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(children: [
                  const Icon(Icons.restart_alt, size: 15, color: ColorConstants.primary),
                  const SizedBox(width: 4),
                  Text('Reset', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: _filtersExpanded ? 'Collapse filters' : 'Expand filters',
              child: Semantics(
                button: true,
                label: _filtersExpanded ? 'Collapse filters' : 'Expand filters',
                child: InkWell(
                  onTap: _toggleFilters,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Container(
                    width: 44,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorConstants.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: ColorConstants.primary.withValues(alpha: 0.25)),
                    ),
                    child: AnimatedRotation(
                      turns: _filtersExpanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.keyboard_arrow_up, color: ColorConstants.primary, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_filtersExpanded) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: ColorConstants.divider),
            ),
            child: Text(
              _filterSummary(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11.5, color: ColorConstants.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _filtersExpanded ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: _filtersExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _filterGrid(),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }

  void _toggleFilters() => setState(() => _filtersExpanded = !_filtersExpanded);

  Widget _filterGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 420;
        final children = <Widget>[
          FilterDropdown(
            label: 'Train',
            value: _selectedTrain,
            items: _trainNumbers,
            onChanged: (v) => _onTrainChanged(v!),
          ),
          FilterDropdown(
            label: 'Coach',
            value: _selectedCoach,
            items: _coachTypes,
            onChanged: (v) => _onCoachChanged(v!),
          ),
          FilterDropdown(
            label: 'Compartment',
            value: _selectedCompartment,
            items: _compartments,
            onChanged: (v) => _onCompartmentChanged(v!),
          ),
          FilterDropdown(
            label: 'Unique ID',
            value: _selectedUniqueId,
            items: _uniqueIds,
            onChanged: (v) => _onUniqueIdChanged(v!),
          ),
          FilterDropdown(
            label: 'Service Type',
            value: _selectedType,
            items: _typeOptions,
            onChanged: (v) => _onTypeChanged(v!),
          ),
          Row(
            children: [
              Expanded(child: _dateField(isFrom: true)),
              const SizedBox(width: 8),
              Expanded(child: _dateField(isFrom: false)),
            ],
          ),
        ];

        if (!twoCol) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i != 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          if (i != 0) rows.add(const SizedBox(height: 12));
          if (i + 1 < children.length) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 12),
                Expanded(child: children[i + 1]),
              ],
            ));
          } else {
            rows.add(children[i]);
          }
        }
        return Column(children: rows);
      },
    );
  }

  String _filterSummary() {
    final parts = <String>[];
    parts.add(_selectedTrain == 'All Trains' ? 'All Trains' : _selectedTrain);
    if (_selectedCoach != 'All Coach Types') parts.add(_selectedCoach);
    parts.add(_selectedCompartment == 'All Compartments' ? 'All Compartments' : 'Compartment $_selectedCompartment');
    if (_selectedUniqueId != 'All Unique IDs') parts.add(_selectedUniqueId);
    parts.add(_selectedType == 'All Types' ? 'All Types' : _selectedType);
    parts.add(_rangeLabel());
    return parts.join('  •  ');
  }

  String _rangeLabel() {
    if (_dateFrom == null && _dateTo == null) return 'All Dates';
    if (_dateFrom != null && _dateTo != null) {
      if (DateFormat('yyyy-MM-dd').format(_dateFrom!) == DateFormat('yyyy-MM-dd').format(_dateTo!)) {
        return DateFormat('dd MMM yyyy').format(_dateFrom!);
      }
      return '${DateFormat('dd MMM').format(_dateFrom!)} – ${DateFormat('dd MMM').format(_dateTo!)}';
    }
    return 'Custom';
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
              border: Border.all(color: isSet ? ColorConstants.primary : ColorConstants.divider, width: 1),
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
    final total = (r['totalCount'] ?? 0) as int;
    final responded = (r['closedCount'] ?? 0) as int;
    final pending = (r['openCount'] ?? 0) as int;
    final avg = r['avgResponseSeconds'] as int?;
    final peak = _peakInfo();

    final respondedPct = total > 0 ? (responded / total * 100).round() : 0;
    final pendingPct = total > 0 ? (pending / total * 100).round() : 0;

    final cards = <Widget>[
      _kpiCard('TOTAL REQUESTS', '$total', subtitle: _rangeLabel(), color: ColorConstants.primary, icon: Icons.assignment_outlined),
      _kpiCard('RESPONDED', '$responded', subtitle: '$respondedPct% response rate', color: _resolvedColor, icon: Icons.check_circle_outline),
      _kpiCard('PENDING', '$pending', subtitle: '$pendingPct% awaiting', color: _pendingColor, icon: Icons.hourglass_bottom_outlined),
      _kpiCard('AVG. RESPONSE TIME', _fmtResponse(avg), subtitle: 'across responded', color: _responseColor, icon: Icons.timer_outlined),
      _kpiCard('PEAK HOUR', peak == null ? '-' : _hourLabel(peak.hour), subtitle: peak == null ? 'no requests' : '${peak.count} requests', color: _linenColor, icon: Icons.local_fire_department_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final perRow = w >= 900 ? 5 : (w >= 600 ? 3 : 2);
        final spacing = 10.0;
        final cardWidth = (w - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, {required String subtitle, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: ColorConstants.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 9.5, color: ColorConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  // ----------------------------- PEAK REQUEST TIME -----------------------------

  _PeakInfo? _peakInfo() {
    final peak = List<Map<String, dynamic>>.from(_report!['peakHours'] ?? []);
    var best = -1;
    var bestCount = 0;
    for (var h = 0; h < peak.length; h++) {
      final c = (peak[h]['count'] ?? 0) as int;
      if (c > bestCount) {
        bestCount = c;
        best = h;
      }
    }
    if (best < 0 || bestCount == 0) return null;
    return _PeakInfo(best, bestCount);
  }

  Widget _buildPeakTimeSection() {
    final peak = List<Map<String, dynamic>>.from(_report!['peakHours'] ?? []);
    final requested = List.generate(24, (h) => ((peak[h]['count'] ?? 0) as num).toDouble());
    final hasData = requested.any((v) => v > 0);
    final peakInfo = _peakInfo();
    final activeHour = _selectedPeakHour ?? peakInfo?.hour ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Peak Request Time', subtitle: 'Hour of the day with the highest number of requests'),
        const SizedBox(height: 14),
        if (!hasData)
          _emptyState('No service requests for the selected period.')
        else ...[
          _infoBanner(
            icon: Icons.local_fire_department,
            color: _responseColor,
            title: _selectedPeakHour == null ? 'Peak' : 'Selected',
            value: '${_hourLabel(activeHour)} · ${requested[activeHour].toInt()} requests',
          ),
          const SizedBox(height: 16),
          SizedBox(height: 190, child: _peakLineChart(requested, activeHour)),
          const SizedBox(height: 6),
          Text(
            'Tap any point to inspect that hour',
            style: GoogleFonts.poppins(fontSize: 9.5, color: ColorConstants.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _peakLineChart(List<double> requested, int activeHour) {
    final maxVal = requested.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = (maxVal == 0 ? 1.0 : maxVal) * 1.25;
    final interval = _niceInterval(maxVal.toInt());
    final spots = List.generate(24, (h) => FlSpot(h.toDouble(), requested[h]));

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: activeHour.toDouble(),
              color: _responseColor.withValues(alpha: 0.35),
              strokeWidth: 1.5,
              dashArray: [4, 4],
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touched) => touched.map((s) {
              final h = s.x.toInt();
              return LineTooltipItem(
                '${_hourLabel(h)}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                children: [
                  TextSpan(
                    text: '${requested[h].toInt()} requests',
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
          touchCallback: (event, response) {
            final spots = response?.lineBarSpots;
            if (event is FlTapUpEvent && spots != null && spots.isNotEmpty) {
              setState(() => _selectedPeakHour = spots.first.x.toInt());
            }
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 3,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_hourLabel(value.toInt()), style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textSecondary)),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            barWidth: 2.5,
            isStrokeCapRound: true,
            color: _requestedColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isActive = index == activeHour;
                return FlDotCirclePainter(
                  radius: isActive ? 5 : 2.4,
                  color: isActive ? _responseColor : _requestedColor,
                  strokeWidth: isActive ? 2 : 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [_requestedColor.withValues(alpha: 0.28), _requestedColor.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- REQUEST / RESPONSE TIMELINE -----------------------------

  Widget _buildActivityTimelineSection() {
    final rows = List<Map<String, dynamic>>.from(_report!['requests'] ?? []);
    final events = <_ActivityEvent>[];
    for (final r in rows) {
      final reqAt = _tryParse(r['opened_at']);
      if (reqAt == null) continue;
      events.add(_ActivityEvent(r: r, requestAt: reqAt, responseAt: _tryParse(r['closed_at'])));
    }
    events.sort((a, b) => a.requestAt.compareTo(b.requestAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Request / Response Timeline',
            subtitle: 'Each event plotted over time — line length shows how long the response took'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _legendDot(_requestedColor, 'Request'),
            _legendDot(_resolvedColor, 'Response'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 18, height: 2, color: _responseColor),
                const SizedBox(width: 5),
                Text('Time taken',
                    style: GoogleFonts.poppins(
                        fontSize: 10.5, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          _emptyState('No service requests for the selected period.')
        else ...[
          _activityBanner(events),
          const SizedBox(height: 14),
          SizedBox(height: 220, child: _activityChart(events)),
          const SizedBox(height: 6),
          Text('Tap any point to see that request / response detail',
              style: GoogleFonts.poppins(fontSize: 9.5, color: ColorConstants.textTertiary)),
        ],
      ],
    );
  }

  Widget _activityBanner(List<_ActivityEvent> events) {
    final sel = _selectedActivityIndex;
    if (sel == null || sel < 0 || sel >= events.length) {
      final pending = events.where((e) => e.responseAt == null).length;
      return _infoBanner(
        icon: Icons.timeline,
        color: _requestedColor,
        title: 'All events',
        value: 'Req ${events.length} · Resp ${events.length - pending} · Pending $pending',
      );
    }
    final e = events[sel];
    final r = e.r;
    final dur = e.responseAt == null
        ? 'Pending — no response yet'
        : _fmtResponse(e.responseAt!.difference(e.requestAt).inSeconds);
    return _infoBanner(
      icon: e.responseAt == null ? Icons.hourglass_empty : Icons.check_circle_outline,
      color: e.responseAt == null ? _pendingColor : _resolvedColor,
      title: '${r['coach_no'] ?? ''} / ${_formatType('${r['issue_type'] ?? ''}')} · ${_fmtDateTime('${r['opened_at'] ?? ''}')}',
      value: 'Time: $dur',
    );
  }

  Widget _activityChart(List<_ActivityEvent> events) {
    final times = <DateTime>[];
    for (final e in events) {
      times.add(e.requestAt);
      if (e.responseAt != null) times.add(e.responseAt!);
    }
    times.sort();
    final minTime = times.first;
    final spanMin = times.last.difference(minTime).inSeconds / 60.0;
    double xOf(DateTime t) => t.difference(minTime).inSeconds / 60.0;
    final maxX = (spanMin <= 0 ? 1.0 : spanMin) * 1.02;
    final labelInterval = _niceTimeInterval(spanMin);
    final selected = _selectedActivityIndex;

    final bars = <LineChartBarData>[];
    for (var i = 0; i < events.length; i++) {
      final e = events[i];
      final isSel = i == selected;
      final spots = <FlSpot>[FlSpot(xOf(e.requestAt), 1)];
      if (e.responseAt != null) spots.add(FlSpot(xOf(e.responseAt!), 0));
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: isSel ? _responseColor : _responseColor.withValues(alpha: 0.4),
          barWidth: isSel ? 2.4 : 1.4,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final isRequest = index == 0;
              return FlDotCirclePainter(
                radius: isSel ? 5 : 3.4,
                color: isRequest ? _requestedColor : _resolvedColor,
                strokeWidth: isSel ? 1.6 : 0,
                strokeColor: isSel ? Colors.white : Colors.transparent,
              );
            },
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: -0.5,
        maxY: 1.5,
        clipData: const FlClipData.all(),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: 0, color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4]),
            HorizontalLine(y: 1, color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4]),
          ],
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 0.5,
              getTitlesWidget: (value, meta) {
                if ((value - 1).abs() < 0.01) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('Request',
                        style: GoogleFonts.poppins(
                            fontSize: 9.5, fontWeight: FontWeight.w700, color: _requestedColor)),
                  );
                }
                if (value.abs() < 0.01) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('Response',
                        style: GoogleFonts.poppins(
                            fontSize: 9.5, fontWeight: FontWeight.w700, color: _resolvedColor)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: labelInterval,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_activityTimeLabel(minTime, value, spanMin),
                    style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textSecondary)),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (spots) => spots.map((s) {
              final e = events[s.barIndex];
              final r = e.r;
              final dur = e.responseAt == null
                  ? 'Pending'
                  : _fmtResponse(e.responseAt!.difference(e.requestAt).inSeconds);
              return LineTooltipItem(
                '${r['coach_no'] ?? ''} / Comp ${r['compartment_no'] ?? ''}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                children: [
                  TextSpan(
                      text: '${_formatType('${r['issue_type'] ?? ''}')}\n',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: 'Req   ${DateFormat('HH:mm:ss').format(e.requestAt)}\n',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: e.responseAt == null
                          ? 'Resp  —\n'
                          : 'Resp  ${DateFormat('HH:mm:ss').format(e.responseAt!)}\n',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: 'Time  $dur',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              );
            }).toList(),
          ),
          touchCallback: (event, response) {
            final spots = response?.lineBarSpots;
            if (event is FlTapUpEvent && spots != null && spots.isNotEmpty) {
              setState(() => _selectedActivityIndex = spots.first.barIndex);
            }
          },
        ),
        lineBarsData: bars,
      ),
    );
  }

  DateTime? _tryParse(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  double _niceTimeInterval(double spanMinutes) {
    if (spanMinutes <= 0) return 1;
    final raw = spanMinutes / 6;
    const steps = [1, 2, 5, 10, 15, 30, 60, 120, 180, 360, 720, 1440, 2880, 4320, 10080];
    for (final s in steps) {
      if (raw <= s) return s.toDouble();
    }
    return (raw / 10080).ceil() * 10080.0;
  }

  String _activityTimeLabel(DateTime minTime, double x, double spanMin) {
    final dt = minTime.add(Duration(minutes: x.round()));
    if (spanMin > 2 * 24 * 60) return DateFormat('dd MMM').format(dt);
    if (spanMin > 24 * 60) return DateFormat('dd MMM HH:mm').format(dt);
    return DateFormat('HH:mm').format(dt);
  }

  // ----------------------------- LINEN VS CLEANING -----------------------------

  Widget _buildTypeComparisonSection() {
    final r = _report!;
    final stats = Map<String, dynamic>.from(r['typeStats'] ?? {});
    final linen = Map<String, dynamic>.from(stats['linen'] ?? {});
    final cleaning = Map<String, dynamic>.from(stats['cleaning'] ?? {});
    final total = (r['totalCount'] ?? 0) as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Linen vs Cleaning', subtitle: 'Tap a category to filter the whole report'),
        const SizedBox(height: 14),
        if (total == 0)
          _emptyState('No service requests for the selected period.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 460;
              final linenCard = _typeStatCard('Linen', _linenColor, Icons.bed_outlined, linen, 'Linen');
              final cleanCard = _typeStatCard('Cleaning', _cleaningColor, Icons.cleaning_services_outlined, cleaning, 'Cleaning');
              if (!wide) {
                return Column(children: [linenCard, const SizedBox(height: 12), cleanCard]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: linenCard), const SizedBox(width: 12), Expanded(child: cleanCard)],
              );
            },
          ),
      ],
    );
  }

  Widget _typeStatCard(String title, Color color, IconData icon, Map<String, dynamic> s, String typeValue) {
    final requested = (s['requested'] ?? 0) as int;
    final responded = (s['responded'] ?? 0) as int;
    final pending = (s['pending'] ?? 0) as int;
    final rate = (s['responseRate'] ?? 0) as int;
    final isSelected = _selectedType == typeValue;

    return InkWell(
      onTap: () => _onTypeChanged(isSelected ? 'All Types' : typeValue),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: isSelected ? color : ColorConstants.divider, width: isSelected ? 1.4 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 15, color: color),
                ),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: color)
                else
                  Icon(Icons.filter_alt_outlined, size: 14, color: ColorConstants.iconGrey),
              ],
            ),
            const SizedBox(height: 12),
            _statRow('Requested', '$requested', _requestedColor),
            _statRow('Responded', '$responded', _resolvedColor),
            _statRow('Pending', '$pending', _pendingColor),
            _statRow('Response Rate', '$rate%', color),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate / 100,
                minHeight: 6,
                backgroundColor: ColorConstants.divider.withValues(alpha: 0.6),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11.5, color: ColorConstants.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ----------------------------- ISSUES PER DAY -----------------------------

  Widget _buildIssueByDaySection() {
    final byDay = List<Map<String, dynamic>>.from(_report!['byDay'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Issues Per Day', subtitle: 'Passenger service requests received each day'),
        const SizedBox(height: 12),
        _rangeChips(),
        const SizedBox(height: 14),
        if (byDay.isEmpty)
          _emptyState('No service requests for the selected period.')
        else ...[
          if (_selectedDayIndex != null && _selectedDayIndex! < byDay.length) ...[
            _dayInfoBanner(byDay[_selectedDayIndex!]),
            const SizedBox(height: 14),
          ],
          SizedBox(height: 200, child: _dayLineChart(byDay)),
          const SizedBox(height: 6),
          Text('Tap a point to see the breakdown for that day',
              style: GoogleFonts.poppins(fontSize: 9.5, color: ColorConstants.textTertiary)),
        ],
      ],
    );
  }

  Widget _rangeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _rangeOptions.map((range) {
        final selected = _selectedRange == range;
        return InkWell(
          onTap: () => _applyRange(range),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? ColorConstants.primary : ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? ColorConstants.primary : ColorConstants.divider),
            ),
            child: Text(
              range,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ColorConstants.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dayInfoBanner(Map<String, dynamic> day) {
    final date = '${day['date'] ?? ''}';
    String label = date;
    try {
      label = DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {}
    return _infoBanner(
      icon: Icons.calendar_month_outlined,
      color: ColorConstants.primary,
      title: label,
      value: 'Total ${day['total'] ?? 0} · Linen ${day['linen'] ?? 0} · Cleaning ${day['cleaning'] ?? 0}',
    );
  }

  Widget _dayLineChart(List<Map<String, dynamic>> byDay) {
    final total = byDay.map((d) => ((d['total'] ?? 0) as num).toDouble()).toList();
    final maxVal = total.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = (maxVal == 0 ? 1.0 : maxVal) * 1.25;
    final interval = _niceInterval(maxVal.toInt());
    final labelInterval = (byDay.length / 6).ceil().clamp(1, 100).toDouble();
    final spots = List.generate(byDay.length, (i) => FlSpot(i.toDouble(), total[i]));
    final maxX = byDay.length > 1 ? (byDay.length - 1).toDouble() : 1.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touched) => touched.map((s) {
              final d = byDay[s.x.toInt()];
              return LineTooltipItem(
                '${_fmtDayLabel('${d['date'] ?? ''}')}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                children: [
                  TextSpan(text: 'Total ${d['total'] ?? 0}\n', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  TextSpan(text: 'Linen ${d['linen'] ?? 0}\n', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  TextSpan(text: 'Cleaning ${d['cleaning'] ?? 0}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              );
            }).toList(),
          ),
          touchCallback: (event, response) {
            final spots = response?.lineBarSpots;
            if (event is FlTapUpEvent && spots != null && spots.isNotEmpty) {
              setState(() => _selectedDayIndex = spots.first.x.toInt());
            }
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: labelInterval,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx < 0 || idx >= byDay.length) return const SizedBox.shrink();
                if ((value - idx).abs() > 0.01) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_fmtDayLabel('${byDay[idx]['date'] ?? ''}'), style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textSecondary)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            barWidth: 2.5,
            isStrokeCapRound: true,
            color: ColorConstants.primary,
            dotData: FlDotData(
              show: byDay.length <= 31,
              getDotPainter: (spot, percent, barData, index) {
                final isSel = index == _selectedDayIndex;
                return FlDotCirclePainter(
                  radius: isSel ? 5 : 2.6,
                  color: isSel ? _responseColor : ColorConstants.primary,
                  strokeWidth: isSel ? 2 : 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [ColorConstants.primary.withValues(alpha: 0.22), ColorConstants.primary.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- TYPE DISTRIBUTION -----------------------------

  Widget _buildTypePieSection() {
    final r = _report!;
    final total = (r['totalCount'] ?? 0) as int;
    final cleaning = (r['cleaningCount'] ?? 0) as int;
    final linen = (r['linenCount'] ?? 0) as int;

    final entries = <_TypeEntry>[
      if (cleaning > 0)
        _TypeEntry('Cleaning', cleaning, _cleaningColor, Icons.cleaning_services_outlined),
      if (linen > 0)
        _TypeEntry('Linen', linen, _linenColor, Icons.bed_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Issue Type Distribution', subtitle: 'Share of each service request type'),
        const SizedBox(height: 16),
        if (total == 0 || entries.isEmpty)
          _emptyState('No service requests for the selected period.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 420;
              final donut = SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 46,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (response == null || response.touchedSection == null) return;
                            final idx = response.touchedSection!.touchedSectionIndex;
                            if (idx != _touchedPieIndex) {
                              setState(() => _touchedPieIndex = idx);
                            }
                          },
                        ),
                        sections: entries.asMap().entries.map((e) {
                          final selected = e.key == _touchedPieIndex;
                          final percent = e.value.value / total * 100;
                          return PieChartSectionData(
                            value: e.value.value.toDouble(),
                            color: e.value.color,
                            radius: selected ? 66 : 56,
                            showTitle: percent >= 8,
                            title: '${percent.round()}%',
                            titleStyle: GoogleFonts.poppins(
                              fontSize: selected ? 13 : 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            titlePositionPercentageOffset: 0.58,
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildPieCenter(entries, total),
                  ],
                ),
              );
              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.asMap().entries.map((e) {
                  final selected = e.key == _touchedPieIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _touchedPieIndex = _touchedPieIndex == e.key ? -1 : e.key;
                      }),
                      child: _pieLegendRow(e.value, total, selected: selected),
                    ),
                  );
                }).toList(),
              );
              if (!wide) {
                return Column(children: [Center(child: donut), const SizedBox(height: 16), legend]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [donut, const SizedBox(width: 16), Expanded(child: legend)],
              );
            },
          ),
      ],
    );
  }

  Widget _buildPieCenter(List<_TypeEntry> entries, int total) {
    if (_touchedPieIndex >= 0 && _touchedPieIndex < entries.length) {
      final e = entries[_touchedPieIndex];
      final percent = (e.value / total * 100).round();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(e.icon, color: e.color, size: 18),
          const SizedBox(height: 2),
          Text('${e.value}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: e.color)),
          Text('$percent% ${e.label}', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
        Text('Total Requests', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
        const SizedBox(height: 2),
        Text('tap a slice', style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textTertiary)),
      ],
    );
  }

  Widget _pieLegendRow(_TypeEntry e, int total, {required bool selected}) {
    final percent = total == 0 ? 0 : (e.value / total * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? e.color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: selected ? e.color.withValues(alpha: 0.4) : ColorConstants.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: e.color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(e.label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary))),
              Text('${e.value}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: e.color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : e.value / total,
              minHeight: 5,
              backgroundColor: ColorConstants.divider.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(e.color),
            ),
          ),
          const SizedBox(height: 4),
          Text('$percent% of total', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
        ],
      ),
    );
  }

  // ----------------------------- AVG RESPONSE TIME -----------------------------

  Widget _buildResponseTimeSection() {
    final r = _report!;
    final peak = List<Map<String, dynamic>>.from(r['peakHours'] ?? []);
    final avgResp = <double>[];
    final counts = <int>[];
    for (var h = 0; h < 24; h++) {
      final s = (peak[h]['responseSeconds'] ?? 0) as num;
      final c = (peak[h]['responseCount'] ?? 0) as num;
      counts.add(c.toInt());
      avgResp.add(c > 0 ? s / c : 0.0);
    }
    final hasData = counts.any((c) => c > 0);
    final overall = r['avgResponseSeconds'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Average Response Time', subtitle: 'Mean time taken to respond to requests, per hour'),
        const SizedBox(height: 12),
        if (!hasData)
          _emptyState('No responses recorded for the selected period.')
        else ...[
          _infoBanner(
            icon: Icons.timer_outlined,
            color: _responseColor,
            title: _selectedRespHour == null ? 'Overall average' : _hourLabel(_selectedRespHour!),
            value: _selectedRespHour == null ? _fmtResponse(overall) : _fmtResponse(avgResp[_selectedRespHour!].round()),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 190, child: _responseLineChart(avgResp, counts)),
          const SizedBox(height: 6),
          Text('Tap any point to inspect that hour',
              style: GoogleFonts.poppins(fontSize: 9.5, color: ColorConstants.textTertiary)),
        ],
      ],
    );
  }

  Widget _responseLineChart(List<double> avgResp, List<int> counts) {
    final spots = <FlSpot>[];
    for (var h = 0; h < 24; h++) {
      if (counts[h] > 0) spots.add(FlSpot(h.toDouble(), avgResp[h]));
    }
    final maxVal = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal == 0 ? 1.0 : maxVal) * 1.3;
    final interval = _niceInterval(maxVal.round());

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touched) => touched.map((s) {
              final h = s.x.toInt();
              return LineTooltipItem(
                '${_hourLabel(h)}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                children: [
                  TextSpan(text: _fmtResponse(s.y.round()), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              );
            }).toList(),
          ),
          touchCallback: (event, response) {
            final spots = response?.lineBarSpots;
            if (event is FlTapUpEvent && spots != null && spots.isNotEmpty) {
              setState(() => _selectedRespHour = spots.first.x.toInt());
            }
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                _shortDuration(value.round()),
                style: GoogleFonts.poppins(fontSize: 8.5, color: ColorConstants.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 3,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_hourLabel(value.toInt()), style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textSecondary)),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            barWidth: 2.5,
            isStrokeCapRound: true,
            color: _responseColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isSel = spot.x.toInt() == _selectedRespHour;
                return FlDotCirclePainter(
                  radius: isSel ? 5 : 2.6,
                  color: isSel ? _responseColor : _responseColor,
                  strokeWidth: isSel ? 2 : 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [_responseColor.withValues(alpha: 0.2), _responseColor.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDuration(int seconds) {
    if (seconds <= 0) return '0';
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) {
      final m = seconds ~/ 60;
      return '${m}m';
    }
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }

  // ----------------------------- ISSUES TABLE -----------------------------

  Widget _buildIssuesTable() {
    final requests = List<Map<String, dynamic>>.from(_report!['requests'] ?? []);
    if (requests.isEmpty) {
      return _sectionCard(child: _emptyState('No service requests for the selected period.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Issue Details', style: AppTextStyles.header3),
            Text('${requests.length} shown', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        _sectionCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(ColorConstants.primary.withValues(alpha: 0.08)),
              dataRowMinHeight: 44,
              dataRowMaxHeight: 56,
              headingTextStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary),
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
                final statusColor = isClosed ? _resolvedColor : _pendingColor;
                return DataRow(
                  cells: [
                    DataCell(_singleLine('${r['coach_no'] ?? ''}', AppTextStyles.coachNumber)),
                    DataCell(_singleLine('${r['compartment_no'] ?? ''}', AppTextStyles.bodyMedium)),
                    DataCell(_singleLine(_formatType('${r['issue_type'] ?? ''}'), AppTextStyles.bodyMedium)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isClosed ? 'Responded' : 'Pending',
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ),
                    DataCell(_singleLine(_fmtDateTime('${r['opened_at'] ?? ''}'), AppTextStyles.bodySmall)),
                    DataCell(_singleLine(_fmtDateTime('${r['closed_at'] ?? ''}'), AppTextStyles.bodySmall)),
                    DataCell(
                      Text(
                        _fmtResponse(r['response_seconds'] as int?),
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ColorConstants.primary),
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

  Widget _singleLine(String text, TextStyle style) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: style,
    );
  }
}

class _TypeEntry {
  _TypeEntry(this.label, this.value, this.color, this.icon);
  final String label;
  final int value;
  final Color color;
  final IconData icon;
}

class _PeakInfo {
  _PeakInfo(this.hour, this.count);
  final int hour;
  final int count;
}

class _ActivityEvent {
  _ActivityEvent({required this.r, required this.requestAt, required this.responseAt});
  final Map<String, dynamic> r;
  final DateTime requestAt;
  final DateTime? responseAt;
}
