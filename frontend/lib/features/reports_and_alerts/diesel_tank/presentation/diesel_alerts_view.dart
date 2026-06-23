import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';


class DieselAlertsView extends StatelessWidget {
  const DieselAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: Icons.error_outline,
          iconBgColor: const Color(0xFFFFEBEB),
          iconColor: ColorConstants.statusCritical,
          title: 'Critical Fuel Level',
          titleColor: ColorConstants.statusCritical,
          locoInfo: 'Loco: WDP4 #40345',
          fuelLevel: 'Fuel Level: 12% (600L remaining)',
          threshold: 'Threshold: Below 15%',
          time: 'Time: Today, 09:40 AM',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconColor: ColorConstants.statusWarning,
          title: 'Warning: Low Fuel',
          titleColor: ColorConstants.statusWarning,
          locoInfo: 'Loco: WDP4 #40345',
          fuelLevel: 'Fuel Level: 12% (600L remaining)',
          threshold: 'Threshold: Below 15%',
          time: 'Time: Today, 09:40 AM',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconColor: ColorConstants.statusWarning,
          title: 'Warning: Low Fuel',
          titleColor: ColorConstants.statusWarning,
          locoInfo: 'Loco: WDG3A #19234',
          fuelLevel: 'Fuel Level: 28% (1400L remaining)',
          threshold: 'Below recommended level',
          time: 'Time: Today, 08:10 AM',
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String locoInfo,
    required String fuelLevel,
    required String threshold,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Text(locoInfo, style: AppTextStyles.bodySmall),
                Text(fuelLevel, style: AppTextStyles.bodySmall),
                Text(threshold, style: AppTextStyles.bodySmall),
                Text(time, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
