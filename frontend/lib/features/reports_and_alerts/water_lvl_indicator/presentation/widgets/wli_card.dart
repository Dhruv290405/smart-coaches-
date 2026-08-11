import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/water_tank_model.dart';

class WliCard extends StatelessWidget {
  final WaterTankModel coach;
  final VoidCallback? onEyeIconTap;

  const WliCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return const Color(0xFFBE8B22);
      case 'critical': return const Color(0xFFD32F2F);
      default: return Colors.grey;
    }
  }

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
    final level = coach.averagePercent;
    final isAlert = coach.status != 'Good';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? statusColor.withValues(alpha: 0.05) : ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? statusColor.withValues(alpha: 0.2) : ColorConstants.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.location.coachName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildPlacementBadge(),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                child: SvgPicture.asset(
                  AppIcons.eye,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isOverhead)
            _buildOverheadSensors(statusColor)
          else
            _buildSingleLevel(level, statusColor, isAlert),
          const SizedBox(height: 10),
          // Progress bar (average)
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConstants.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 6,
                    width: constraints.maxWidth * (level / 100),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _formatTimestamp(coach.timestamp),
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              _buildStatusBadge(coach.status, statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementBadge() {
    final isOverhead = _isOverhead;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverhead
            ? const Color(0xFF1A9DF8).withValues(alpha: 0.1)
            : const Color(0xFF059669).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOverhead ? 'OVERHEAD' : 'UNDERSLUNG',
        style: GoogleFonts.poppins(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: isOverhead ? const Color(0xFF1A9DF8) : const Color(0xFF059669),
        ),
      ),
    );
  }

  Widget _buildSingleLevel(double level, Color statusColor, bool isAlert) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Level',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '${level.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isAlert ? statusColor : ColorConstants.primary,
              ),
            ),
          ],
        ),
        if (coach.assets.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${coach.assets.first.volumeLiters.toStringAsFixed(1)} L',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.primary,
                ),
              ),
              Text(
                '${coach.assets.first.levelCm.toStringAsFixed(1)} cm',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOverheadSensors(Color statusColor) {
    return Row(
      children: coach.assets.map((asset) {
        final isCritical = asset.percentFull < 20;
        final isWarning = asset.percentFull < 40;
        final color = isCritical
            ? const Color(0xFFD32F2F)
            : isWarning
                ? const Color(0xFFBE8B22)
                : Colors.green;
        final label = asset.assetName.contains('Front') ? 'Front' : 'Rear';
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: asset == coach.assets.last ? 0 : 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
                  ),
                  Text(
                    '${asset.percentFull.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${asset.volumeLiters.toStringAsFixed(0)} L',
                    style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}