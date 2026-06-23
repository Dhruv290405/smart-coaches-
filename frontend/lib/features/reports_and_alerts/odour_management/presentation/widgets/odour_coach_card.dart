import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import 'odour_modal.dart';

class OdourCoachCard extends StatelessWidget {
  final OdourCoachModel coach;

  const OdourCoachCard({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final bool isBad = coach.reading > 70;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => OdourModal(coach: coach),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBad ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isBad ? Colors.red.withOpacity(0.1) : ColorConstants.divider.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Coach ${coach.coachNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.primary,
                    ),
                  ),
                ),
                _buildStatusBadge(coach.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              coach.toiletPosition,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: ColorConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Odour Level',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: ColorConstants.textTertiary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${coach.reading}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isBad ? Colors.red : ColorConstants.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ppm',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
