import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../data/models/water_tank_model.dart';

class AlertsView extends StatelessWidget {
  final List<WaterTankModel> coaches;

  const AlertsView({super.key, required this.coaches});

  List<WaterTankModel> get _criticalAlerts =>
      coaches.where((c) => c.status == 'Critical').toList()
        ..sort((a, b) => a.averagePercent.compareTo(b.averagePercent));

  List<WaterTankModel> get _warningAlerts =>
      coaches.where((c) => c.status == 'Warning').toList()
        ..sort((a, b) => a.averagePercent.compareTo(b.averagePercent));

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final critical = _criticalAlerts;
    final warning = _warningAlerts;

    if (critical.isEmpty && warning.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Alerts', style: AppTextStyles.header2),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
                const SizedBox(height: 12),
                Text('No alerts', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('All water levels are normal', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Alerts', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        // Critical alerts
        ...critical.map((coach) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertCard(
            icon: Icons.error_outline,
            iconBgColor: const Color(0xFFFFEBEB),
            iconColor: ColorConstants.statusCritical,
            title: 'Critical: Very Low Water Level',
            titleColor: ColorConstants.statusCritical,
            subtitle: '${coach.location.coachName} - ${coach.averagePercent.toStringAsFixed(1)}% - ${_formatTimestamp(coach.timestamp)}',
          ),
        )),
        // Warning alerts
        ...warning.map((coach) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertCard(
            icon: Icons.warning_amber_rounded,
            iconBgColor: const Color(0xFFFFF8E1),
            iconColor: ColorConstants.statusWarning,
            title: 'Warning: Low Water Level',
            titleColor: ColorConstants.statusWarning,
            subtitle: '${coach.location.coachName} - ${coach.averagePercent.toStringAsFixed(1)}% - ${_formatTimestamp(coach.timestamp)}',
          ),
        )),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
