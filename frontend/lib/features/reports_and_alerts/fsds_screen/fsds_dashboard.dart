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
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import '../../../../core/di/inject.dart';
import 'presentation/widgets/fsds_report_generator.dart';
import 'data/models/fsds_model.dart';

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

  List<FsdsBypassModel> _allAssets = [];
  List<FsdsBypassModel> _filteredAssets = [];

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
      showRecentOnly = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredAssets = _allAssets.where((asset) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || asset.trainNo == selectedTrainNumber;
        final matchesCoach = selectedCoachNumber == 'All Coach Numbers' || asset.coachNo == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' ||
                             (selectedStatus == 'ON' && asset.isBypassed) ||
                             (selectedStatus == 'OFF' && !asset.isBypassed);
        final matchesRecent = !showRecentOnly || asset.isRecent;
        return matchesTrain && matchesCoach && matchesStatus && matchesRecent;
      }).toList();
    });
  }

  Future<void> _loadAllTrains() async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters();
      if (response.success == true && mounted) {
        setState(() {
          final data = response.data ?? [];
          trainNumbers = ['All Trains', ...data.map((e) => e.trainNo).where((e) => e != null).cast<String>().toSet()];
        });
      }
    } catch (e) {
      log('Error loading trains: $e');
    }
  }

  Future<void> _loadCoachTypes(String trainNo) async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters(trainNo: trainNo);
      if (response.success == true && mounted) {
        setState(() {
          final data = response.data ?? [];
          coachTypes = ['All Types', ...data.map((e) => e.commCoachNo).where((e) => e != null).cast<String>().toSet()];
          selectedCoachType = 'All Types';
          coachNumbers = ['All Coach Numbers'];
          selectedCoachNumber = 'All Coach Numbers';
        });
      }
    } catch (e) {
      log('Error loading coach types: $e');
    }
  }

  Future<void> _loadCoachNumbers(String trainNo, String coachType) async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters(trainNo: trainNo, coachType: coachType);
      if (response.success == true && mounted) {
        setState(() {
          final data = response.data ?? [];
          coachNumbers = ['All Coach Numbers', ...data.map((e) => e.techCoachNo).where((e) => e != null).cast<String>().toSet()];
          selectedCoachNumber = 'All Coach Numbers';
        });
      }
    } catch (e) {
      log('Error loading coach numbers: $e');
    }
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    if (trainNumbers.length <= 1 && selectedTrainNumber == 'All Trains') {
      _loadAllTrains();
    }

    try {
      List<FsdsBypassModel> assets = [];

      final logs = await getIt<AcpRepository>().getAcpSummary();

      for (var logEntry in logs) {
        final isBypassed = logEntry.acpStatus == '1';
        final timestamp = logEntry.lastHeartbeat ?? DateTime.now().toIso8601String();
        assets.add(FsdsBypassModel(
          assetId: logEntry.logId?.toString() ?? '',
          assetName: logEntry.commCoachNo ?? logEntry.techCoachNo ?? 'Unknown',
          timestamp: timestamp,
          isBypassed: isBypassed,
          sensorId: logEntry.techCoachNo ?? '',
          locName: logEntry.trainLocation ?? '',
          locId: '',
          trainNo: logEntry.trainNo ?? '',
          coachNo: logEntry.commCoachNo ?? logEntry.techCoachNo ?? '',
          deviceId: logEntry.deviceId ?? '',
        ));
      }

      if (mounted) {
        setState(() {
          _allAssets = assets;
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
        title: Text(widget.title ?? "FSDS Bypass Dashboard", style: AppTextStyles.header1),
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
              onRefresh: () => _refreshData(),
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
                      _buildSectionCard(child: _buildCoachesView())
                    else if (selectedViewType == 'Chart View')
                      _buildSectionCard(child: _buildChartView())
                    else if (selectedViewType == 'Alerts')
                      _buildSectionCard(child: _buildAlertsView()),
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
                    Text('Clear Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
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
                  if (v! != 'All Trains') {
                    _loadCoachTypes(v);
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
                items: coachTypes,
                onChanged: (v) {
                  setState(() => selectedCoachType = v!);
                  if (v! != 'All Types' && selectedTrainNumber != 'All Trains') {
                    _loadCoachNumbers(selectedTrainNumber, v);
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
                label: 'Coach Number',
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (v) {
                  setState(() => selectedCoachNumber = v!);
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
            Expanded(child: StatusChip(label: 'Bypassed', isSelected: selectedStatus == 'ON', onTap: () { setState(() => selectedStatus = 'ON'); _applyFilters(); })),
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
              onTap: isRefreshing ? () {} : () => _refreshData(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
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

  Widget _buildCoachesView() {
    if (_filteredAssets.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No data found matching filters")));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('FSDS Bypass Status', style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: ColorConstants.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('${_filteredAssets.length} Assets', style: AppTextStyles.badge),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._filteredAssets.map((asset) => _buildCoachCard(asset)),
      ],
    );
  }

  Widget _buildCoachCard(FsdsBypassModel asset) {
    final isBypassed = asset.isBypassed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isBypassed ? const Color(0xFFEF9A9A) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBypassed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBypassed ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: isBypassed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.coachNo.isNotEmpty ? asset.coachNo : asset.assetName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                if (asset.trainNo.isNotEmpty)
                  Text('Train: ${asset.trainNo}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                if (asset.locName.isNotEmpty)
                  Text('Location: ${asset.locName}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                if (asset.deviceId.isNotEmpty)
                  Text('Device: ${asset.deviceId}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Status", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isBypassed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  asset.statusText,
                  style: TextStyle(
                    color: isBypassed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    if (_filteredAssets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bypass Status Overview', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        if (true) _buildPieChart(),
      ],
    );
  }

  Widget _buildPieChart() {
    final bypassedCount = _filteredAssets.where((a) => a.isBypassed).length;
    final normalCount = _filteredAssets.where((a) => !a.isBypassed).length;
    final total = _filteredAssets.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFFD32F2F), 'Bypassed ($bypassedCount)'),
            const SizedBox(width: 20),
            _legend(const Color(0xFF2E7D32), 'Normal ($normalCount)'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _statRow('Total Assets', '$total'),
            _statRow('Bypassed', '$bypassedCount', const Color(0xFFD32F2F)),
            _statRow('Normal', '$normalCount', const Color(0xFF2E7D32)),
          ]),
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

  Widget _statRow(String l, String v, [Color? c]) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        if (c != null) ...{
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
        },
        Text(l, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      ]),
      Text(v, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildAlertsView() {
    final alerts = _filteredAssets.where((a) => a.isBypassed).toList();
    if (alerts.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No active bypass alerts', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textSecondary)),
        ]),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
            child: Text('${alerts.length} Active', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F))),
          ),
        ]),
        const SizedBox(height: 16),
        ...alerts.map((alert) {
          String timeStr = 'Unknown';
          try {
            final date = DateTime.parse(alert.timestamp);
            timeStr = DateFormat('MMM dd, HH:mm:ss').format(date);
          } catch (_) {}
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: const Color(0xFFEF9A9A), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FSDS BYPASS ACTIVE', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFD32F2F))),
                  const SizedBox(height: 4),
                  Text('${alert.coachNo}  |  $timeStr', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE53935))),
                  if (alert.locName.isNotEmpty)
                    Text('Location: ${alert.locName}', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                  if (alert.deviceId.isNotEmpty)
                    Text('Device: ${alert.deviceId}', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                ])),
              ],
            ),
          );
        }),
      ],
    );
  }
}
