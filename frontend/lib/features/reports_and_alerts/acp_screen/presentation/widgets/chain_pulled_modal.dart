// lib/features/reports_and_alerts/acp_screen/presentation/widgets/chain_pulled_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/acp_model.dart';
import '../history_screen.dart';

class ChainPulledModal extends StatelessWidget {
  final AcpCoachModel coach;
  const ChainPulledModal({super.key, required this.coach});

  String _formatDatetime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = coach.isChainPulled;
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
                  isAlert ? 'Chain Pulled' : 'Coach Status',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
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
                          isAlert ? Icons.front_hand : Icons.check_circle_outline,
                          color: isAlert ? const Color(0xFFEF5350) : const Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          coach.coachNumber,
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
                          '\u2022 ${coach.todayCount}',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Details Grid
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorConstants.divider),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Coach No.', coach.coachNumber, showTopBorder: false),
                        _buildDetailRow('Technical ID', coach.sensorId),
                        if (coach.deviceId != 'N/A' && coach.deviceId.isNotEmpty)
                          _buildDetailRow('Device ID', coach.deviceId),
                        _buildDetailRow('Train No', coach.trainNo),
                        _buildDetailRow('Location', coach.location),
                        _buildDetailRow('TODAY COUNT', '${coach.todayCount}'),
                        _buildDetailRow('TOTAL COUNT', '${coach.totalCount}'),
                        _buildDetailRow(
                          'STATUS',
                          coach.statusLabel.toUpperCase(),
                          valueColor: coach.isChainPulled ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                        ),
                        _buildDetailRow(
                          'LAST TRIGGER',
                          _formatDatetime(coach.lastTrigger),
                          valueColor: coach.lastTrigger != null ? const Color(0xFFD32F2F) : null,
                        ),
                        _buildDetailRow('Last Updated', _formatDatetime(coach.updateTime)),
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AcpHistoryScreen(coach: coach)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
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