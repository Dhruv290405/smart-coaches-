import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/device_id_mapper.dart';
import '../../data/models/acp_model.dart';

class AcpCoachCard extends StatelessWidget {
  final AcpCoachModel coach;
  final VoidCallback? onEyeIconTap;

  const AcpCoachCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRecent = coach.isRecent;
    final isPulled = coach.isChainPulled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: !isRecent ? ColorConstants.cardBackground : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: !isRecent
            ? Border.all(color: ColorConstants.divider.withValues(alpha: 0.5), width: 1)
            : Border.all(color: Colors.red.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach: ${coach.coachNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                    Text(
                      'Technical No: ${DeviceIdMapper.resolve(coach.sensorId)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                    Text(
                      'Device ID: ${coach.deviceId}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textTertiary,
                ),
              ),
              _PulledToggle(isPulled: isPulled),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Count: ${coach.todayCount}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Total: ${coach.totalCount}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondary,
                ),
              ),
              if (coach.updateTime != 'N/A') ...[
                const Spacer(),
                Text(
                  'Updated: ${coach.updateTime}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PulledToggle extends StatefulWidget {
  final bool isPulled;
  const _PulledToggle({required this.isPulled});

  @override
  State<_PulledToggle> createState() => _PulledToggleState();
}

class _PulledToggleState extends State<_PulledToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _position = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.isPulled) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_PulledToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulled != oldWidget.isPulled) {
      widget.isPulled ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: Color.lerp(
              const Color(0xFFD32F2F),
              const Color(0xFF2E7D32),
              _position.value,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                width: 24,
                child: Opacity(
                  opacity: 1 - _position.value,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                width: 24,
                child: Opacity(
                  opacity: _position.value,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ON',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 32 - _position.value * 30,
                top: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

