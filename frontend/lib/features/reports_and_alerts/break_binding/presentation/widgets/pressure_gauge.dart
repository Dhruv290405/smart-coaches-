import 'package:flutter/material.dart';

class PressureGauge extends StatefulWidget {
  final double value;
  final String label;
  final double maxValue;

  const PressureGauge({
    super.key,
    required this.value,
    required this.label,
    this.maxValue = 120,
  });

  @override
  State<PressureGauge> createState() => _PressureGaugeState();
}

class _PressureGaugeState extends State<PressureGauge> {
  double _oldValue = 0.0;

  @override
  void didUpdateWidget(covariant PressureGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _oldValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxBarHeight = (constraints.maxHeight) * 0.55;
      final clampedNew = widget.value.clamp(0.0, widget.maxValue);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _oldValue, end: clampedNew),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, animatedValue, child) {
              final fraction = (animatedValue / widget.maxValue).clamp(0.0, 1.0);
              final barHeight = fraction * maxBarHeight;

              return Container(
                width: 60,
                height: maxBarHeight,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red,
                      Colors.yellow,
                      Colors.green,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: barHeight,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "${clampedNew.toStringAsFixed(1)} PSI",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      );
    });
  }
}
