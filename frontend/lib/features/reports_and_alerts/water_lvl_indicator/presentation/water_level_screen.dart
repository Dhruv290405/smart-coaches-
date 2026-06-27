import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/view_type_selector.dart';
import '../data/datasources/wli_data_service.dart';
import '../data/models/water_tank_model.dart';
import 'widgets/wli_card.dart';
import 'widgets/wli_modal.dart';
import 'widgets/wli_report_generator.dart';
import 'alerts.dart';
import 'chart_view.dart';

class WaterLevelScreen extends StatefulWidget {
  const WaterLevelScreen({super.key});

  @override
  State<WaterLevelScreen> createState() => _WaterLevelScreenState();
}

class _WaterLevelScreenState extends State<WaterLevelScreen> {
  final WliDataService _dataService = WliDataService(baseUrl: ApiConstants.devUrl);
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedViewType = 'Assets';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];

  List<WaterTankModel> _allCoaches = [];
  List<WaterTankModel> _filteredCoaches = [];

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
      coachTypes = ['All Types'];
      coachNumbers = ['All Coach Numbers'];
    });
    _refreshData();
  }
  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        // Match train by checking device_id start OR coachName start (trainNo_coachName format)
        final coachName = coach.location.coachName;
        final matchesTrain = selectedTrainNumber == 'All Trains' ||
            coach.source.deviceId.startsWith(selectedTrainNumber) ||
            coachName.startsWith('${selectedTrainNumber}_');
        final matchesType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || coach.status.toUpperCase() == selectedStatus.toUpperCase();
        return matchesTrain && matchesType && matchesCoach && matchesStatus;
      }).toList();
    });
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    if (trainNumbers.length <= 1 && selectedTrainNumber == 'All Trains') {
      await _loadTrains();
    }

    try {
      final tanks = await _dataService.fetchWliCoaches();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          isRefreshing = false;
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          _allCoaches = tanks;
          _applyFilters();
          if (!isBackgroundRefresh) isRefreshing = false;
        });
      }
    } catch (e) {
      log('Error refreshing data from API: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load WLI data.';
          isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadTrains() async {
    final Set<String> trains = {};
    for (final c in _allCoaches) {
      // Extract train prefix from device_id (format: TRAINNUM_XXXX)
      final deviceParts = c.source.deviceId.split('_');
      if (deviceParts.length > 1 && deviceParts[0].isNotEmpty) {
        trains.add(deviceParts[0]);
        continue;
      }
      // Extract train number from coachName (format: TRAINNUM_coachName)
      final nameParts = c.location.coachName.split('_');
      if (nameParts.length > 1 && nameParts[0].isNotEmpty) {
        trains.add(nameParts[0]);
      }
    }
    if (mounted) {
      setState(() {
        trainNumbers = ['All Trains', ...trains];
      });
    }
  }

  Future<void> _loadCoachTypes(String trainNo) async {
    final Set<String> types = {};
    for (final c in _allCoaches) {
      if (trainNo == 'All Trains' || c.source.deviceId.startsWith(trainNo)) {
        if (c.coachType.isNotEmpty) types.add(c.coachType);
      }
    }
    if (mounted) {
      setState(() {
        coachTypes = ['All Types', ...types];
        selectedCoachType = 'All Types';
        coachNumbers = ['All Coach Numbers'];
        selectedCoachNumber = 'All Coach Numbers';
      });
    }
  }

  Future<void> _loadCoachNumbers(String trainNo, String coachType) async {
    final Set<String> nums = {};
    for (final c in _allCoaches) {
      final matchesTrain = trainNo == 'All Trains' || c.source.deviceId.startsWith(trainNo);
      final matchesType = coachType == 'All Types' || c.coachType == coachType;
      if (matchesTrain && matchesType) nums.add(c.coachNumber);
    }
    if (mounted) {
      setState(() {
        coachNumbers = ['All Coach Numbers', ...nums];
        selectedCoachNumber = 'All Coach Numbers';
      });
    }
  }

  void _sendAlerts() {
    final criticalCoaches = _allCoaches.where((c) => c.status == 'Critical').toList();
    if (criticalCoaches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No critical water levels detected to alert.')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent alerts for ${criticalCoaches.length} critical coaches.'),
        backgroundColor: ColorConstants.statusCritical,
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
        title: Text('Water Level Indicator', style: AppTextStyles.header1),
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
                child: Text(
                  'Last Updated: $lastUpdated',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
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
                _buildSectionCard(child: _buildContent()),
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
                onChanged: (v) {
                  setState(() => selectedTrainNumber = v!);
                  if (v != 'All Trains') {
                    _loadCoachTypes(v!);
                  } else {
                    setState(() {
                      coachTypes = ['All Types'];
                      selectedCoachType = 'All Types';
                      coachNumbers = ['All Coach Numbers'];
                      selectedCoachNumber = 'All Coach Numbers';
                    });
                  }
                  _refreshData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.coachType,
                value: selectedCoachType,
                items: coachTypes,
                onChanged: (v) {
                  setState(() => selectedCoachType = v!);
                  if (v != 'All Types') {
                    _loadCoachNumbers(selectedTrainNumber, v!);
                  } else {
                    setState(() {
                      coachNumbers = ['All Coach Numbers'];
                      selectedCoachNumber = 'All Coach Numbers';
                    });
                  }
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilterDropdown(
          label: AppStrings.uniqueId,
          value: selectedCoachNumber,
          items: coachNumbers,
          onChanged: (v) {
            setState(() => selectedCoachNumber = v!);
            _applyFilters();
          },
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
                onTap: () {
                  WliReportGenerator.generate(context, _filteredCoaches);
                },
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
    return Row(
      children: [
        Expanded(child: ViewTypeSelector(label: 'Assets', svgIcon: AppIcons.bcPressure, isSelected: selectedViewType == 'Assets', onTap: () => setState(() => selectedViewType = 'Assets'))),
        const SizedBox(width: 8),
        Expanded(child: ViewTypeSelector(label: 'Chart', svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Chart', onTap: () => setState(() => selectedViewType = 'Chart'))),
        const SizedBox(width: 8),
        Expanded(child: ViewTypeSelector(label: 'Alerts', svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
      ],
    );
  }

  Widget _buildContent() {
    if (selectedViewType == 'Chart') return ChartView(coaches: _filteredCoaches);
    if (selectedViewType == 'Alerts') return AlertsView(coaches: _filteredCoaches);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Assets', style: AppTextStyles.header2),
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
                  child: WliCard(
                    coach: coach,
                    onEyeIconTap: () => showDialog(
                      context: context,
                      builder: (context) => WliModal(coach: coach),
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