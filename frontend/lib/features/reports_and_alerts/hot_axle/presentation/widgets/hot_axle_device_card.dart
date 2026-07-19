import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class HotAxleDeviceCard extends StatefulWidget {
  final HotAxleCoachModel coach;
  final int sequenceNumber;
  final VoidCallback? onTap;

  const HotAxleDeviceCard({
    super.key,
    required this.coach,
    required this.sequenceNumber,
    this.onTap,
  });

  @override
  State<HotAxleDeviceCard> createState() => _HotAxleDeviceCardState();
}

class _HotAxleDeviceCardState extends State<HotAxleDeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;
  double _previousTemp = 0;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gaugeAnimation = Tween<double>(begin: 0, end: widget.coach.maxTemp)
        .animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic));
    _gaugeController.forward();
  }

  @override
  void didUpdateWidget(covariant HotAxleDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coach.maxTemp != widget.coach.maxTemp) {
      _previousTemp = oldWidget.coach.maxTemp;
      _gaugeAnimation = Tween<double>(
        begin: _previousTemp,
        end: widget.coach.maxTemp,
      ).animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic));
      _gaugeController.reset();
      _gaugeController.forward();
    }
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  Color _getTempColor(double temp) {
    if (temp > 80) return const Color(0xFFE53935);
    if (temp > 60) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return const Color(0xFF4CAF50);
      case 'warning': return const Color(0xFFFF9800);
      case 'critical': return const Color(0xFFE53935);
      default: return Colors.grey;
    }
  }

  IconData _getBatteryIcon(int level) {
    if (level <= 0) return Icons.battery_unknown;
    if (level <= 15) return Icons.battery_1_bar;
    if (level <= 30) return Icons.battery_2_bar;
    if (level <= 50) return Icons.battery_3_bar;
    if (level <= 70) return Icons.battery_4_bar;
    if (level <= 90) return Icons.battery_5_bar;
    return Icons.battery_full;
  }

  Color _getBatteryColor(int level) {
    if (level <= 15) return const Color(0xFFE53935);
    if (level <= 30) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  String _formatLastSeen(String ts) {
    if (ts.isEmpty) return 'N/A';
    try {
      final normalized = ts.contains('T') ? ts : ts.replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized).toLocal();
      return DateFormat('hh:mm:ss a').format(dt);
    } catch (_) {
      return ts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;
    final tempColor = _getTempColor(coach.maxTemp);
    final statusColor = _getStatusColor(coach.status);
    final online = coach.signalStrength > 0;
    final deviceNumber = coach.coachNumber.isNotEmpty ? coach.coachNumber : coach.deviceId;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(deviceNumber, coach, statusColor, online),
                  const SizedBox(height: 8),
                  _buildGaugeSection(),
                  const SizedBox(height: 8),
                  _buildInfoSection(coach, online),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String deviceNumber, HotAxleCoachModel coach, Color statusColor, bool online) {
    final shortId = deviceNumber.startsWith('Master:')
        ? coach.deviceId
        : deviceNumber;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              shortId.length > 3 ? shortId.substring(shortId.length - 3) : shortId,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                coach.coachNumber.isNotEmpty ? coach.coachNumber : 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1D21),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'Device: ${coach.deviceId}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (coach.trainNo.isNotEmpty)
                Text(
                  'Train: ${coach.trainNo}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
        Flexible(
          flex: 0,
          child: _buildStatusBadge(coach.status, statusColor),
        ),
        const SizedBox(width: 4),
        Icon(
          online ? Icons.wifi : Icons.wifi_off,
          size: 14,
          color: online ? const Color(0xFF4CAF50) : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGaugeSection() {
    return AnimatedBuilder(
      animation: _gaugeAnimation,
      builder: (context, child) {
        final currentTemp = _gaugeAnimation.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${currentTemp.toStringAsFixed(1)}°C',
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: _getTempColor(currentTemp),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Temperature',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 48,
              child: CustomPaint(
                size: Size(double.infinity, 48),
                painter: _SemiCircleGaugePainter(
                  value: currentTemp,
                  maxValue: 120,
                  color: _getTempColor(currentTemp),
                  backgroundColor: const Color(0xFFF0F2F5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(HotAxleCoachModel coach, bool online) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(
          Icons.circle,
          'Status',
          coach.status,
          _getStatusColor(coach.status),
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          _getBatteryIcon(coach.batteryPercentage),
          'Battery',
          '${coach.batteryPercentage}%',
          _getBatteryColor(coach.batteryPercentage),
        ),
        const SizedBox(height: 4),
        if (coach.technicalId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildInfoRow(
              Icons.qr_code,
              'Tech ID',
              coach.technicalId,
              const Color(0xFF6B7280),
            ),
          ),
        const SizedBox(height: 4),
        _buildInfoRow(
          Icons.access_time,
          'Last Seen',
          _formatLastSeen(coach.timestamp),
          online ? const Color(0xFF4CAF50) : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 12, color: valueColor),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D21),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SemiCircleGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;
  final Color backgroundColor;

  _SemiCircleGaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final arcHeight = size.height;
    final arcWidth = size.width;
    final radius = (arcWidth / 2).clamp(16.0, arcHeight * 0.85);
    final center = Offset(arcWidth / 2, arcHeight);
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    final valuePaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: [
          const Color(0xFF4CAF50),
          const Color(0xFFFF9800),
          const Color(0xFFE53935),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fraction = (value / maxValue).clamp(0.0, 1.0);
    final sweepAngle = pi * fraction;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      valuePaint,
    );

    final tickPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;

    for (int i = 0; i <= 12; i++) {
      final angle = pi + (pi * i / 12);
      final outerPoint = Offset(
        center.dx + (radius + strokeWidth / 2 + 3) * cos(angle),
        center.dy + (radius + strokeWidth / 2 + 3) * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius + strokeWidth / 2) * cos(angle),
        center.dy + (radius + strokeWidth / 2) * sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
