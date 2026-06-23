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
import 'data/models/fsds_model.dart';
import 'presentation/widgets/fsds_report_generator.dart';
import 'fsds_coaches_view.dart';
import 'fsds_chart_view.dart';
import 'fsds_alerts_view.dart';

class FsdsDashboard extends StatefulWidget {
  final String? title;
  const FsdsDashboard({super.key, this.title});

  @override
  State<FsdsDashboard> createState() => _FsdsDashboardState();
}

class _FsdsDashboardState extends State<FsdsDashboard> {
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

  List<FsdsAssetModel> _allAssets = [];
  List<FsdsAssetModel> _filteredAssets = [];

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _refreshData(isBackgroundRefresh: true);
      }
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
      _filteredAssets = _allAssets.where((asset) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || asset.locName.contains(selectedTrainNumber);
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || asset.assetName.contains(selectedCoachNumber);
        final matchesStatus = selectedStatus == 'All' || 
                             (selectedStatus == 'ON' && asset.isSmokeDetected) ||
                             (selectedStatus == 'OFF' && !asset.isSmokeDetected);
        final matchesRecent = !showRecentOnly || asset.isRecent;
        
        return matchesTrain && matchesCoach && matchesStatus && matchesRecent;
      }).toList();
    });
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data based on FSDS payload
      final List<FsdsAssetModel> mockData = [
        FsdsAssetModel(
          assetId: "7d831f05-d38f-4c41-833a-1c43fa9a240a",
          assetName: "GS 255386 FSDS 1",
          timestamp: "2026-04-23T10:18:19.209Z",
          lightValue: 1023,
          smokeLevel: 45,
          sensorId: "FSDS_TEST_001",
          locName: "VASP FSDS Train 8",
          locId: "be3c934f-28ed-4300-b278-aabfa8d1eca6",
        ),
        FsdsAssetModel(
          assetId: "8e942f16-e49g-5d52-944b-2d54gb0b351b",
          assetName: "GS 255387 FSDS 2",
          timestamp: "2026-04-23T10:25:00.000Z",
          lightValue: 100,
          smokeLevel: 10,
          sensorId: "FSDS_TEST_002",
          locName: "VASP FSDS Train 8",
          locId: "be3c934f-28ed-4300-b278-aabfa8d1eca6",
        ),
        FsdsAssetModel(
          assetId: "9f053g27-f50h-6e63-055c-3e65hc1c462c",
          assetName: "GS 255388 FSDS 3",
          timestamp: "2026-04-23T10:30:00.000Z",
          lightValue: 512,
          smokeLevel: 65,
          sensorId: "FSDS_TEST_003",
          locName: "VASP FSDS Train 8",
          locId: "be3c934f-28ed-4300-b278-aabfa8d1eca6",
        ),
      ];

      if (mounted) {
        setState(() {
          _allAssets = mockData;
          trainNumbers = ['All Trains', ...mockData.map((e) => e.locName).toSet()];
          coachNumbers = ['All Coach Numbers', ...mockData.map((e) => e.assetName).toSet()];
          
          _applyFilters();
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          if (!isBackgroundRefresh) isRefreshing = false;
        });
      }
    } catch (e) {
      log('Error refreshing FSDS data: $e');
      if (mounted && !isBackgroundRefresh) {
        setState(() => isRefreshing = false);
      }
    }
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
        title: Text(widget.title ?? "FSDS Dashboard", style: AppTextStyles.header1),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Last Updated: $lastUpdated', style: AppTextStyles.bodySmall),
              ),
            ),
          ),
        ],
      ),
      body: isRefreshing && _allAssets.isEmpty
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
                    if (selectedViewType == 'Coaches')
                      _buildSectionCard(child: FsdsCoachesView(assets: _filteredAssets))
                    else if (selectedViewType == 'Chart View')
                      _buildSectionCard(child: FsdsChartView(assets: _filteredAssets))
                    else if (selectedViewType == 'Alerts')
                      _buildSectionCard(child: FsdsAlertsView(assets: _filteredAssets)),
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
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
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
            Text(
              AppStrings.filters,
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
                child: Row(
                  children: [
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
                onChanged: (v) => setState(() => selectedTrainNumber = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Type',
                value: selectedCoachType,
                items: coachTypes,
                onChanged: (v) => setState(() => selectedCoachType = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Number',
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (v) => setState(() => selectedCoachNumber = v!),
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
            Expanded(child: StatusChip(label: 'Alert', isSelected: selectedStatus == 'ON', onTap: () { setState(() => selectedStatus = 'ON'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Normal', isSelected: selectedStatus == 'OFF', onTap: () { setState(() => selectedStatus = 'OFF'); _applyFilters(); })),
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
                onTap: () {}, // Implement Send Alert Dialog if needed
                isPrimary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () {
                  FsdsReportGenerator.generate(context, _allAssets);
                },
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: 'Recent',
                svgIcon: AppIcons.alert,
                onTap: () {
                  setState(() => showRecentOnly = !showRecentOnly);
                  _applyFilters();
                },
                isPrimary: showRecentOnly,
                isFullWidth: true,
              ),
            ),
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
                    : SvgPicture.asset(
                        AppIcons.refresh,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn),
                      ),
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
            Expanded(child: ViewTypeSelector(label: "Coaches", svgIcon: AppIcons.coaches, isSelected: selectedViewType == 'Coaches', onTap: () => setState(() => selectedViewType = 'Coaches'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: "Chart View", svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Chart View', onTap: () => setState(() => selectedViewType = 'Chart View'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: "Alerts", svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
    );
  }
}
