import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class HotAxleCoachCard extends StatelessWidget {
  final HotAxleCoachModel coach;
  final VoidCallback? onEyeIconTap;

  const HotAxleCoachCard({super.key, required this.coach, this.onEyeIconTap});

  static String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM HH:mm').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default: return ColorConstants.iconGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(coach.status);
    final isAlert = coach.isAlert;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? statusColor.withValues(alpha: 0.05) : ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAlert ? statusColor.withValues(alpha: 0.2) : ColorConstants.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach: ${coach.coachNumber}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                    if (coach.trainNo.isNotEmpty)
                      Text('Train: ${coach.trainNo}', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                    if (coach.deviceId != 'Unknown')
                      Text('Device: ${coach.deviceId}', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textTertiary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                child: SvgPicture.asset(AppIcons.eye, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max Temp', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                    Text('${coach.maxTemp.toStringAsFixed(1)}°C', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: isAlert ? statusColor : ColorConstants.textPrimary)),
                  ],
                ),
              ),
              _buildStatusBadge(coach.status, statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTimestamp(coach.timestamp), style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textTertiary)),
              if (coach.coachType != 'Unknown')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: ColorConstants.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                  child: Text(coach.coachType, style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.primary, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
