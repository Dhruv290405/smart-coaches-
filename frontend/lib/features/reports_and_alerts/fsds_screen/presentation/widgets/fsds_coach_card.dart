import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/fsds_model.dart';
import 'fsds_modal.dart';

class FsdsCoachCard extends StatelessWidget {
  final FsdsAssetModel coach;
  final VoidCallback? onEyeIconTap;

  const FsdsCoachCard({super.key, required this.coach, this.onEyeIconTap});

  @override
  Widget build(BuildContext context) {
    final bool isAlert = coach.isSmokeDetected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: !isAlert ? ColorConstants.cardBackground : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: !isAlert
            ? Border.all(color: ColorConstants.divider.withValues(alpha: 0.5), width: 1)
            : Border.all(color: Colors.red.withValues(alpha: 0.15), width: 1),
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
                      'Coach No: ${coach.sensorId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                    Text(
                      'Device ID: ${coach.assetId}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    builder: (_) => FsdsModal(coach: coach),
                  );
                },
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
                isAlert ? 'ALERT' : 'NORMAL',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}