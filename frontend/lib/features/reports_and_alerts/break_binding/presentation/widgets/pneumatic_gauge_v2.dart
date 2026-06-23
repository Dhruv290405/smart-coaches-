import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PneumaticGauge extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double maxValue;
  final Color accentColor;

  const PneumaticGauge({
    super.key,
    required this.label,
    required this.value,
    this.unit = "KG/CM²",
    this.maxValue = 6.0,
    this.accentColor = const Color(0xFF1A9DF8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 85,
            height: 85,
            child: CustomPaint(
              painter: GaugePainter(
                value: value,
                maxValue: maxValue,
                accentColor: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == "BP" ? "BRAKE PIPE" : 
            label == "FP" ? "FEED PIPE" :
            label == "BC" ? "BRAKE CYLINDER" : "CONTROL RES.",
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color accentColor;

  GaugePainter({
    required this.value,
    required this.maxValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );
    
    // ... rest of GaugePainter ...
    final valuePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          accentColor.withOpacity(0.5),
          accentColor,
        ],
        startAngle: pi * 0.75,
        endAngle: pi * 2.25,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / maxValue).clamp(0.0, 1.0) * pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi * 0.75,
      sweepAngle,
      false,
      valuePaint,
    );

    // Ticks
    final tickPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 6; i++) {
      final angle = pi * 0.75 + (i / 6) * pi * 1.5;
      final start = Offset(
        center.dx + (radius - 12) * cos(angle),
        center.dy + (radius - 12) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 4) * cos(angle),
        center.dy + (radius - 4) * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Needle
    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final needleAngle = pi * 0.75 + (value / maxValue).clamp(0.0, 1.0) * pi * 1.5;
    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(needleAngle),
      center.dy + (radius - 20) * sin(needleAngle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // Needle Center
    canvas.drawCircle(center, 4, Paint()..color = Colors.black);
    canvas.drawCircle(center, 2, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
