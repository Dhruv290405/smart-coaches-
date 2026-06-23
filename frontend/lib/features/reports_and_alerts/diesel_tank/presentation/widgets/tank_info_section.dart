import 'package:flutter/material.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/info_row.dart';
import 'package:smart_coach_new/core/widgets/loco_badge.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/models/diesel_tank_model.dart';


class TankInfoSection extends StatelessWidget {
  final String title;
  final DieselTankModel tank;

  const TankInfoSection({
    super.key,
    required this.title,
    required this.tank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.header2),
              const LocoBadge(),
            ],
          ),
          const SizedBox(height: 16),
          InfoRow(label: 'Engine ID', value: tank.engineId),
          InfoRow(label: 'Sensor ID', value: tank.sensorId),
          InfoRow(label: 'Height', value: '${tank.height.toInt()} cm'),
          InfoRow(label: 'Width', value: '${tank.width.toInt()} cm'),
          InfoRow(label: 'Length', value: '${tank.length.toInt()} cm'),
          InfoRow(label: 'Capacity', value: '${tank.capacity} Litres'),
          InfoRow(
              label: 'Consumption Rate',
              value: '${tank.consumptionRate}L/hr'),
          InfoRow(
              label: 'Estimated Run Time',
              value: '${tank.estimatedRunTime}Hours'),
          InfoRow(label: 'Range Left', value: '${tank.rangeLeft}Km'),
          InfoRow(label: 'Last Updated', value: tank.getFormattedDate()),
          InfoRow(
              label: 'Refilled By', value: tank.refilledBy, isLast: true),
        ],
      ),
    );
  }
}
