import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/helper/status_helper.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/loco_badge.dart';
import 'package:smart_coach_new/core/widgets/update_info.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/models/diesel_tank_model.dart';


class DieselTankView extends StatelessWidget {
  final DieselTankModel tank;

  const DieselTankView({super.key, required this.tank});

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelper.getStatusColor(tank.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.dieselTank, style: AppTextStyles.header2),
            const LocoBadge(),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${tank.percentage}%',
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              tank.status,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: ColorConstants.statusCritical,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Critical if below 15%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ColorConstants.statusCritical,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: ColorConstants.statusWarning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Low if below 40%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ColorConstants.statusWarning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: tank.percentage / 100,
            minHeight: 20,
            backgroundColor: ColorConstants.divider,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 12),

        UpdateInfo(
          lastUpdated: tank.getFormattedDate(),
          refilledBy: tank.refilledBy,
        ),
      ],
    );
  }
}
