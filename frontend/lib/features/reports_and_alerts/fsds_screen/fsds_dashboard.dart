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
import '../../../../core/di/inject.dart';
import '../../../../core/network/api_client.dart';
import 'presentation/widgets/fsds_report_generator.dart';
import 'data/models/fsds_model.dart';
import 'data/repository/fsds_repository.dart' show FsdsRepository;

class FsdsDashboard extends StatefulWidget {
  final String? title;
  const FsdsDashboard({super.key, this.title});

  @override
  State<FsdsDashboard> createState() => _FsdsDashboardState();
}

class _FsdsDashboardState extends State<FsdsDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoach = 'All Coaches';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  bool showRecentOnly = false;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachNumbers = ['All Coaches'];

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
      selectedCoach = 'All Coaches';
      selectedStatus = 'All';
      showRecentOnly = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredAssets = _allAssets.where((asset) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || asset.trainNo == selectedTrainNumber;
        final matchesCoach = selectedCoach == 'All Coaches' || asset.assetName == selectedCoach || asset.deviceId == selectedCoach;
        final matchesStatus = selectedStatus == 'All' ||
                             (selectedStatus == 'ON' && asset.isBypassed) ||
                             (selectedStatus == 'OFF' && !asset.isBypassed);
        final matchesRecent = !showRecentOnly || asset.isRecent;
        return matchesTrain && matchesCoach && matchesStatus && matchesRecent;
      }).toList();
    });
  }

  void _populateFilters() {
    final trains = _allAssets.map((a) => a.trainNo).where((t) => t.isNotEmpty).toSet().toList()..sort();
    final coaches = _allAssets.map((a) => a.assetName.isNotEmpty ? a.assetName : a.deviceId).where((c) => c.isNotEmpty).toSet().toList()..sort();
    setState(() {
      trainNumbers = ['All Trains', ...trains];
      coachNumbers = ['All Coaches', ...coaches];
    });
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
      final assets = await FsdsRepository(getIt<ApiClient>()).getFsdsData(limit: 500);

      if (mounted) {
        setState(() {
          _allAssets = assets;
          _populateFilters();
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
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach / Device',
                value: selectedCoach,
                items: coachNumbers,
                onChanged: (v) {
                  setState(() => selectedCoach = v!);
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
              child: Text('${_filteredAssets.length} Sensors', style: AppTextStyles.badge),
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
                Text(asset.assetName.isNotEmpty ? asset.assetName : asset.deviceId, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                if (asset.locName.isNotEmpty)
                  Text('Location: ${asset.locName}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                if (asset.deviceId.isNotEmpty)
                  Text('Device: ${asset.deviceId}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                if (asset.timestamp.isNotEmpty)
                  Text('Time: ${_fmtTimestamp(asset.timestamp)}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
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
        _buildBarChart(),
        const SizedBox(height: 16),
        _buildSummaryTable(),
      ],
    );
  }

  Widget _buildBarChart() {
    final bypassed = _filteredAssets.where((a) => a.isBypassed).length;
    final normal = _filteredAssets.where((a) => !a.isBypassed).length;
    final total = _filteredAssets.length;
    final bypassPct = total > 0 ? bypassed / total : 0.0;
    final normalPct = total > 0 ? normal / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Sensors: $total', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 28,
              child: Row(
                children: [
                  if (bypassed > 0)
                    Expanded(
                      flex: (bypassed * 100).round(),
                      child: Container(
                        alignment: Alignment.center,
                        color: const Color(0xFFD32F2F),
                        child: bypassPct > 0.08 ? Text('Bypassed ${(bypassPct * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)) : null,
                      ),
                    ),
                  if (normal > 0)
                    Expanded(
                      flex: (normal * 100).round(),
                      child: Container(
                        alignment: Alignment.center,
                        color: const Color(0xFF2E7D32),
                        child: normalPct > 0.08 ? Text('Normal ${(normalPct * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)) : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(const Color(0xFFD32F2F), 'Bypassed ($bypassed)'),
              const SizedBox(width: 20),
              _legend(const Color(0xFF2E7D32), 'Normal ($normal)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable() {
    final bypassed = _filteredAssets.where((a) => a.isBypassed).toList();
    final normal = _filteredAssets.where((a) => !a.isBypassed).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bypassed Sensors', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F))),
          const SizedBox(height: 8),
          if (bypassed.isEmpty)
            Text('None', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
          else
            ...bypassed.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('${a.deviceId} - ${a.locName} [${_fmtTimestamp(a.timestamp)}]', style: GoogleFonts.poppins(fontSize: 11)),
            )),
          const SizedBox(height: 12),
          Text('Normal Sensors', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          if (normal.isEmpty)
            Text('None', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
          else
            ...normal.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('${a.deviceId} - ${a.locName}', style: GoogleFonts.poppins(fontSize: 11)),
            )),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

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
          final timeStr = _fmtTimestamp(alert.timestamp);
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
                  Text('${alert.assetName}  |  $timeStr', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE53935))),
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

  String _fmtTimestamp(String ts) {
    try {
      final date = DateTime.parse(ts.contains('T') ? ts : ts.replaceFirst(' ', 'T'));
      return DateFormat('MMM dd, HH:mm:ss').format(date);
    } catch (_) {
      return ts;
    }
  }
}
