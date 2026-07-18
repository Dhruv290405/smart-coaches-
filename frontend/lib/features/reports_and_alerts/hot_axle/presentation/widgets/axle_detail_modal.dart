import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';


class AxleDetailModal extends StatelessWidget {
  final AxleModel axle;
  final VoidCallback? onHistoryTap;

  const AxleDetailModal({super.key, required this.axle, this.onHistoryTap});

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return ColorConstants.statusCritical;
      case 'critical':
        return ColorConstants.statusWarning;
      default:
        return ColorConstants.iconGrey;
    }
  }

  static String _getAxleIcon(String status) {
    switch (status.toLowerCase()) {
      case 'warning':
        return AppIcons.axelRed;
      case 'critical':
        return AppIcons.axelYellow;
      default:
        return AppIcons.axelBlue; // Good
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(axle.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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

          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Axle ${axle.axleNumber} Detailed Info',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: ColorConstants.divider),
          const SizedBox(height: 16),

          // Header: icon + name + temp + badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Axle icon with colored bg
                Container(
                  width: 34,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      _getAxleIcon(axle.status),
                      width: 22,
                      height: 11.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Axle name
                Text(
                  'Axle ${axle.axleNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primary,
                  ),
                ),

                const Spacer(),

                // Temperature
                Text(
                  axle.currentTemp,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        axle.status,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildDividerRow('Current Temp', axle.currentTemp),
                _buildDividerRow('Status', _getStatusLabel(axle.status)),
                _buildDividerRow('Sensor ID', axle.sensorId),
                _buildDividerRow('Speed', axle.speed),
                _buildDividerRow('Battery', '${axle.batteryStatus} (${axle.batteryVoltage.toStringAsFixed(1)}V)'),
                _buildDividerRow('Detected at', axle.detectedAt),
                _buildDividerRow('Location', axle.location),
                _buildDividerRow('Last maintenance', axle.lastMaintenance,
                    isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // View History button
          if (onHistoryTap != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onHistoryTap!();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorConstants.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 18, color: ColorConstants.primary),
                        const SizedBox(width: 8),
                        Text(
                          'View Full History',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'warning':
        return 'Critical Overheat';
      case 'critical':
        return 'Extreme Overheat';
      default:
        return 'Normal';
    }
  }

  Widget _buildDividerRow(String label, String value,
      {bool isLast = false}) {
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
}
