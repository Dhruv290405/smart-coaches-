import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';

class SensorTypeDetailDialog extends StatelessWidget {
  final SensorTypeEntity sensorItem;

  const SensorTypeDetailDialog({super.key, required this.sensorItem});

  @override
  Widget build(BuildContext context) {
    List<String> deviceNames = sensorItem.devicesNames ?? [];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sensor Type Details',
                    style: TextStyle(
                      fontSize: 14.sp,
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
              _buildItem(
                  label: 'Sensor Type ID',
                  value: (sensorItem.sensorTypeId ?? '0').toString()),
              _buildItem(label: 'Sensor Type Name', value: sensorItem.sensorTypeName),
              _buildItem(
                label: 'Description',
                value: sensorItem.description,
              ),
              _buildItem(label: 'Name', value: sensorItem.name),
              _buildItem(label: 'Category', value: sensorItem.category?.name),
              if (deviceNames.isNotEmpty)
                Text(
                  'Applicable Devices',
                  style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                ),
              if (deviceNames.isNotEmpty)
                SizedBox(height: 0.6.h),
              if (deviceNames.isNotEmpty)
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: deviceNames.map((device) {
                    return _chipView(device, Colors.grey.shade200, Colors.black);
                  }).toList(),
                ),
              SizedBox(height: 1.5.h),
              _buildItem(
                  label: 'Value Format', value: sensorItem.valueFormat),
              SizedBox(height: 1.h),
              Text(
                'Default SI Unit',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 0.5.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: (sensorItem.unitsNames ?? []).map((unit) {
                  return _chipView(unit, Colors.grey.shade200, Colors.black);
                }).toList(),
              ),
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                        label: 'Min Expected Value',
                        value: sensorItem.minExpectedValue?.toString()),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildItem(
                        label: 'Max Expected Value',
                        value: sensorItem.maxExpectedValue?.toString()),
                  ),
                ],
              ),

              /// Frequency & Time Unit
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                        label: 'Sampling Frequency',
                        value: (sensorItem.samplingFrequency ?? '').toString()),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildItem(
                        label: 'Time Unit', value: sensorItem.timeInterval),
                  ),
                ],
              ),
              _buildItem(
                label: 'Status',
                value: DeviceStatusHelper.fromBool(sensorItem.isActive).name,
                isStatusView: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      label: 'Created At',
                      value: _formatDateTime(sensorItem.createdAt),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildItem(
                      label: 'Updated At',
                      value: _formatDateTime(sensorItem.updatedAt),
                    ),
                  ),
                ],
              ),

              /// Created & Updated By
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      label: 'Created By',
                      value: sensorItem.createdBy,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildItem(
                      label: 'Updated By',
                      value: sensorItem.updatedBy,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),
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
    bool isStatusView = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 0.3.h),
          isStatusView
              ? _buildStatusView(label: label, statusValue: value)
              : Text(
                  value ?? 'N/A',
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.black),
                ),
        ],
      ),
    );
  }

  String _formatDateTime(String? datetime) {
    return Utils.formatReadableDate(datetime, dateFormat: Constants.dateTimeFormatToShowInTable) ?? '';
  }

  Widget _buildStatusView(
      {required String label, required String? statusValue}) {
    bool isActive =
        statusValue?.toLowerCase() == DeviceStatus.active.name.toLowerCase();
    bool isPending =
        statusValue?.toLowerCase() == DeviceStatus.pending.name.toLowerCase();
    bool isInActive =
        statusValue?.toLowerCase() == DeviceStatus.inactive.name.toLowerCase();
    Color color = Colors.black;

    if (isActive) {
      color = Colors.green;
    } else if (isPending) {
      color = Colors.red.shade900;
    } else if (isInActive) {
      color = Color(0xFFC0AF6A);
    }
    return _chipView(statusValue, color.withValues(alpha: 0.13), color);
  }

  Widget _chipView(String? text, Color bgColor, Color textColor) {
    return ChipView(
      text: text,
      bgColor: bgColor,
      textColor: textColor,
    );
  }
}
