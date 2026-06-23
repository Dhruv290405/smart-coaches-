import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class DeviceDetailDialog extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailDialog({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Device Details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              /// Field builder
              _buildItem(label: 'Short Name:', value: device.shortName),
              _buildItem(label: 'Full Name:', value: device.fullName),
              _buildItem(label: 'Data Type:', value: device.dataType),
              _buildItem(label: 'Number of Sensors:', value: (device.numberOfSensors ?? '').toString()),
              _buildItem(
                label: 'Sampling Frequency:',
                value: device.frequency != null && device.timeUnit != null
                    ? '${device.frequency} ${device.timeUnit}'
                    : null,
              ),
              _buildItem(
                  label: 'Status:',
                  value: DeviceStatusHelper.fromId(device.isActive).name),
              _buildItem(label: 'Last Updated:', value: device.updatedAt ?? device.createdAt),
              _buildItem(
                label: 'Description:',
                value: device.description,
                isMultiline: true,
              ),

              SizedBox(height: 3.h),

              /// Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Close',
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    textSize: 12,
                    radius: 6,
                    color: Color(0xFFF2F3F5),
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required String? value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 12.5.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
