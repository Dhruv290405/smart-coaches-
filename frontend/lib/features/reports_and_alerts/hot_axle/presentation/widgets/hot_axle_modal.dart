import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/hot_axle_model.dart';
import '../hot_axle_history_screen.dart';

class HotAxleModal extends StatelessWidget {
  final HotAxleCoachModel coach;
  const HotAxleModal({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final isAlert = coach.isAlert;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isAlert ? const Color(0xFFFFEBEB) : const Color(0xFFE8F5E9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  isAlert ? 'High Temperature Alert' : 'Hot Axle Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Coach header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAlert ? const Color(0xFFFFF0F0) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            child: Icon(
                              isAlert ? Icons.thermostat : Icons.check_circle_outline,
                              color: isAlert ? const Color(0xFFEF5350) : const Color(0xFF2E7D32),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Coach ${coach.coachNumber}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAlert ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '\u2022 ${coach.status.toUpperCase()}',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // General Info
                      _buildInfoSection('Coach Info', [
                        _buildDetailRow('Coach Number', coach.coachNumber, showTopBorder: false),
                        if (coach.trainNo.isNotEmpty)
                          _buildDetailRow('Train Number', coach.trainNo),
                        _buildDetailRow('Device ID', coach.deviceId),
                        _buildDetailRow('Coach Type', coach.coachType),
                        _buildDetailRow('Railway', coach.owningRly),
                        _buildDetailRow('Battery', '${coach.batteryPercentage}%'),
                        _buildDetailRow('Signal', '${coach.signalStrength} dBm'),
                        _buildDetailRow('Timestamp', _formatTimestamp(coach.timestamp)),
                      ]),
                      
                      const SizedBox(height: 24),

                      // Temperatures Grid
                      _buildInfoSection('Axle Temperatures (°C)', [
                        _buildAxleGrid(),
                      ]),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: ColorConstants.divider),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              ),
                              child: Text('Close', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HotAxleHistoryScreen(coach: coach),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: ColorConstants.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                              ),
                              child: Text('History', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: Colors.white)),
                            ),
                          ),
                        ],
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

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.divider),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAxleGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _buildAxleItem('A1-1', coach.a11Temp),
          _buildAxleItem('A1-2', coach.a12Temp),
          _buildAxleItem('A2-1', coach.a21Temp),
          _buildAxleItem('A2-2', coach.a22Temp),
          _buildAxleItem('A3-1', coach.a31Temp),
          _buildAxleItem('A3-2', coach.a32Temp),
          _buildAxleItem('A4-1', coach.a41Temp),
          _buildAxleItem('A4-2', coach.a42Temp),
        ],
      ),
    );
  }

  Widget _buildAxleItem(String label, double temp) {
    final isHot = temp > 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHot ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(
            '${temp.toStringAsFixed(1)}°',
            style: GoogleFonts.poppins(
              fontSize: 14, 
              fontWeight: FontWeight.w700,
              color: isHot ? const Color(0xFFD32F2F) : ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showTopBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder ? const Border(top: BorderSide(color: ColorConstants.divider)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
