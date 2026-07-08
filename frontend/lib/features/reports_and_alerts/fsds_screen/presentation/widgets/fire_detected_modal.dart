import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/fsds_history_screen.dart';


class FireDetectedModal extends StatelessWidget {
  final FsdsBypassModel sensor;

  const FireDetectedModal({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFD32F2F);
    const pinkBg = Color(0xFFFFEBEB);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: pinkBg,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Fire Detected',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: redColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: ColorConstants.divider),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 32,
                  decoration: BoxDecoration(
                    color: pinkBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFEF5350),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Text(
                  sensor.assetName.isNotEmpty ? sensor.assetName : sensor.deviceId,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primary,
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: redColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: redColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sensor.statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: redColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildDividerRow('Device ID', sensor.deviceId),
                _buildDividerRow('Asset Name', sensor.assetName),
                _buildDividerRow('Fire Status', sensor.fireStatus.toString()),
                _buildDividerRow('Methane Level', sensor.methaneLevel.toString()),
                _buildDividerRow('Location', sensor.locName, isLast: true),
                _buildDividerRow('Time', _fmtTimestamp(sensor.timestamp), isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: ColorConstants.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FsdsHistoryScreen(sensor: sensor),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: ColorConstants.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'View Full History',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDividerRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: ColorConstants.divider),
      ],
    );
  }

  String _fmtTimestamp(String ts) {
    try {
      final date = DateTime.parse(ts.contains('T') ? ts : ts.replaceFirst(' ', 'T'));
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    } catch (_) {
      return ts;
    }
  }
}
