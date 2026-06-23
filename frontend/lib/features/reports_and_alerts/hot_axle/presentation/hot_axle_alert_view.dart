import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';

class HotAxleAlertView extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const HotAxleAlertView({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final criticalCount = alerts.where((a) => a['type'] == 'critical').length;
    final warningCount = alerts.where((a) => a['type'] == 'warning').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentAlerts, style: AppTextStyles.header2),
            Row(
              children: [
                if (criticalCount > 0) _badge('$criticalCount Critical', const Color(0xFFD32F2F), const Color(0xFFFFEBEE)),
                if (warningCount > 0) ...[
                  const SizedBox(width: 6),
                  _badge('$warningCount Warning', const Color(0xFFBE8B22), const Color(0xFFFFF8E1)),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (alerts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No active alerts',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ),
          )
        else
          ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAlertCard(alert),
              )),
      ],
    );
  }

  Widget _badge(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final type = alert['type'] as String;

    final IconData icon;
    final Color bgColor, iconColor, titleColor, textColor;

    if (type == 'critical') {
      icon = Icons.error_outline;
      bgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFD32F2F);
      titleColor = const Color(0xFFD32F2F);
      textColor = const Color(0xFFE53935);
    } else if (type == 'warning') {
      icon = Icons.warning_amber_rounded;
      bgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFF9A825);
      titleColor = const Color(0xFFF9A825);
      textColor = const Color(0xFFFBC02D);
    } else {
      icon = Icons.check_circle;
      bgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      titleColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF388E3C);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: iconColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['title'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: titleColor)),
                const SizedBox(height: 3),
                Text('${alert['coach'] ?? ''}  |  ${alert['time'] ?? ''}', style: GoogleFonts.poppins(fontSize: 11, color: textColor)),
                Text(alert['detail'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: textColor)),
                const SizedBox(height: 2),
                Text(alert['note'] ?? '', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: titleColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
