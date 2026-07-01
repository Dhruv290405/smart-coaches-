import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/repository/hot_axle_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_report_generator.dart';
import '../data/models/hot_axle_model.dart';
import 'hot_axle_alert_view.dart';
import 'hot_axle_coaches_view.dart';
import 'hot_axle_chart_view.dart';

class HotAxleDashboard extends StatefulWidget {
  const HotAxleDashboard({super.key});

  @override
  State<HotAxleDashboard> createState() => _HotAxleDashboardState();
}

class _HotAxleDashboardState extends State<HotAxleDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];

  List<HotAxleCoachModel> _allCoaches = [];
  List<HotAxleCoachModel> _filteredCoaches = [];

  List<Map<String, dynamic>> _liveAlerts = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _refreshData(isBackgroundRefresh: true);
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || coach.trainNo == selectedTrainNumber;
        final matchesType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || coach.coachNumber == selectedCoachNumber || coach.deviceId == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || coach.status.toUpperCase() == selectedStatus.toUpperCase();
        return matchesTrain && matchesType && matchesCoach && matchesStatus;
      }).toList();
    });
  }

  double _validTemp(double t) => t < 0 ? 0.0 : t;

  HotAxleCoachModel _mapDataToModel(HotAxleData d) {
    return HotAxleCoachModel(
      deviceId: d.deviceId ?? 'Unknown',
      coachNumber: d.coachNumber ?? d.techCoachNo ?? 'Unknown',
      coachType: d.coachType ?? 'Unknown',
      owningRly: d.owningRly ?? 'Unknown',
      trainNo: d.trainNo?.toString() ?? '',
      timestamp: d.timestamp ?? '',
      a11Temp: _validTemp(d.a11Temp),
      a12Temp: _validTemp(d.a12Temp),
      a21Temp: _validTemp(d.a21Temp),
      a22Temp: _validTemp(d.a22Temp),
      a31Temp: _validTemp(d.a31Temp),
      a32Temp: _validTemp(d.a32Temp),
      a41Temp: _validTemp(d.a41Temp),
      a42Temp: _validTemp(d.a42Temp),
      batteryPercentage: d.batteryPercentage,
      signalStrength: d.signalStrength,
      apiStatus: _mapAlertStatus(d.alertStatus),
    );
  }

  String _mapAlertStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'warning':  return 'Warning';
      case 'critical': return 'Critical';
      default:         return 'Good';
    }
  }

  List<Map<String, dynamic>> _buildAlerts(List<HotAxleCoachModel> coaches) {
    final alerts = <Map<String, dynamic>>[];
    for (final coach in coaches) {
      if (coach.status == 'Critical') {
        alerts.add({
          'type': 'critical',
          'title': 'Critical: Axle Overheat (Max ${coach.maxTemp.toStringAsFixed(1)}°C)',
          'coach': coach.coachNumber,
          'deviceId': coach.deviceId,
          'trainNo': coach.trainNo,
          'time': _formatTimestamp(coach.timestamp),
          'detail': 'Coach: ${coach.coachNumber}  |  Device: ${coach.deviceId}  |  Train: ${coach.trainNo}',
          'note': 'Immediate inspection required',
        });
      } else if (coach.status == 'Warning') {
        alerts.add({
          'type': 'warning',
          'title': 'Warning: Elevated axle temperature (Max ${coach.maxTemp.toStringAsFixed(1)}°C)',
          'coach': coach.coachNumber,
          'deviceId': coach.deviceId,
          'trainNo': coach.trainNo,
          'time': _formatTimestamp(coach.timestamp),
          'detail': 'Coach: ${coach.coachNumber}  |  Device: ${coach.deviceId}  |  Train: ${coach.trainNo}',
          'note': 'Monitor closely',
        });
      }
    }
    return alerts.take(20).toList();
  }

  static String _formatTimestamp(String ts) {
    if (ts.isEmpty) return 'N/A';
    try {
      final normalized = ts.contains('T') ? ts : ts.replaceFirst(' ', 'T');
      return DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(normalized).toLocal());
    } catch (_) {
      return ts;
    }
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
      final String? trainFilter = selectedTrainNumber == 'All Trains' ? null : selectedTrainNumber;
      final List<HotAxleData> rawData = await getIt<HotAxleRepository>().getHotAxleDashboard(trainNo: trainFilter);
      final List<HotAxleCoachModel> coaches = rawData.map(_mapDataToModel).toList();

      if (mounted) {
        setState(() {
          isRefreshing = false;
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          _allCoaches = coaches;

          trainNumbers = ['All Trains', ...coaches.map((e) => e.trainNo).where((e) => e.isNotEmpty).toSet()];
          coachTypes = ['All Types', ...coaches.map((e) => e.coachType).where((e) => e != 'Unknown').toSet()];
          coachNumbers = ['All Coach Numbers', ...coaches.map((e) => e.coachNumber).toSet()];

          if (!trainNumbers.contains(selectedTrainNumber)) selectedTrainNumber = 'All Trains';
          if (!coachTypes.contains(selectedCoachType)) selectedCoachType = 'All Types';
          if (!coachNumbers.contains(selectedCoachNumber)) selectedCoachNumber = 'All Coach Numbers';

          _liveAlerts = _buildAlerts(coaches);
          _applyFilters();
        });
      }
    } catch (e) {
      log('Hot Axle error: $e');
      if (mounted && !isBackgroundRefresh) setState(() => isRefreshing = false);
    }
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coach Numbers';
      selectedStatus = 'All';
    });
    _applyFilters();
  }

  void _sendAlerts() {
    final criticalCoaches = _allCoaches.where((c) => c.status == 'Critical').toList();
    if (criticalCoaches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No critical axles detected to alert.')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${criticalCoaches.length} coach(es) have critical axle overheat:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 12),
            ...criticalCoaches.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.warning, size: 16, color: ColorConstants.statusCritical),
                const SizedBox(width: 8),
                Expanded(child: Text('${c.coachNumber} — ${c.deviceId} (${c.trainNo})', style: GoogleFonts.poppins(fontSize: 12))),
              ]),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: ColorConstants.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert sent to control room', style: GoogleFonts.poppins(fontSize: 13)), backgroundColor: Colors.green[700], behavior: SnackBarBehavior.floating));
            },
            child: Text('Send Now', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary), onPressed: () => Navigator.pop(context)),
        titleSpacing: 4,
        title: Text(AppStrings.hotAxleMonitoring, style: AppTextStyles.header1),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(8)),
                child: Text('Last Updated: $lastUpdated', style: AppTextStyles.bodySmall),
              ),
            ),
          ),
        ],
      ),
      body: (isRefreshing && _allCoaches.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(child: _buildFiltersSection()),
                      const SizedBox(height: 8),
                      _buildSectionCard(child: _buildQuickActionsSection()),
                      const SizedBox(height: 8),
                      _buildSectionCard(child: _buildViewTypeSection()),
                      const SizedBox(height: 8),
                      if (selectedViewType == 'Coaches')
                        _buildSectionCard(child: HotAxleCoachesView(coaches: _filteredCoaches))
                      else if (selectedViewType == 'Chart View')
                        _buildSectionCard(child: HotAxleChartView(coaches: _filteredCoaches))
                      else if (selectedViewType == 'Alerts')
                        _buildSectionCard(child: HotAxleAlertView(alerts: _liveAlerts)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: child,
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.filters, style: AppTextStyles.header2.copyWith(color: ColorConstants.primary)),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: ColorConstants.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Row(children: [
                  const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                  const SizedBox(width: 4),
                  Text('Clear Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilterDropdown(
                label: AppStrings.trainNumber,
                value: selectedTrainNumber,
                items: trainNumbers,
                onChanged: (value) {
                  setState(() { selectedTrainNumber = value!; selectedCoachType = 'All Types'; selectedCoachNumber = 'All Coach Numbers'; });
                  _refreshData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Type',
                value: selectedCoachType,
                items: coachTypes,
                onChanged: (value) { setState(() { selectedCoachType = value!; selectedCoachNumber = 'All Coach Numbers'; }); _applyFilters(); },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.uniqueId,
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (value) { setState(() => selectedCoachNumber = value!); _applyFilters(); },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.good, isSelected: selectedStatus == 'Good', onTap: () { setState(() => selectedStatus = 'Good'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.warning, isSelected: selectedStatus == 'Warning', onTap: () { setState(() => selectedStatus = 'Warning'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.critical, isSelected: selectedStatus == 'Critical', onTap: () { setState(() => selectedStatus = 'Critical'); _applyFilters(); })),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: AppStrings.sendAlerts,
                svgIcon: AppIcons.alert,
                onTap: _sendAlerts,
                isPrimary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () => HotAxleReportGenerator.generate(context, _filteredCoaches),
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isRefreshing ? () {} : _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusMedium), border: Border.all(color: ColorConstants.divider)),
                child: isRefreshing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary))
                    : SvgPicture.asset(AppIcons.refresh, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ViewTypeSelector(label: AppStrings.coachesView, svgIcon: AppIcons.coaches, isSelected: selectedViewType == 'Coaches', onTap: () => setState(() => selectedViewType = 'Coaches'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.chartView, svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Chart View', onTap: () => setState(() => selectedViewType = 'Chart View'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.alerts, svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
    );
  }
}
