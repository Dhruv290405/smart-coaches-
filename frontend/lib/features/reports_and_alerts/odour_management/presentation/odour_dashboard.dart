import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import '../data/models/odour_model.dart';
import '../data/repository/odour_repository.dart';
import 'widgets/odour_alerts_view.dart';
import 'widgets/odour_coaches_view.dart';
import 'widgets/odour_report_generator.dart';
import 'widgets/odour_chart_view.dart';

class OdourDashboard extends StatefulWidget {
  const OdourDashboard({super.key});

  @override
  State<OdourDashboard> createState() => _OdourDashboardState();
}

class _OdourDashboardState extends State<OdourDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Unique IDs';
  String selectedStatus = 'All';
  String selectedViewType = 'Monitoring';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  StreamSubscription<List<OdourCoachModel>>? _odourSubscription;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Unique IDs'];

  List<OdourCoachModel> _allRecords = [];
  List<OdourCoachModel> _filteredRecords = [];
  List<CoachToiletGroup> _groupedCoaches = [];

  @override
  void initState() {
    super.initState();
    _loadSampleDataInstantly();
    _subscribeToOdourData();
  }

  void _subscribeToOdourData() {
    _odourSubscription?.cancel();
    final repository = OdourRepository();
    _odourSubscription = repository.watchOdourData().listen((records) {
      if (mounted) {
        setState(() {
          _allRecords = records;
          trainNumbers = ['All Trains', ...records.map((e) => e.trainNumber).toSet()];
          coachTypes = ['All Types', ...records.map((e) => e.coachType).toSet()];
          coachNumbers = ['All Unique IDs', ...records.map((e) => e.coachNumber).toSet()];
          _applyFilters();
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
        });
      }
    }, onError: (error) {
      log('Error streaming odour data: $error');
    });
  }

  void _loadSampleDataInstantly() {
    final repository = OdourRepository();
    final records = repository.getSampleData();
    setState(() {
      _allRecords = records;
      trainNumbers = ['All Trains', ...records.map((e) => e.trainNumber).toSet()];
      coachTypes = ['All Types', ...records.map((e) => e.coachType).toSet()];
      coachNumbers = ['All Unique IDs', ...records.map((e) => e.coachNumber).toSet()];
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _odourSubscription?.cancel();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Unique IDs';
      selectedStatus = 'All';
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((r) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || r.trainNumber == selectedTrainNumber;
        final matchesType = selectedCoachType == 'All Types' || r.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Unique IDs' || r.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' ||
            (selectedStatus == 'ON' && r.isActive) ||
            (selectedStatus == 'OFF' && !r.isActive);
        return matchesTrain && matchesType && matchesCoach && matchesStatus;
      }).toList();
      _groupedCoaches = CoachToiletGroup.groupByCoach(_filteredRecords);
    });
  }

  List<Map<String, dynamic>> _generateRichData() {
    final now = DateTime.now();
    final ts = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now);
    final data = <Map<String, dynamic>>[];

    final trains = {
      '12952': {'name': 'Rajdhani Express', 'route': 'NDLS-BCT'},
      '12002': {'name': 'Shatabdi Express', 'route': 'NDLS-HBJ'},
    };

    for (final tEntry in trains.entries) {
      final tNo = tEntry.key;
      final tInfo = tEntry.value;
      final coachCount = tNo == '12952' ? 2 : 1;
      for (int c = 1; c <= coachCount; c++) {
        final coachLabel = tNo == '12952' ? (c == 1 ? 'B1' : 'A1') : 'C1';
        final coachType = tNo == '12952' ? (c == 1 ? '3AC' : '2AC') : 'CC';
        final positions = ['L-Side-Front', 'R-Side-Front', 'L-Side-Rear', 'R-Side-Rear'];
        for (int p = 0; p < positions.length; p++) {
          final readings = tNo == '12952' && coachLabel == 'B1'
              ? [85, 15, 72, 10]
              : tNo == '12952' && coachLabel == 'A1'
                  ? [12, 88, 0, 45]
                  : [70, 55, 5, 30];
          final isActive = readings[p] > 20;
          data.add({
            'coach_number': coachLabel,
            'coach_type': coachType,
            'toilet_position': positions[p],
            'status': isActive ? 'Active' : 'Inactive',
            'reading': readings[p],
            'timestamp': ts,
            'sensor_id': 'SENS-$coachLabel-T${p + 1}',
            'device_id': 'ODM-$coachLabel-T${p + 1}',
            'train_number': tNo,
            'train_name': tInfo['name'],
            'route': tInfo['route'],
            'battery_level': [85, 92, 0, 78][p],
            'refill_level': [42, 75, 10, 60][p],
            'usage_count': [18, 4, 25, 2][p],
            'cleanliness': ['Needs Cleaning', 'Clean', 'Unknown', 'Clean'][p],
            'malfunction_alerts': p == 2 ? ['Power Failure', 'Refill Low'] : <String>[],
          });
        }
      }
    }
    return data;
  }

  Future<void> _refreshData() async {
    if (mounted) setState(() => isRefreshing = true);
    _subscribeToOdourData();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Bad Odour Management", style: AppTextStyles.header1),
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
      body: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    _buildSectionCard(child: _buildFiltersSection()),
                    const SizedBox(height: 8),
                    _buildSectionCard(child: _buildQuickActionsSection()),
                    const SizedBox(height: 8),
                    _buildSectionCard(child: _buildViewTypeSection()),
                    const SizedBox(height: 8),
                    if (selectedViewType == 'Monitoring')
                      _buildSectionCard(child: OdourCoachesView(coaches: _filteredRecords, grouped: _groupedCoaches))
                    else if (selectedViewType == 'Analytics')
                      _buildSectionCard(child: OdourChartView(records: _allRecords, groups: _groupedCoaches))
                    else if (selectedViewType == 'Alerts')
                      _buildSectionCard(child: OdourAlertsView(records: _allRecords)),
                  ],
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
            Expanded(child: FilterDropdown(label: AppStrings.trainNumber, value: selectedTrainNumber, items: trainNumbers, onChanged: (v) { setState(() => selectedTrainNumber = v!); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: 'Coach Type', value: selectedCoachType, items: coachTypes, onChanged: (v) { setState(() => selectedCoachType = v!); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: 'Unique ID', value: selectedCoachNumber, items: coachNumbers, onChanged: (v) { setState(() => selectedCoachNumber = v!); _applyFilters(); })),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Active', isSelected: selectedStatus == 'ON', onTap: () { setState(() => selectedStatus = 'ON'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Inactive', isSelected: selectedStatus == 'OFF', onTap: () { setState(() => selectedStatus = 'OFF'); _applyFilters(); })),
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
            Expanded(child: ActionButton(label: AppStrings.sendAlerts, svgIcon: AppIcons.alert, onTap: _sendAlerts, isPrimary: true, isFullWidth: true)),
            const SizedBox(width: 8),
            Expanded(child: ActionButton(label: AppStrings.generateReport, svgIcon: AppIcons.report, onTap: () => OdourReportGenerator.generate(context, _allRecords), isFullWidth: true)),
            const SizedBox(width: 8),
            AnimatedSyncButton(
              isSyncing: isRefreshing,
              onTap: _refreshData,
            ),
          ],
        ),
      ],
    );
  }

  void _sendAlerts() {
    final alertCoaches = _allRecords.where((r) => r.hasAlert).map((r) => '${r.coachNumber} (${r.toiletPosition})').toSet().join(', ');
    if (alertCoaches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active odour alerts.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert sent for: $alertCoaches'), backgroundColor: ColorConstants.statusCritical));
  }

  Widget _buildViewTypeSection() {
    return Row(
      children: [
        Expanded(child: ViewTypeSelector(label: "Monitoring", svgIcon: AppIcons.coaches, isSelected: selectedViewType == 'Monitoring', onTap: () => setState(() => selectedViewType = 'Monitoring'))),
        const SizedBox(width: 8),
        Expanded(child: ViewTypeSelector(label: "Analytics", svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Analytics', onTap: () => setState(() => selectedViewType = 'Analytics'))),
        const SizedBox(width: 8),
        Expanded(child: ViewTypeSelector(label: "Alerts", svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
      ],
    );
  }
}

class AnimatedSyncButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSyncing;

  const AnimatedSyncButton({super.key, required this.onTap, required this.isSyncing});

  @override
  State<AnimatedSyncButton> createState() => _AnimatedSyncButtonState();
}

class _AnimatedSyncButtonState extends State<AnimatedSyncButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (widget.isSyncing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedSyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !oldWidget.isSyncing) {
      _controller.repeat();
    } else if (!widget.isSyncing && oldWidget.isSyncing) {
      _controller.stop();
      _controller.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSyncing ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isSyncing ? ColorConstants.primary.withValues(alpha: 0.1) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: widget.isSyncing ? ColorConstants.primary.withValues(alpha: 0.3) : ColorConstants.divider)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controller,
              child: SvgPicture.asset(
                AppIcons.refresh,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  widget.isSyncing ? ColorConstants.primary : ColorConstants.iconGrey,
                  BlendMode.srcIn
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('Sync', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: widget.isSyncing ? ColorConstants.primary : ColorConstants.textSecondary)),
          ],
        ),
      ),
    );
  }
}
