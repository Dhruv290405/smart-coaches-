import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class AxleListCard extends StatelessWidget {
  final AxleModel axle;
  final VoidCallback? onEyeIconTap;

  const AxleListCard({
    super.key,
    required this.axle,
    this.onEyeIconTap,
  });

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return ColorConstants.statusCritical; // Red
      case 'critical':
        return ColorConstants.statusWarning; // Yellow
      default:
        return ColorConstants.iconGrey;
    }
  }

  static Color _getCardBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return const Color(0xFFE8F5E9);
      case 'warning':
        return const Color(0xFFFFEBEE);
      case 'critical':
        return const Color(0xFFFFF8E1);
      default:
        return ColorConstants.cardBackground;
    }
  }

  static String _getAxleIcon(String status) {
    switch (status.toLowerCase()) {
      case 'warning':
        return AppIcons.axelRed;
      case 'critical':
        return AppIcons.axelYellow;
      default:
        return AppIcons.axelBlue;
    }
  }

  static Color _getIconBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'warning':
        return ColorConstants.statusCritical.withValues(alpha: 0.15);
      case 'critical':
        return ColorConstants.statusWarning.withValues(alpha: 0.15);
      default:
        return ColorConstants.primary.withValues(alpha: 0.12); // Good → purple tint
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(axle.status);
    final bgColor = _getCardBgColor(axle.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + axle name + badge + eye
          Row(
            children: [
              // Axle icon with colored square background
              Container(
                width: 34,
                height: 32,
                decoration: BoxDecoration(
                  color: _getIconBgColor(axle.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    _getAxleIcon(axle.status),
                    width: 22,
                    height: 11.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Axle name
              Text(
                'Axle ${axle.axleNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.primary,
                ),
              ),
              const SizedBox(width: 8),

              // Status badge pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      axle.status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Eye icon
              GestureDetector(
                onTap: onEyeIconTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.iconGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Max Temp row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Temp:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondary,
                ),
              ),
              Text(
                axle.maxTemp,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Timestamp
          Text(
            'Updated ${axle.updateTime}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: ColorConstants.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
