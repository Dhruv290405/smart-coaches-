import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/features/dashboard/domain/entities/dashboard_item.dart';

class CountsDataView extends StatelessWidget {
  final int totalTrains;
  final int smartCoaches;
  final int activeDevices;
  final int activeSensors;
  final int criticalAlerts;
  final int warnings;
  final int moderate;
  final int normalState;
  final int acpDeployed;

  const CountsDataView({
    super.key,
    required this.totalTrains,
    required this.smartCoaches,
    required this.activeDevices,
    required this.activeSensors,
    required this.criticalAlerts,
    required this.warnings,
    required this.moderate,
    required this.normalState,
    this.acpDeployed = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Total Trains',
        value: totalTrains.toString(),
        icon: Icons.train,
        color: Colors.blue,
      ),
      DashboardItem(
        title: 'Smart Coaches',
        value: smartCoaches.toString(),
        icon: Icons.directions_bus,
        color: Colors.purple,
      ),
      DashboardItem(
        title: 'Active Devices',
        value: activeDevices.toString(),
        icon: Icons.devices,
        color: Colors.green,
      ),
      DashboardItem(
        title: 'Active Sensors',
        value: activeSensors.toString(),
        icon: Icons.sensors,
        color: Colors.teal,
      ),
      DashboardItem(
        title: 'ACP Monitoring',
        value: acpDeployed.toString(),
        icon: Icons.security,
        color: Colors.indigo,
      ),
      DashboardItem(
        title: 'Critical Alerts',
        value: criticalAlerts.toString(),
        icon: Icons.error,
        color: Colors.red,
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Warnings',
        value: warnings.toString(),
        icon: Icons.warning_amber,
        color: Colors.orange,
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Moderate',
        value: moderate.toString(),
        icon: Icons.error_outline,
        color: const Color(0xFFC0AF6A),
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Normal State',
        value: normalState.toString(),
        icon: Icons.check_circle_outline,
        color: Colors.green,
        showTextInColor: true,
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      items[index].title,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: items[index].color.withOpacity(0.13),
                    ),
                    child: Icon(items[index].icon,
                        color: items[index].color, size: 13.sp),
                  ),
                ],
              ),
              Text(
                items[index].value,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: items[index].showTextInColor
                      ? items[index].color
                      : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}