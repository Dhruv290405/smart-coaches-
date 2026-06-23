import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import '../../../../core/di/inject.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';

class AcpAlertsView extends StatefulWidget {
  const AcpAlertsView({super.key});

  @override
  State<AcpAlertsView> createState() => _AcpAlertsViewState();
}

class _AcpAlertsViewState extends State<AcpAlertsView> {
  final AcpRepository _repository = getIt<AcpRepository>();
  List<AcpLogData> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final logs = await _repository.getAcpLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No recent alerts found',
            style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_logs.length} Total',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._logs.asMap().entries.map((entry) {
          int idx = entry.key;
          AcpLogData log = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAlertCard(log),
              ),
              if (idx < _logs.length - 1)
                const Divider(height: 24, color: ColorConstants.divider),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAlertCard(AcpLogData log) {
    // Current mapping (emergency is the default for metrics logs)
    final isEmergency = log.acpStatus == '1';
    
    // Parse coach number: [Coach_Code] [Coach_Number] ACP [Device_ID]
    String coachName = log.commCoachNo ?? 'Unknown';
    if (log.rawAssetName != null && log.rawAssetName!.isNotEmpty) {
      final parts = log.rawAssetName!.split(' ');
      if (parts.length >= 2) {
        coachName = parts[1];
      }
    }

    final lastUpdatedStr = log.lastUpdated ?? '';
    String timeStr = 'Unknown';
    if (lastUpdatedStr.isNotEmpty) {
      try {
        final date = DateTime.parse(lastUpdatedStr);
        timeStr = DateFormat('MMM dd, HH:mm:ss').format(date);
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEmergency ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: isEmergency ? const Color(0xFFEF9A9A) : const Color(0xFFA5D6A7),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isEmergency ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isEmergency ? Icons.error_outline : Icons.check_circle,
              color: isEmergency ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEmergency ? 'Emergency: Alarm Chain Pull' : 'Status Update',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isEmergency ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                Text(
                  '$coachName  |  $timeStr',
                  style: GoogleFonts.poppins(fontSize: 11, color: isEmergency ? const Color(0xFFE53935) : const Color(0xFF388E3C)),
                ),
                // Text(
                //   'Location: ${log.locName ?? 'N/A'}',
                //   style: GoogleFonts.poppins(fontSize: 11, color: isEmergency ? const Color(0xFFE53935) : const Color(0xFF388E3C)),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}