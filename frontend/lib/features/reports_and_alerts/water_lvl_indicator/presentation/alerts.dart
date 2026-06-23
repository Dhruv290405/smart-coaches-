import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';


class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Alerts', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: Icons.error_outline,
          iconBgColor: const Color(0xFFFFEBEB),
          iconColor: ColorConstants.statusCritical,
          title: 'Warning: Low Water Level',
          titleColor: ColorConstants.statusCritical,
          subtitle: 'Coach 1 (1001553) - 60% - 22 Jun, 09:45 AM',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconColor: ColorConstants.statusWarning,
          title: 'Critical: Low Water Level',
          titleColor: ColorConstants.statusWarning,
          subtitle: 'Coach 4 (1001483) - 45% - 22 Jun, 08:30 AM',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconColor: ColorConstants.statusWarning,
          title: 'Critical: Low Water Level',
          titleColor: ColorConstants.statusWarning,
          subtitle: 'Coach 5 (1001629) - 40% - 22 Jun, 08:15 AM',
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
