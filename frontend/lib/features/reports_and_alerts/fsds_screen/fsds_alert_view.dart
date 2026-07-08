import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';

class FsdsAlertsView extends StatelessWidget {
  const FsdsAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: Icons.check_circle,
          bgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          title: 'Resolved: False Methane Detected',
          titleColor: const Color(0xFF2E7D32),
          subtitle:
              'Coach 1 | Today, 06:10 AM\nIssue resolved by: Ramesh Kumar',
          subtitleColor: const Color(0xFF388E3C),
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.error_outline,
          bgColor: const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFD32F2F),
          title: 'Emergency: Fire Detected',
          titleColor: const Color(0xFFD32F2F),
          subtitle:
              'Coach 4 | Today, 12:45 PM\nLocation: Ujjain Section | Not Reset',
          subtitleColor: const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
