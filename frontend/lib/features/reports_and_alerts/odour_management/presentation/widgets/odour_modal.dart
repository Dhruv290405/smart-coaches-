import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourModal extends StatelessWidget {
  final OdourCoachModel coach;
  const OdourModal({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final hasAlert = coach.hasActiveAlert;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: hasAlert ? const Color(0xFFFFEBEB) : const Color(0xFFE8F5E9),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Center(
                child: Text(
                  hasAlert ? 'Bad Odour Alert' : 'Odour Status',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: hasAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: hasAlert ? const Color(0xFFFFF0F0) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                          child: Icon(hasAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: hasAlert ? const Color(0xFFEF5350) : const Color(0xFF2E7D32), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Coach ${coach.coachNumber}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                          Text('${coach.trainNumber} | ${coach.coachType}', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
                        ])),
                        if (hasAlert)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(4)),
                            child: Text('${coach.alertCount} ALERTS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F))),
                          ),
                      ]),
                      const SizedBox(height: 24),
                      _buildInfoSection('Coach Info', [
                        _buildDetailRow('Device ID', coach.deviceId, showTopBorder: false),
                        _buildDetailRow('Train Number', coach.trainNumber),
<<<<<<< HEAD
=======
                        _buildDetailRow('Train Name', coach.trainName),
                        _buildDetailRow('Route', coach.route),
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
                        _buildDetailRow('Coach Type', coach.coachType),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Toilet Sensors', [
                        ...coach.toilets.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _toiletCard(t),
                        )),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: ColorConstants.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium))),
                          child: Text('Close', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toiletCard(ToiletSensor t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.isBad ? const Color(0xFFFFF0F0) : (t.reading > 40 ? const Color(0xFFFFF8E1) : const Color(0xFFF5F5F5)),
        borderRadius: BorderRadius.circular(8),
      ),
<<<<<<< HEAD
      child: Column(children: [
        Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: t.isBad ? const Color(0xFFD32F2F) : (t.reading > 40 ? const Color(0xFFBE8B22) : Colors.green), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.position, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('VOC: ${t.vocIndex} | H2S: ${t.h2sPpm} ppm | NH3: ${t.nh3Ppm} ppm', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
            ]),
          ),
          Text(t.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: t.isBad ? const Color(0xFFD32F2F) : Colors.green)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _miniMetric('Temp', '${t.temperature}\u00B0C'),
          _miniMetric('Humidity', '${t.humidity}%'),
          _miniMetric('Methane', '${t.methanePpm}'),
          _miniMetric('Locks', '${t.longLockCount}'),
        ]),
=======
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: t.isBad ? const Color(0xFFD32F2F) : (t.reading > 40 ? const Color(0xFFBE8B22) : Colors.green), shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.position, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${t.reading} ppm — ${t.levelLabel}', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
          ]),
        ),
        Text(t.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: t.isBad ? const Color(0xFFD32F2F) : Colors.green)),
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
      ]),
    );
  }

<<<<<<< HEAD
  Widget _miniMetric(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
      Text(label, style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textSecondary)),
    ]);
  }

=======
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(border: Border.all(color: ColorConstants.divider), borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _buildDetailRow(String label, String value, {bool showTopBorder = true, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: showTopBorder ? const Border(top: BorderSide(color: ColorConstants.divider)) : null),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: valueColor)),
      ]),
    );
  }
}
