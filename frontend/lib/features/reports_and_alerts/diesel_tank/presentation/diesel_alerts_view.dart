import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../data/models/diesel_tank_model.dart';

class DieselAlertsView extends StatelessWidget {
  final List<DieselTankModel> tanks;

  const DieselAlertsView({super.key, required this.tanks});

  List<DieselTankModel> get _alerts {
    final alerts = tanks.where((t) {
      final status = t.status.toLowerCase();
      return status == 'critical' || status == 'warning';
    }).toList();
    alerts.sort((a, b) => a.percentage.compareTo(b.percentage));
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _alerts;

    if (alerts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'No alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: ColorConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All diesel levels are normal',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ColorConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
        const SizedBox(height: 16),
        for (final tank in alerts)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAlertCard(tank),
          ),
      ],
    );
  }

  Widget _buildAlertCard(DieselTankModel tank) {
    final isCritical = tank.status.toLowerCase() == 'critical';
    final remainingLitres = (tank.capacity * tank.percentage / 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCritical ? const Color(0xFFFFEBEB) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCritical
                  ? const Color(0xFFFFEBEB)
                  : const Color(0xFFFFF8E1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
              color: isCritical
                  ? ColorConstants.statusCritical
                  : ColorConstants.statusWarning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical
                      ? 'Critical: Low Diesel Level'
                      : 'Warning: Low Diesel Level',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCritical
                        ? ColorConstants.statusCritical
                        : ColorConstants.statusWarning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Loco: ${tank.locoNumber.isEmpty ? tank.engineId : tank.locoNumber}',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Fuel Level: ${tank.percentage}% (${remainingLitres}L remaining)',
                  style: AppTextStyles.bodySmall,
                ),
                Text('Status: ${tank.status}', style: AppTextStyles.bodySmall),
                Text(
                  'Time: ${tank.getFormattedDate()}',
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
