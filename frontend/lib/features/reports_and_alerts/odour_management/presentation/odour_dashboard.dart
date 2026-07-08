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
  final OdourRepository _repository = OdourRepository();
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  bool showRecentOnly = false;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];
  List<String> toiletNumbers = ['All Toilets'];

  List<OdourCoachModel> _allCoaches = [];
  List<OdourCoachModel> _filteredCoaches = [];

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

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coach Numbers';
      selectedStatus = 'All';
      showRecentOnly = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || coach.trainNumber == selectedTrainNumber;
        final matchesType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' ||
                             (selectedStatus == 'ON' && coach.hasActiveAlert) ||
                             (selectedStatus == 'OFF' && !coach.hasActiveAlert);
        final matchesRecent = !showRecentOnly || coach.toilets.any((t) => t.isRecent);
        return matchesTrain && matchesType && matchesCoach && matchesStatus && matchesRecent;
      }).toList();
    });
  }

  List<OdourCoachModel> _generateMockData() {
    final trains = [
      {'no': '12952', 'name': 'Rajdhani Express', 'route': 'NDLS-BCT'},
      {'no': '12615', 'name': 'Grand Trunk Express', 'route': 'NDLS-MAS'},
      {'no': '12002', 'name': 'Shatabdi Express', 'route': 'NDLS-HBH'},
    ];
    final coachTypes = ['1AC', '2AC', '3AC', 'SL'];
    final positions = ['Toilet 1 (Front-Left)', 'Toilet 2 (Front-Right)', 'Toilet 3 (Rear-Left)', 'Toilet 4 (Rear-Right)'];
    final coaches = <OdourCoachModel>[];

    for (int c = 1; c <= 20; c++) {
      final train = trains[(c - 1) % 3];
      final type = coachTypes[(c - 1) % 4];
      final toilets = <ToiletSensor>[];
      for (int t = 0; t < 4; t++) {
        final isBad = (c == 4 && t == 0) || (c == 7 && t == 2) || (c == 11 && t == 1) || (c == 15 && t == 3) || (c == 19 && t == 0);
        final isWarn = !isBad && ((c == 4 && t == 1) || (c == 8 && t == 0) || (c == 12 && t == 2));
        final reading = isBad ? 75 + (c * 3) % 25 : (isWarn ? 45 + (c * 2) % 25 : 10 + (c * 5) % 30);
        toilets.add(ToiletSensor(
          id: 'T${c}0${t + 1}',
          position: positions[t],
          reading: reading,
          status: isBad ? 'Alert' : 'Active',
          isRecent: isBad,
        ));
      }
      coaches.add(OdourCoachModel(
        coachNumber: 'Coach $c',
        coachType: type,
        trainNumber: train['no']!,
        trainName: train['name']!,
        route: train['route']!,
        deviceId: 'ODR_DEV_${100 + c}',
        toilets: toilets,
      ));
    }
    return coaches;
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
<<<<<<< HEAD
      final data = await _repository.getOdourData();

      if (mounted) {
        setState(() {
          _allCoaches = data;
          trainNumbers = ['All Trains', ...data.map((e) => e.trainNumber).toSet()];
          coachTypes = ['All Types', ...data.map((e) => e.coachType).toSet()];
          coachNumbers = ['All Coach Numbers', ...data.map((e) => e.coachNumber).toSet()];
=======
      await Future.delayed(const Duration(milliseconds: 500));
      final List<OdourCoachModel> mockData = _generateMockData();

      if (mounted) {
        setState(() {
          _allCoaches = mockData;
          trainNumbers = ['All Trains', ...mockData.map((e) => e.trainNumber).toSet()];
          coachTypes = ['All Types', ...mockData.map((e) => e.coachType).toSet()];
          coachNumbers = ['All Coach Numbers', ...mockData.map((e) => e.coachNumber).toSet()];
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
          _applyFilters();
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          if (!isBackgroundRefresh) isRefreshing = false;
        });
      }
    } catch (e) {
      log('Error refreshing odour data: $e');
      if (mounted && !isBackgroundRefresh) setState(() => isRefreshing = false);
    }
  }

  void _sendAlerts() {
    final alertCoaches = _allCoaches.where((c) => c.hasActiveAlert).toList();
    if (alertCoaches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active odour alerts'), behavior: SnackBarBehavior.floating));
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
            Text('${alertCoaches.length} coach(es) with bad odour:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 12),
            ...alertCoaches.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.warning, size: 16, color: ColorConstants.statusCritical),
                const SizedBox(width: 8),
                Expanded(child: Text('${c.coachNumber} — ${c.alertCount} toilet(s) alerting', style: GoogleFonts.poppins(fontSize: 12))),
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary), onPressed: () => Navigator.pop(context)),
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
      body: isRefreshing && _allCoaches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                    if (selectedViewType == 'Coaches')
                      _buildSectionCard(child: OdourCoachesView(coaches: _filteredCoaches))
                    else if (selectedViewType == 'Chart View')
                      _buildSectionCard(child: OdourChartView(coaches: _filteredCoaches))
                    else if (selectedViewType == 'Alerts')
                      _buildSectionCard(child: OdourAlertsView(coaches: _filteredCoaches)),
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
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: FilterDropdown(label: AppStrings.trainNumber, value: selectedTrainNumber, items: trainNumbers, onChanged: (v) => setState(() => selectedTrainNumber = v!))),
          const SizedBox(width: 8),
          Expanded(child: FilterDropdown(label: 'Coach Type', value: selectedCoachType, items: coachTypes, onChanged: (v) => setState(() => selectedCoachType = v!))),
          const SizedBox(width: 8),
          Expanded(child: FilterDropdown(label: 'Coach Number', value: selectedCoachNumber, items: coachNumbers, onChanged: (v) => setState(() => selectedCoachNumber = v!))),
        ]),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
          const SizedBox(width: 8),
          Expanded(child: StatusChip(label: 'Alert', isSelected: selectedStatus == 'ON', onTap: () { setState(() => selectedStatus = 'ON'); _applyFilters(); })),
          const SizedBox(width: 8),
          Expanded(child: StatusChip(label: 'Normal', isSelected: selectedStatus == 'OFF', onTap: () { setState(() => selectedStatus = 'OFF'); _applyFilters(); })),
        ]),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ActionButton(label: AppStrings.sendAlerts, svgIcon: AppIcons.alert, onTap: _sendAlerts, isPrimary: true, isFullWidth: true)),
          const SizedBox(width: 8),
          Expanded(child: ActionButton(label: AppStrings.generateReport, svgIcon: AppIcons.report, onTap: () => OdourReportGenerator.generate(context, _allCoaches), isFullWidth: true)),
          const SizedBox(width: 8),
          Expanded(child: ActionButton(label: 'Recent', svgIcon: AppIcons.alert, onTap: () { setState(() => showRecentOnly = !showRecentOnly); _applyFilters(); }, isPrimary: showRecentOnly, isFullWidth: true)),
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
        ]),
      ],
    );
  }

  Widget _buildViewTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ViewTypeSelector(label: "Coaches", svgIcon: AppIcons.coaches, isSelected: selectedViewType == 'Coaches', onTap: () => setState(() => selectedViewType = 'Coaches'))),
          const SizedBox(width: 8),
          Expanded(child: ViewTypeSelector(label: "Chart View", svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Chart View', onTap: () => setState(() => selectedViewType = 'Chart View'))),
          const SizedBox(width: 8),
          Expanded(child: ViewTypeSelector(label: "Alerts", svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
        ]),
      ],
    );
  }
}
