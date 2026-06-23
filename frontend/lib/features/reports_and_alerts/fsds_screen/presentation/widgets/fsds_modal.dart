import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/fsds_history_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';

class FsdsModal extends StatelessWidget {
  final FsdsAssetModel coach;
  const FsdsModal({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final isAlert = coach.isSmokeDetected;

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
            // Header — always "Coach Status"
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
                  'Coach Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
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
                      // Coach header row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAlert ? const Color(0xFFFFF0F0) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            child: Icon(
                              isAlert ? Icons.local_fire_department : Icons.check_circle_outline,
                              color: isAlert ? const Color(0xFFEF5350) : const Color(0xFF2E7D32),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              coach.assetName,
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
                              '• ${isAlert ? "ALERT" : "NORMAL"}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Details — exact same fields as ACP ChainPulledModal
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorConstants.divider),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Tech Coach #', coach.sensorId, showTopBorder: false),
                            _buildDetailRow('Device ID', coach.assetId),
                            _buildDetailRow('Train No', coach.locName),
                            _buildDetailRow('Location', coach.locName),
                            _buildDetailRow(
                              'COUNT',
                              '${coach.smokeLevel} nos',
                              valueColor: isAlert ? const Color(0xFFD32F2F) : null,
                            ),
                            _buildDetailRow('TOTAL', '${coach.lightValue} nos'),
                            _buildDetailRow(
                              'STATUS',
                              isAlert ? 'ALERT' : 'NORMAL',
                              valueColor: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                            ),
                            _buildDetailRow(
                              'RECENT',
                              coach.isRecent ? 'RECENTLY TRIGGERED' : 'NOT RECENTLY TRIGGERED',
                              valueColor: coach.isRecent ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                            ),
                            _buildDetailRow('Last Updated', coach.timestamp),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: ColorConstants.divider),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                ),
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
                                    builder: (_) => FsdsHistoryScreen(
                                      coach: AcpCoachModel(
                                        coachNumber: coach.assetName,
                                        status: isAlert ? 'ALERT' : 'NORMAL',
                                        updateTime: coach.timestamp,
                                        isChainPulled: isAlert,
                                        sensorId: coach.sensorId,
                                        location: coach.locName,
                                        rawAssetName: coach.locName,
                                        isOn: !isAlert,
                                        isRecent: coach.isRecent,
                                        trainNo: coach.locName,
                                        deviceId: coach.assetId,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConstants.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                ),
                              ),
                              child: Text('View History', style: AppTextStyles.button),
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

  Widget _buildDetailRow(String label, String value, {bool showTopBorder = true, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder ? const Border(top: BorderSide(color: ColorConstants.divider)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
