import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/widgets/water_tank_view.dart';

class WaterTankCard extends StatelessWidget {
  final WaterTank tank;

  const WaterTankCard({super.key, required this.tank});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.blue;
      case 'warning':
        return Colors.red;
      case 'critical':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getTankIcon() {
    if (tank.percentage >= 80) return Icons.water;
    if (tank.percentage >= 50) return Icons.water_drop;
    return Icons.water_damage_outlined;
  }

  Color get fillColor {
    if (tank.percentage >= 70) return Colors.blue;
    if (tank.percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  String get statusText {
    if (tank.percentage >= 70) return "Good";
    if (tank.percentage >= 40) return "Critical";
    return "Warning";
  }

  @override
  Widget build(BuildContext context) {
    double tankWidth = 14.w;
    double tankHeight = 10.h;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: tankWidth,
              height: tankHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: List.generate(4, (index) {
                  final y = (index + 1) * (tankHeight / 5);
                  return Positioned(
                    bottom: y,
                    left: 0,
                    right: 0,
                    child: Divider(
                      color: Colors.grey.shade400,
                      thickness: 0.6,
                      height: 0,
                    ),
                  );
                }),
              ),
            ),

            // Filled Level
            Container(
              width: tankWidth,
              height: tankHeight * (tank.percentage / 100),
              decoration: BoxDecoration(
                color: fillColor.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
            ),

            // Percentage Label
            const Positioned(
              top: 4,
              child: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 4,
              child: Text(
                "${tank.percentage.toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          tank.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
        ),
        Text(
          statusText,
          style: TextStyle(
            color: fillColor,
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
