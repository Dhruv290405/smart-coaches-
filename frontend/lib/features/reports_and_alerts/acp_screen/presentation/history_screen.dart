import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_coach_history_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import '../../../../core/di/inject.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';
import '../data/models/acp_model.dart';

class AcpHistoryScreen extends StatefulWidget {
  final AcpCoachModel coach;
  const AcpHistoryScreen({super.key, required this.coach});

  @override
  State<AcpHistoryScreen> createState() => _AcpHistoryScreenState();
}

class _AcpHistoryScreenState extends State<AcpHistoryScreen> {
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;
  List<AcpCoachHistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  String _startDate() {
    final now = DateTime.now();
    if (selectedPeriod == '30 Days') {
      return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
    }
    if (selectedPeriod == 'Custom' && customRange != null) {
      return DateFormat('yyyy-MM-dd').format(customRange!.start);
    }
    // default: 7 Days
    return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
  }

  String _endDate() {
    if (selectedPeriod == 'Custom' && customRange != null) {
      return DateFormat('yyyy-MM-dd').format(customRange!.end);
    }
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final entries = await getIt<AcpRepository>().getAcpCoachHistory(
        coachId: widget.coach.sensorId,
        fromDate: _startDate(),
        toDate: _endDate(),
      );
      if (mounted) {
        setState(() {
          _historyEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        customRange = range;
        selectedPeriod = 'Custom';
      });
      _fetchHistory();
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
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(AppStrings.acpMonitoring, style: AppTextStyles.header1),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrainInfoCard(),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.coach.coachNumber} (${AppStrings.chainPullHistory})',
                            style: AppTextStyles.header2,
                          ),
                          const SizedBox(height: 16),
                          PeriodFilter(
                            selected: selectedPeriod,
                            periods: const ['7 Days', '30 Days', 'Custom'],
                            onChanged: (value) async {
                              if (value == 'Custom') {
                                await _pickCustomRange();
                              } else {
                                setState(() {
                                  selectedPeriod = value;
                                  customRange = null;
                                });
                                _fetchHistory();
                              }
                            },
                          ),
                          if (selectedPeriod == 'Custom' && customRange != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorConstants.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_fmt(customRange!.start)}  →  ${_fmt(customRange!.end)}',
                                style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          if (_isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ))
                          else if (_historyEntries.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(Icons.history, size: 48, color: ColorConstants.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('No chain pull events in this period', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ..._historyEntries.asMap().entries.map((e) => _buildHistoryCard(e.value, e.key + 1)),
                        ],
                      ),
                    ),
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

  Widget _buildTrainInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppIcons.train, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.primary, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Text(widget.coach.rawAssetName.isNotEmpty ? widget.coach.rawAssetName : widget.coach.location, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Last Pull: ${widget.coach.lastPull}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Device ID: ${widget.coach.deviceId}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              //   decoration: BoxDecoration(
              //     color: widget.coach.isOn ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              //   child: Text(
              //     widget.coach.status,
              //     style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: widget.coach.isOn ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F)),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AcpCoachHistoryEntry entry, int index) {
    final formattedTime = entry.eventTime != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(entry.eventDate)
        : 'N/A';

    final todayCount = entry.todayPullsCount?.toString() ?? '0';
    final totalCount = entry.totalLifetimePulls?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildRow('Tech Coach #', widget.coach.sensorId),
                _buildRow('Device ID', widget.coach.deviceId),
                const Divider(color: ColorConstants.divider),
                _buildRow('TODAY COUNT', todayCount),
                _buildRow('TOTAL COUNT', totalCount),
                const Divider(color: ColorConstants.divider),
                _buildRow('Location', entry.trainLocation ?? 'N/A'),
                _buildRow('Last Trigger', formattedTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? ColorConstants.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}