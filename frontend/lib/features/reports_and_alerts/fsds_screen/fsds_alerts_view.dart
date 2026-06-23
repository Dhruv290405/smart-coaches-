import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'data/models/fsds_model.dart';

class FsdsAlertsView extends StatefulWidget {
  final List<FsdsAssetModel> assets;
  const FsdsAlertsView({super.key, required this.assets});

  @override
  State<FsdsAlertsView> createState() => _FsdsAlertsViewState();
}

class _FsdsAlertsViewState extends State<FsdsAlertsView> {
  @override
  Widget build(BuildContext context) {
    final alerts = widget.assets.where((a) => a.isSmokeDetected).toList();

    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: Colors.green.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'No active smoke/fire alerts',
                style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textSecondary),
              ),
            ],
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
                '${alerts.length} Active',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(FsdsAssetModel alert) {
    final date = DateTime.parse(alert.timestamp);
    final timeStr = DateFormat('MMM dd, HH:mm:ss').format(date);

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMOKE DETECTED',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFD32F2F)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.assetName}  |  $timeStr',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE53935)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Smoke Level: ${alert.smokeLevel}%  |  Light: ${alert.lightValue}',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFD32F2F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
