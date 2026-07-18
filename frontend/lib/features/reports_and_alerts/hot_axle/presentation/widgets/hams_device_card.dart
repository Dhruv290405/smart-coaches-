import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HamsDataModel {
  final int id;
  final String deviceId;
  final String masterId;
  final double temperature;
  final String status;
  final String tempState;
  final String receivedTimestamp;
  final String batteryStatus;
  final double batteryVoltage;

  HamsDataModel({
    required this.id,
    required this.deviceId,
    required this.masterId,
    required this.temperature,
    required this.status,
    required this.tempState,
    required this.receivedTimestamp,
    required this.batteryStatus,
    required this.batteryVoltage,
  });

  factory HamsDataModel.fromJson(Map<String, dynamic> json) {
    return HamsDataModel(
      id: json['id'] ?? 0,
      deviceId: json['device_id']?.toString() ?? '',
      masterId: json['master_id']?.toString() ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'Low',
      tempState: json['temp_state']?.toString() ?? 'Normal',
      receivedTimestamp: json['received_timestamp']?.toString() ?? '',
      batteryStatus: json['battery_status']?.toString() ?? 'Low',
      batteryVoltage: (json['battery_voltage'] ?? 0.0).toDouble(),
    );
  }
}

class HamsDeviceCard extends StatefulWidget {
  final HamsDataModel data;
  final int sequenceNumber;
  final VoidCallback? onTap;

  const HamsDeviceCard({
    super.key,
    required this.data,
    required this.sequenceNumber,
    this.onTap,
  });

  @override
  State<HamsDeviceCard> createState() => _HamsDeviceCardState();
}

class _HamsDeviceCardState extends State<HamsDeviceCard>
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
    _gaugeAnimation = Tween<double>(begin: 0, end: widget.data.temperature)
        .animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic));
    _gaugeController.forward();
  }

  @override
  void didUpdateWidget(covariant HamsDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.temperature != widget.data.temperature) {
      _previousTemp = oldWidget.data.temperature;
      _gaugeAnimation = Tween<double>(
        begin: _previousTemp,
        end: widget.data.temperature,
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

  Color _tempColor(double temp) {
    if (temp > 80) return const Color(0xFFE53935);
    if (temp > 60) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'high': return const Color(0xFFE53935);
      case 'moderate': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  Color _batColor(String bat) {
    switch (bat.toLowerCase()) {
      case 'low': return const Color(0xFFE53935);
      case 'moderate': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
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
    final tempC = _tempColor(widget.data.temperature);
    final tColor = _statusColor(widget.data.tempState);
    final bColor = _batColor(widget.data.batteryStatus);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(tColor),
              const SizedBox(height: 8),
              _buildGaugeSection(tempC),
              const SizedBox(height: 8),
              _buildInfoSection(tColor, bColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text('${widget.sequenceNumber}',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Device: ${widget.data.deviceId}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D21)),
                overflow: TextOverflow.ellipsis, maxLines: 1),
              Text('Master: ${widget.data.masterId}',
                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(widget.data.status.toUpperCase(),
            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildGaugeSection(Color tempColor) {
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
                fontSize: 21, fontWeight: FontWeight.w700, color: _tempColor(currentTemp)),
            ),
            const SizedBox(height: 1),
            Text(
              'Temperature',
              style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 48,
              child: CustomPaint(
                size: const Size(double.infinity, 48),
                painter: _SemiCircleGaugePainter(
                  value: currentTemp,
                  maxValue: 120,
                  color: _tempColor(currentTemp),
                  backgroundColor: const Color(0xFFF0F2F5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(Color tColor, Color bColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _infoRow(Icons.thermostat, 'State', widget.data.tempState, tColor),
        const SizedBox(height: 4),
        _infoRow(Icons.battery_std, 'Battery', '${widget.data.batteryStatus} (${widget.data.batteryVoltage.toStringAsFixed(2)}V)', bColor),
        const SizedBox(height: 4),
        _infoRow(Icons.access_time, 'Last Seen', _formatLastSeen(widget.data.receivedTimestamp),
          widget.data.batteryStatus.toLowerCase() == 'low' ? const Color(0xFFE53935) : const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Text('$label: ',
                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
              Flexible(
                child: Text(value,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D21)),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
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
      pi, pi, false, bgPaint,
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
      pi, sweepAngle, false, valuePaint,
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