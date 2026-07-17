import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import 'hams_device_card.dart';

class HamsAxleModal extends StatelessWidget {
  final HamsDataModel data;
  const HamsAxleModal({super.key, required this.data});

  bool get isAlert => data.status.toLowerCase() == 'high';

  @override
  Widget build(BuildContext context) {
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
                  isAlert ? 'High Temperature Alert' : 'Device Status',
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
                              'Device ${data.deviceId}',
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
                              '\u2022 ${data.status.toUpperCase()}',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection('Device Info', [
                        _buildDetailRow('Device ID', data.deviceId, showTopBorder: false),
                        _buildDetailRow('Master ID', data.masterId),
                        _buildDetailRow('Temperature', '${data.temperature.toStringAsFixed(1)}°C'),
                        _buildDetailRow('Temp State', data.tempState),
                        _buildDetailRow('Status', data.status),
                        _buildDetailRow('Battery', '${data.batteryStatus} (${data.batteryVoltage.toStringAsFixed(2)}V)'),
                        _buildDetailRow('Timestamp', _formatTimestamp(data.receivedTimestamp)),
                      ]),
                      const SizedBox(height: 24),
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

  static String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(normalized).toLocal());
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
