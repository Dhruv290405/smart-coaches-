import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/color_constants.dart';
import '../data/models/bc_pressure_model.dart';

class BCPressureCard extends StatelessWidget {
  final BCPressureModel coach;
  final VoidCallback? onEyeIconTap;

  const BCPressureCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  static String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  Color _getStatusColor(String status) {
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
    final pressure = coach.latestReading?.currentPressure ?? 0.0;
    final isAlert = coach.status != 'Good';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? statusColor.withValues(alpha: 0.05) : ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? statusColor.withValues(alpha: 0.2) : ColorConstants.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  'Coach ${coach.coachNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              GestureDetector(
                onTap: onEyeIconTap,
                child: SvgPicture.asset(
                  AppIcons.eye,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pressure',
                      style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
                    ),
                    Text(
                      '${pressure.toStringAsFixed(1)} kg/cm²',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isAlert ? statusColor : ColorConstants.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildStatusBadge(coach.status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatTimestamp(coach.latestReading?.timestamp ?? ''),
            style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
