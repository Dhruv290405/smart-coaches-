import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';
import '../../../../core/di/inject.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';

class FsdsHistoryScreen extends StatefulWidget {
  final AcpCoachModel coach;
  const FsdsHistoryScreen({super.key, required this.coach});

  @override
  State<FsdsHistoryScreen> createState() => _FsdsHistoryScreenState();
}

class _FsdsHistoryScreenState extends State<FsdsHistoryScreen> {
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;
  List<AcpHistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final logs = await getIt<AcpRepository>().getAcpFilteredLogs(
        trainNo: widget.coach.trainNo != 'N/A' ? widget.coach.trainNo : null,
        techCoachNo: widget.coach.sensorId,
      );
      
      logs.sort((a, b) {
        final da = DateTime.tryParse(a.lastUpdated ?? '') ?? DateTime(0);
        final db = DateTime.tryParse(b.lastUpdated ?? '') ?? DateTime(0);
        return da.compareTo(db);
      });

      final List<AcpHistoryEntry> entriesList = [];
      int? lastCount;
      
      for (var logEntry in logs) {
        final currentCount = logEntry.totalCount ?? 0;
        
        bool isTrigger = false;
        if (lastCount != null && currentCount > lastCount) {
          isTrigger = true;
        } else if (lastCount == null && currentCount > 0) {
          isTrigger = true;
        }

        if (isTrigger) {
          String time24h = 'N/A';
          DateTime logDate = DateTime.now();
          if (logEntry.lastUpdated != null && logEntry.lastUpdated!.isNotEmpty) {
            try {
              logDate = DateTime.parse(logEntry.lastUpdated!);
              time24h = DateFormat('dd/MM/yyyy HH:mm:ss').format(logDate);
            } catch (_) {}
          }
          
          entriesList.add(AcpHistoryEntry(
            sensorId: logEntry.techCoachNo ?? 'N/A',
            lastPull: time24h,
            reset: 'N/A',
            trainSpeed: 'N/A',
            location: logEntry.trainLocation ?? 'N/A',
            date: logDate,
            status: logEntry.acpStatus ?? '0',
            totalCount: logEntry.totalCount ?? 0,
            powerCarNo: logEntry.powerCarNo ?? 'N/A',
            rawAssetName: logEntry.rawAssetName ?? '',
            deviceId: (logEntry.deviceId != null && logEntry.deviceId != 'N/A') ? logEntry.deviceId! : widget.coach.deviceId,
          ));
        }
        lastCount = currentCount;
      }

      if (mounted) {
        setState(() {
          _historyEntries = entriesList.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AcpHistoryEntry> get entries {
    if (selectedPeriod == 'All') return _historyEntries;
    
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    if (selectedPeriod == '7 Days') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (selectedPeriod == '30 Days') {
      startDate = now.subtract(const Duration(days: 30));
    } else if (selectedPeriod == 'Custom' && customRange != null) {
      startDate = customRange!.start;
      endDate = customRange!.end.add(const Duration(days: 1));
    }

    if (startDate == null) return _historyEntries;

    return _historyEntries.where((entry) {
      bool afterStart = entry.date.isAfter(startDate!);
      bool beforeEnd = endDate == null || entry.date.isBefore(endDate);
      return afterStart && beforeEnd;
    }).toList();
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 3, 12),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 2, 10),
        end: DateTime(2026, 3, 12),
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
        title: Text('FSDS History', style: AppTextStyles.header1),
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
                            '${widget.coach.coachNumber} (FSDS Alert History)',
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
                          else if (entries.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(Icons.history, size: 48, color: ColorConstants.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('No alert events in this period', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...entries.asMap().entries.map((e) => _buildHistoryCard(e.value, e.key + 1)),
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
                child: Text('Last Alert: ${widget.coach.lastPull}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Device ID: ${widget.coach.deviceId}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.coach.isOn ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.coach.status,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: widget.coach.isOn ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AcpHistoryEntry entry, int index) {
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
                _buildRow('Tech Coach #', entry.sensorId),
                _buildRow('Device ID', entry.deviceId),
                const Divider(color: ColorConstants.divider),
                _buildRow('COUNT', '${entry.status} nos'),
                _buildRow('TOTAL', '${entry.totalCount} nos'),
                const Divider(color: ColorConstants.divider),
                _buildRow('Location', entry.location),
                _buildRow('Updated At', entry.lastPull),
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
