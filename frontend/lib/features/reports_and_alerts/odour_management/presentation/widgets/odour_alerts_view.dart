import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import '../../data/models/odour_model.dart';

class OdourAlertsView extends StatelessWidget {
  final List<OdourCoachModel> coaches;
  const OdourAlertsView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    final alerts = coaches.where((c) => c.hasActiveAlert).toList();

    if (alerts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Alerts', style: AppTextStyles.header2),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No active odour alerts', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Alerts', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        ...alerts.map((coach) {
          final badToilets = coach.toilets.where((t) => t.isBad).toList();
          return Column(children: badToilets.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAlertCard(
              coach: coach, toilet: t,
            ),
          )).toList());
        }),
      ],
    );
  }

  Widget _buildAlertCard({required OdourCoachModel coach, required ToiletSensor toilet}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('High Odour Level Detected', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F))),
                const SizedBox(height: 4),
                Text(
                  '${coach.coachNumber} | ${coach.trainNumber}\n'
                  'Reading: ${toilet.reading} ppm | ${toilet.position}',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFD32F2F).withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
