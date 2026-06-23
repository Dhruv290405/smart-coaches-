import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/entities/alert_model.dart';
import 'package:intl/intl.dart';

class AlertsView extends StatelessWidget {
   AlertsView({super.key});

  final List<AlertModel> alerts = [
    AlertModel(
      status: 'Warning',
      title: 'Low Water Level',
      subtitle: 'Coach 203745 (1001553)',
      percentage: 60,
      dateTime: DateTime(2024, 6, 22, 9, 45),
    ),
    AlertModel(
      status: 'Critical',
      title: 'Low Water Level',
      subtitle: 'Coach 166332 (1001483)',
      percentage: 45,
      dateTime: DateTime(2024, 6, 22, 8, 30),
    ),
    AlertModel(
      status: 'Critical',
      title: 'Low Water Level',
      subtitle: 'Coach 203764 (1001629)',
      percentage: 40,
      dateTime: DateTime(2024, 6, 22, 8, 15),
    ),
  ];

   @override
   Widget build(BuildContext context) {
     return Padding(
       padding: EdgeInsets.all(4.w),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             'Recent Alerts',
             style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 12.sp,
               color: Colors.blueGrey.shade800,
             ),
           ),
           SizedBox(height: 2.h),
           ...alerts.map((e) => AlertCard(alert: e)),
         ],
       ),
     );
   }
}


class AlertCard extends StatelessWidget {
  final AlertModel alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final style = getAlertStyle(alert.status);
    final bgColor = style.color.withValues(alpha: 0.13);
    final formattedDate = DateFormat('dd MMM, hh:mm a').format(alert.dateTime);

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            style.icon,
            color: style.color,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.status}: ${alert.title}',
                  style: TextStyle(
                    color: style.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${alert.subtitle} - ${alert.percentage.toStringAsFixed(0)}% - $formattedDate',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
