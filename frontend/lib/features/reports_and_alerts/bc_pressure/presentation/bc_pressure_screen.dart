import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/repository/bc_pressure_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/presentation/widgets/bc_report_generator.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/view_type_selector.dart';
import '../data/models/bc_pressure_model.dart';
import 'bc_alerts_view.dart';
import 'bc_chart_view.dart';
import 'widgets/bc_pressure_modal.dart';
import 'bc_pressure_card.dart';

class BCPressureScreen extends StatefulWidget {
  const BCPressureScreen({super.key});

  @override
  State<BCPressureScreen> createState() => _BCPressureScreenState();
}

class _BCPressureScreenState extends State<BCPressureScreen> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedViewType = 'BC Pressure';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];

  List<BCPressureModel> _allCoaches = [];
  List<BCPressureModel> _filteredCoaches = [];
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
        final matchesTrain = selectedTrainNumber == 'All Trains' ||
            coach.trainNumber == selectedTrainNumber ||
            coach.owningRly == selectedTrainNumber;
        final matchesType = selectedCoachType == 'All Types' ||
            coach.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' ||
            coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' ||
            coach.status.toUpperCase() == selectedStatus.toUpperCase();
        return matchesTrain && matchesType && matchesCoach && matchesStatus;
      }).toList();
    });
  }

  BCPressureModel _mapToModel(BcPressureData d) {
    return BCPressureModel(
      deviceId: d.deviceId ?? 'Unknown',
      coachNumber: d.coachNumber ?? d.techCoachNo ?? 'Unknown',
      coachType: d.coachType ?? 'Unknown',
      owningRly: d.owningRly ?? 'Unknown',
      trainNumber: d.trainNumber ?? (d.trainNo != null ? '${d.trainNo}' : '00000'),
      readings: [
        BCPressureReading(
          currentPressure: d.currentPressure,
          chargingTime: d.chargingTime,
          dischargingTime: d.dischargingTime,
          brakeAppliedTime: d.brakeAppliedTime ?? '',
          brakeReleasedTime: d.brakeReleasedTime ?? '',
          brakeResponseTime: d.brakeResponseTime ?? 0.0,
          batteryPercentage: d.batteryPercentage,
          signalStrength: d.signalStrength,
          timestamp: d.timestamp ?? d.createdAt ?? '',
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildAlerts(List<BCPressureModel> coaches) {
    final alerts = <Map<String, dynamic>>[];
    final now = DateFormat('dd MMM, hh:mm a').format(DateTime.now());
    for (final coach in coaches) {
      final p = coach.pressure;
      if (coach.status == 'Critical') {
        alerts.add({
          'type': 'critical',
          'title': 'Critical: BC Pressure out of range (${p.toStringAsFixed(2)} kg/cm²)',
          'coach': coach.coachNumber,
          'time': now,
          'detail': 'Device: ${coach.deviceId}  |  Train: ${coach.trainNumber}',
          'note': 'Immediate inspection required',
        });
      } else if (coach.status == 'Warning') {
        alerts.add({
          'type': 'warning',
          'title': 'Warning: BC Pressure deviation (${p.toStringAsFixed(2)} kg/cm²)',
          'coach': coach.coachNumber,
          'time': now,
          'detail': 'Device: ${coach.deviceId}  |  Train: ${coach.trainNumber}',
          'note': 'Monitor closely',
        });
      }
    }
    return alerts.take(20).toList();
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
      final String? trainFilter =
          selectedTrainNumber == 'All Trains' ? null : selectedTrainNumber;

      final List<BcPressureData> rawData =
          await getIt<BcPressureRepository>().getBcPressureData(
        trainNo: trainFilter,
      );

      // Deduplicate: keep latest entry per coachNumber
      final Map<String, BcPressureData> latestByCoach = {};
      for (final d in rawData) {
        final key = d.coachNumber ?? d.deviceId ?? 'unknown';
        if (!latestByCoach.containsKey(key)) {
          latestByCoach[key] = d;
        }
      }

      final List<BCPressureModel> coaches =
          latestByCoach.values.map(_mapToModel).toList();

      if (mounted) {
        setState(() {
          isRefreshing = false;
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          _allCoaches = coaches;

          trainNumbers = ['All Trains', ...coaches.map((e) => e.trainNumber).where((e) => e != '00000' && e != 'Unknown').toSet()];
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
      log('BC Pressure error: $e');
      if (mounted && !isBackgroundRefresh) {
        setState(() => isRefreshing = false);
      }
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
    final critical = _allCoaches.where((c) => c.status == 'Critical').toList();
    if (critical.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No critical BC pressure issues detected'), behavior: SnackBarBehavior.floating));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send BC Pressure Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${critical.length} coach(es) have critical BC pressure:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 12),
            ...critical.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.warning, size: 16, color: ColorConstants.statusCritical),
                const SizedBox(width: 8),
                Expanded(child: Text('${c.coachNumber} — ${c.deviceId} (${c.trainNumber})', style: GoogleFonts.poppins(fontSize: 12))),
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
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(AppStrings.bcPressureMonitoring, style: AppTextStyles.header1),
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
                      _card(child: _buildFilters()),
                      const SizedBox(height: 8),
                      _card(child: _buildQuickActions()),
                      const SizedBox(height: 8),
                      _card(child: _buildViewType()),
                      const SizedBox(height: 8),
                      if (selectedViewType == 'BC Pressure')
                        _card(child: _buildGrid())
                      else if (selectedViewType == 'Chart View')
                        _card(child: BCChartView(coaches: _filteredCoaches))
                      else if (selectedViewType == 'Alerts')
                        _card(child: BCAlertsView(alerts: _liveAlerts)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
    decoration: BoxDecoration(
      color: ColorConstants.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
    ),
    child: child,
  );

  Widget _buildFilters() {
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
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                    const SizedBox(width: 4),
                    Text('Clear Filters', style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                  ],
                ),
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
                onChanged: (v) {
                  setState(() {
                    selectedTrainNumber = v!;
                    selectedCoachType = 'All Types';
                    selectedCoachNumber = 'All Coach Numbers';
                  });
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
                onChanged: (v) {
                  setState(() {
                    selectedCoachType = v!;
                    selectedCoachNumber = 'All Coach Numbers';
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.uniqueId,
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (v) {
                  setState(() => selectedCoachNumber = v!);
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all,      isSelected: selectedStatus == 'All',      onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.good,     isSelected: selectedStatus == 'Good',     onTap: () { setState(() => selectedStatus = 'Good'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.warning,  isSelected: selectedStatus == 'Warning',  onTap: () { setState(() => selectedStatus = 'Warning'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.critical, isSelected: selectedStatus == 'Critical', onTap: () { setState(() => selectedStatus = 'Critical'); _applyFilters(); })),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ActionButton(label: AppStrings.sendAlerts,    svgIcon: AppIcons.alert,  onTap: _sendAlerts, isPrimary: true, isFullWidth: true)),
            const SizedBox(width: 8),
            Expanded(child: ActionButton(label: AppStrings.generateReport, svgIcon: AppIcons.report, onTap: () => BCReportGenerator.generate(context, _filteredCoaches), isFullWidth: true)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isRefreshing ? () {} : _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
                child: isRefreshing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary))
                    : const Icon(Icons.refresh, size: 18, color: ColorConstants.iconGrey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ViewTypeSelector(label: AppStrings.bcPressure, svgIcon: AppIcons.bcPressure, isSelected: selectedViewType == 'BC Pressure', onTap: () => setState(() => selectedViewType = 'BC Pressure'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.chartView,  svgIcon: AppIcons.graph,      isSelected: selectedViewType == 'Chart View',  onTap: () => setState(() => selectedViewType = 'Chart View'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.alerts,     svgIcon: AppIcons.alert,      isSelected: selectedViewType == 'Alerts',      onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.bcPressure, style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: ColorConstants.primary, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  SvgPicture.asset(AppIcons.train, width: 14, height: 14, colorFilter: const ColorFilter.mode(ColorConstants.white, BlendMode.srcIn)),
                  const SizedBox(width: 4),
                  Text('${_filteredCoaches.length} Coaches', style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _filteredCoaches.map((coach) {
                return SizedBox(
                  width: cardWidth,
                  child: BCPressureCard(
                    coach: coach,
                    onEyeIconTap: () => showDialog(
                      context: context,
                      builder: (_) => BCPressureModal(coach: coach),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
