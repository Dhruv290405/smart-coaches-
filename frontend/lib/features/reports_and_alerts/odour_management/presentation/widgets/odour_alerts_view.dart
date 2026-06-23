import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';

class OdourAlertsView extends StatelessWidget {
  const OdourAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Alerts", style: AppTextStyles.header2),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          bgColor: const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFD32F2F),
          title: 'High Odour Level Detected',
          subtitle: 'Coach B1 | Today, 10:45 AM\nReading: 85 ppm | Toilet: L-Side-Front',
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: iconColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: iconColor.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
