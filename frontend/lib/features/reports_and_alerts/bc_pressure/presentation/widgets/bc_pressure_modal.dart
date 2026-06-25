import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../../../../core/utils/device_id_mapper.dart';
import '../../data/models/bc_pressure_model.dart';

class BCPressureModal extends StatelessWidget {
  final BCPressureModel coach;
  const BCPressureModal({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final latest = coach.latestReading;
    final statusColor = _getStatusColor(coach.status);
    
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
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  'BC Pressure Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: statusColor
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
                              color: statusColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            child: Icon(
                              Icons.compress,
                              color: statusColor,
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
                          _buildStatusBadge(coach.status, statusColor),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Latest Reading
                      if (latest != null) ...[
                        _buildInfoSection('Latest Reading', [
                          _buildDetailRow('Pressure', '${latest.currentPressure} kg/cm²', showTopBorder: false),
                          _buildDetailRow('Charging Time', '${latest.chargingTime}s'),
                          _buildDetailRow('Discharging Time', '${latest.dischargingTime}s'),
                          _buildDetailRow('Response Time', '${latest.brakeResponseTime}s'),
                          _buildDetailRow('Applied At', _formatTimestamp(latest.brakeAppliedTime)),
                          _buildDetailRow('Released At', _formatTimestamp(latest.brakeReleasedTime)),
                        ]),
                        const SizedBox(height: 24),
                        _buildInfoSection('Metadata', [
                          _buildDetailRow('Technical No', DeviceIdMapper.resolve(coach.deviceId), showTopBorder: false),
                          _buildDetailRow('Coach Type', coach.coachType),
                          _buildDetailRow('Train Number', coach.trainNumber),
                          _buildDetailRow('Railway', coach.owningRly),
                          _buildDetailRow('Battery', '${latest.batteryPercentage}%'),
                          _buildDetailRow('Signal', '${latest.signalStrength}%'),
                        ]),
                      ] else 
                        const Center(child: Text('No readings available')),

                      const SizedBox(height: 24),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default: return ColorConstants.iconGrey;
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

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
