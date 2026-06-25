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
    final hasAlert = coach.hasActiveAlert;

    return InkWell(
      onTap: () => showDialog(context: context, builder: (_) => OdourModal(coach: coach)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasAlert ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: hasAlert ? Colors.red.withValues(alpha: 0.2) : ColorConstants.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Coach ${coach.coachNumber}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
                  Text('Train ${coach.trainNumber} | ${coach.coachType}', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
                ]),
              ),
              if (hasAlert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFD32F2F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('${coach.alertCount} Alert', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFFD32F2F))),
                ),
            ]),
            const SizedBox(height: 10),
            ...coach.toilets.map((t) => _toiletRow(t)),
          ],
        ),
      ),
    );
  }

  Widget _toiletRow(ToiletSensor t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: t.isBad ? const Color(0xFFD32F2F) : (t.reading > 40 ? const Color(0xFFBE8B22) : Colors.green),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(t.position.split('(').first.trim(), style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
          ),
          Text('${t.reading} ppm', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: t.isBad ? const Color(0xFFD32F2F) : ColorConstants.textPrimary)),
        ],
      ),
    );
  }
}
