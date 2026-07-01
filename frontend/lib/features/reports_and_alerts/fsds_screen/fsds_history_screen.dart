import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import '../../../../core/di/inject.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';
import 'data/repository/fsds_repository.dart' show FsdsRepository;

class FsdsHistoryScreen extends StatefulWidget {
  final FsdsBypassModel sensor;
  const FsdsHistoryScreen({super.key, required this.sensor});

  @override
  State<FsdsHistoryScreen> createState() => _FsdsHistoryScreenState();
}

class _FsdsHistoryScreenState extends State<FsdsHistoryScreen> {
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;
  List<FsdsBypassModel> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final logs = await FsdsRepository(getIt<ApiClient>()).getFsdsData(limit: 500);

      final filtered = logs.where((e) =>
        e.deviceId == widget.sensor.deviceId ||
        e.assetName == widget.sensor.assetName
      ).toList();

      filtered.sort((a, b) {
        final da = DateTime.tryParse(a.timestamp) ?? DateTime(0);
        final db = DateTime.tryParse(b.timestamp) ?? DateTime(0);
        return da.compareTo(db);
      });

      if (mounted) {
        setState(() {
          _historyEntries = filtered.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      log('FSDS history error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FsdsBypassModel> get entries {
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
      final entryDate = DateTime.tryParse(entry.timestamp) ?? DateTime(0);
      bool afterStart = entryDate.isAfter(startDate!);
      bool beforeEnd = endDate == null || entryDate.isBefore(endDate);
      return afterStart && beforeEnd;
    }).toList();
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
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
                    _buildSensorInfoCard(),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.sensor.assetName} (FSDS Alert History)',
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

                          if (entries.isEmpty)
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

  Widget _buildSensorInfoCard() {
    final sensor = widget.sensor;
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sensor.isBypassed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  sensor.isBypassed ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: sensor.isBypassed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(sensor.assetName.isNotEmpty ? sensor.assetName : sensor.deviceId,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (sensor.locName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                  child: Text('Location: ${sensor.locName}', style: AppTextStyles.bodySmall),
                ),
              if (sensor.locName.isNotEmpty) const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Device: ${sensor.deviceId}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sensor.isBypassed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sensor.statusText,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600,
                    color: sensor.isBypassed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(FsdsBypassModel entry, int index) {
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
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: ColorConstants.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildRow('Device ID', entry.deviceId),
                _buildRow('Asset', entry.assetName),
                const Divider(color: ColorConstants.divider),
                _buildRow('Status', entry.statusText,
                    valueColor: entry.isBypassed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                _buildRow('Fire Status', entry.fireStatus.toString()),
                _buildRow('Smoke Level', entry.smokeLevel.toString()),
                const Divider(color: ColorConstants.divider),
                _buildRow('Location', entry.locName),
                _buildRow('Timestamp', _fmtTimestamp(entry.timestamp)),
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

  String _fmtTimestamp(String ts) {
    try {
      final date = DateTime.parse(ts.contains('T') ? ts : ts.replaceFirst(' ', 'T'));
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    } catch (_) {
      return ts;
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
