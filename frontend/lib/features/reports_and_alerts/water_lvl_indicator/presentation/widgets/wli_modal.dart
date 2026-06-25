import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/water_tank_model.dart';
import '../fulltank_history.dart';

class WliModal extends StatelessWidget {
  final WaterTankModel coach;
  const WliModal({super.key, required this.coach});

  bool get _isOverhead => coach.placement.type == 'OVERHEAD';

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Water Level Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
                            child: Icon(Icons.water_drop, color: statusColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coach.location.coachName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.primary,
                                  ),
                                ),
                                _buildPlacementBadge(),
                              ],
                            ),
                          ),
                          _buildStatusBadge(coach.status, statusColor),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sensor readings
                      _buildSensorSection(statusColor),
                      const SizedBox(height: 4),

                      // Placement info
                      _buildInfoSection('Tank Info', [
                        _buildDetailRow('Tank Type', coach.placement.type, showTopBorder: false),
                        _buildDetailRow('Sensor Count', '${coach.placement.sensorCount}'),
                        _buildDetailRow('Position', coach.placement.position.join(', ')),
                      ]),

                      // Metadata
                      _buildInfoSection('Device Info', [
                        _buildDetailRow('Device ID', coach.source.deviceId, showTopBorder: false),
                        _buildDetailRow('System', coach.source.systemType),
                        _buildDetailRow('Company', coach.source.companyName),
                        _buildDetailRow('Timestamp', _formatTimestamp(coach.timestamp)),
                      ]),

                      const SizedBox(height: 20),

                      // Buttons row: History + Close
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullTankHistory(coach: coach),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history, size: 16),
                              label: Text('History', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: ColorConstants.primary,
                                side: const BorderSide(color: ColorConstants.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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

  Widget _buildPlacementBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _isOverhead
            ? const Color(0xFF1A9DF8).withValues(alpha: 0.1)
            : const Color(0xFF059669).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _isOverhead ? 'OVERHEAD' : 'UNDERSLUNG',
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _isOverhead ? const Color(0xFF1A9DF8) : const Color(0xFF059669),
        ),
      ),
    );
  }

  Widget _buildSensorSection(Color statusColor) {
    if (!_isOverhead) {
      // Single sensor for underslung
      final asset = coach.assets.first;
      return _buildInfoSection(asset.assetName, [
        _buildDetailRow('Water Level', '${asset.percentFull.toStringAsFixed(1)}%', showTopBorder: false),
        _buildDetailRow('Volume', '${asset.volumeLiters.toStringAsFixed(1)} L'),
        _buildDetailRow('Level (cm)', '${asset.levelCm.toStringAsFixed(1)} cm'),
      ]);
    }

    return Column(
      children: coach.assets.map((asset) {
        final label = asset.assetName.contains('Front') ? 'Front End' : 'Rear End';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoSection(label, [
            _buildDetailRow('Water Level', '${asset.percentFull.toStringAsFixed(1)}%', showTopBorder: false),
            _buildDetailRow('Volume', '${asset.volumeLiters.toStringAsFixed(1)} L'),
            _buildDetailRow('Level (cm)', '${asset.levelCm.toStringAsFixed(1)} cm'),
          ]),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default: return Colors.grey;
    }
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.divider),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 12),
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