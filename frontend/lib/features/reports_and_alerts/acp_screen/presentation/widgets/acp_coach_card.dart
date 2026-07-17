import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/acp_model.dart';

class AcpCoachCard extends StatelessWidget {
  final AcpCoachModel coach;
  final VoidCallback? onEyeIconTap;

  const AcpCoachCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPulled = coach.isChainPulled;
    final hasDeviceId = coach.deviceId != 'N/A' && coach.deviceId.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach: ${coach.coachNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                    Text(
                      'Technical No: ${coach.sensorId}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                    if (hasDeviceId)
                      Text(
                        'Device ID: ${coach.deviceId}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textTertiary,
                ),
              ),
              Text(
                isPulled ? 'PULLED' : 'NOT PULLED',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPulled ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Count: ${coach.todayCount}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  coach.updateTime != 'N/A' ? 'Updated: ${coach.updateTime}' : '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
