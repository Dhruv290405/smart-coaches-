import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/services/socket_service.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/presentation/widgets/acp_report_generator.dart';
import '../../../../core/di/inject.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/view_type_selector.dart';
import '../data/models/acp_model.dart';
import '../data/models/acp_log_response.dart';
import 'alert_view.dart';
import 'chart_view.dart';
import 'coaches_view.dart';

class AcpDashboard extends StatefulWidget {
  const AcpDashboard({super.key});

  @override
  State<AcpDashboard> createState() => _AcpDashboardState();
}

class _AcpDashboardState extends State<AcpDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  bool showRecentOnly = false;
  Timer? _refreshTimer;

  bool _isApiCallInProgress = false;
  StreamSubscription<Map<String, dynamic>>? _acpSocketSub;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];

  List<AcpCoachModel> _allCoaches = [];
  List<AcpCoachModel> _filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _startAutoRefresh();
    _acpSocketSub = SocketService().acpStream.listen((_) {
      if (mounted) _refreshData(isBackgroundRefresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _acpSocketSub?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _scheduleNextRefresh();
  }

  void _scheduleNextRefresh() {
    _refreshTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _refreshData(isBackgroundRefresh: true);
      }
    });
  }

  void _clearFilters() {
    if (selectedTrainNumber == 'All Trains' && selectedStatus == 'All') return;
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coach Numbers';
      selectedStatus = 'All';
      showRecentOnly = false;
      coachTypes = ['All Types'];
      coachNumbers = ['All Coach Numbers'];
    });
    _refreshData();
  }

  Future<void> _loadTrains() async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters();
      if (response.success == true) {
        if (mounted) {
          setState(() {
            final data = response.data ?? [];
            final extracted = data.map((e) => e.trainNo).where((e) => e != null).cast<String>().toList();
            trainNumbers = ['All Trains', ...extracted];
          });
        }
      }
    } catch (e) {
      log('Error loading trains: $e');
    }
  }

  Future<void> _loadCoachTypes(String trainNo) async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters(trainNo: trainNo);
      if (response.success == true) {
        if (mounted) {
          setState(() {
            final data = response.data ?? [];
            final extracted = data.map((e) => e.commCoachNo).where((e) => e != null).cast<String>().toList();
            coachTypes = ['All Types', ...extracted];
            selectedCoachType = 'All Types';
            coachNumbers = ['All Coach Numbers'];
            selectedCoachNumber = 'All Coach Numbers';
          });
        }
      }
    } catch (e) {
      log('Error loading coach types: $e');
    }
  }

  Future<void> _loadCoachNumbers(String trainNo, String coachType) async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters(trainNo: trainNo, coachType: coachType);
      if (response.success == true) {
        if (mounted) {
          setState(() {
            final data = response.data ?? [];
            final extracted = data.map((e) => e.techCoachNo).where((e) => e != null).cast<String>().toList();
            coachNumbers = ['All Coach Numbers', ...extracted];
            selectedCoachNumber = 'All Coach Numbers';
          });
        }
      }
    } catch (e) {
      log('Error loading coach numbers: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || 
                           coach.trainNo == selectedTrainNumber;
        final matchesCoachType = selectedCoachType == 'All Types' || 
                               coach.coachNumber == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || 
                           coach.sensorId == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || 
                             (selectedStatus == 'ON' && coach.isChainPulled) ||
                             (selectedStatus == 'OFF' && !coach.isChainPulled);
        final matchesRecent = !showRecentOnly || coach.isRecent;
        
        return matchesTrain && matchesCoachType && matchesCoach && matchesStatus && matchesRecent;
      }).toList();
    });
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Never';
    try {
      final dateTime = DateTime.parse(timestamp);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return 'Never';
    }
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (_isApiCallInProgress) {
      if (!isBackgroundRefresh) _scheduleNextRefresh();
      return;
    }

    _isApiCallInProgress = true;

    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    if (trainNumbers.length <= 1 && selectedTrainNumber == 'All Trains') {
      _loadTrains();
    }

    try {
      var logs = <AcpLogData>[];
      if (selectedTrainNumber == 'All Trains' || selectedCoachNumber == 'All Coach Numbers') {
        logs = await getIt<AcpRepository>().getAcpSummary();
      } else {
        logs = await getIt<AcpRepository>().getAcpFilteredLogs(
          trainNo: selectedTrainNumber,
          techCoachNo: selectedCoachNumber,
        );
      }

      final List<AcpCoachModel> coaches = [];

      for (var logEntry in logs) {
        final sensorId = logEntry.techCoachNo ?? 'Unknown';
        final coachName = logEntry.commCoachNo ?? 'Unknown';
        final countVal = int.tryParse(logEntry.acpStatus ?? '0') ?? 0;

        bool isRecent = false;
        bool isStale = true;
        if (logEntry.lastHeartbeat != null) {
          try {
            final lastUpdate = DateTime.parse(logEntry.lastHeartbeat!);
            final diff = DateTime.now().difference(lastUpdate).inMinutes;
            if (diff < 5 && countVal > 0) isRecent = true;
            if (diff < 4320) isStale = false;
          } catch (_) {}
        }

        final statusLabel = logEntry.statusText ?? (countVal > 0 ? 'Pulled' : 'Not Pulled');

        // FSDS: fire_status=0 means normal (ON), fire_status=1 means bypassed (OFF)
        final fsdsStatusStr = logEntry.fsdsStatus?.toString() ?? '';
        final fsdsOn = fsdsStatusStr.isNotEmpty && fsdsStatusStr != '1';
        final bool isFsdsRecent = logEntry.fsdsTimestamp != null
            ? DateTime.tryParse(logEntry.fsdsTimestamp!) != null
                ? DateTime.now().difference(DateTime.parse(logEntry.fsdsTimestamp!)).inMinutes < 60
                : false
            : false;

        coaches.add(AcpCoachModel(
          coachNumber: coachName,
          status: logEntry.acpStatus ?? '0',
          totalCount: logEntry.totalCount ?? 0,
          todayCount: logEntry.todayCount ?? 0,
          updateTime: logEntry.lastHeartbeat ?? 'N/A',
          isChainPulled: statusLabel.toLowerCase() == 'pulled',
          location: logEntry.trainLocation ?? 'Danapur',
          lastPull: logEntry.lastHeartbeat ?? 'N/A',
          sensorId: sensorId,
          rawAssetName: logEntry.rawAssetName ?? '$coachName $sensorId',
          isOn: !isStale,
          isRecent: isRecent,
          trainNo: logEntry.trainNo ?? 'N/A',
          deviceId: logEntry.deviceId ?? 'N/A',
          totalizedCount: logEntry.totalizedCount ?? 0,
          lastTrigger: logEntry.lastTrigger,
          statusLabel: statusLabel,
          fsdsStatus: fsdsOn ? 'ON' : 'OFF',
          fsdsRecent: isFsdsRecent ? 'YES' : 'NO',
        ));
      }

      if (mounted) {
        setState(() {
          _allCoaches = coaches;
          _applyFilters();
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          if (!isBackgroundRefresh) isRefreshing = false;
        });
      }
    } catch (e) {
      log('Error refreshing data: $e');
      if (mounted && !isBackgroundRefresh) {
        setState(() => isRefreshing = false);
      }
    } finally {
      _isApiCallInProgress = false;
      if (mounted) _scheduleNextRefresh();
    }
  }

  void _sendAlerts() {
    final offlineCount = _filteredCoaches.where((c) => !c.isOn).length;
    final offlineCoaches = _filteredCoaches.where((c) => !c.isOn).map((c) => c.coachNumber).join(', ');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offline coaches will be alerted:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 12),
            Text(
              offlineCount > 0
                  ? '$offlineCount coach(s) currently offline: $offlineCoaches'
                  : 'All coaches are online',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFD32F2F), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: ColorConstants.textSecondary)),
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
        title: Text(AppStrings.acpMonitoring, style: AppTextStyles.header1),
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
                  _buildSectionCard(child: AcpCoachesView(coaches: _filteredCoaches))
                else if (selectedViewType == 'Chart View')
                  _buildSectionCard(child: AcpChartView(coaches: _filteredCoaches))
                else if (selectedViewType == 'Alerts')
                    _buildSectionCard(child: const AcpAlertsView()),
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
                items: trainNumbers.isNotEmpty ? trainNumbers : ['All Trains'],
                onChanged: (value) {
                  setState(() => selectedTrainNumber = value!);
                  if (value != 'All Trains') {
                    _loadCoachTypes(value!);
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
                label: 'Coach Type',
                value: selectedCoachType,
                items: coachTypes.isNotEmpty ? coachTypes : ['All Types'],
                onChanged: (value) {
                  setState(() => selectedCoachType = value!);
                  if (value != 'All Types' && selectedTrainNumber != 'All Trains') {
                    _loadCoachNumbers(selectedTrainNumber, value!);
                  } else {
                    setState(() {
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
                label: AppStrings.uniqueId,
                value: selectedCoachNumber,
                items: coachNumbers.isNotEmpty ? coachNumbers : ['All Coach Numbers'],
                onChanged: (value) {
                  setState(() => selectedCoachNumber = value!);
                  _refreshData();
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
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.on, isSelected: selectedStatus == 'ON', onTap: () { setState(() => selectedStatus = 'ON'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.off, isSelected: selectedStatus == 'OFF', onTap: () { setState(() => selectedStatus = 'OFF'); _applyFilters(); })),
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
                onTap: () {
                  final reportCoaches = _allCoaches.where((c) => c.todayCount > 0).toList();
                  AcpReportGenerator.generate(
                    context,
                    reportCoaches,
                    title: 'ACP Monitoring Report',
                  );
                },
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.recentlyPulled,
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