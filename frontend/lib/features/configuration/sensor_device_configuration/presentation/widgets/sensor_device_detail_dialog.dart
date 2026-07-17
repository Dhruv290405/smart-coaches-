import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/screen_card_padding.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';

class SensorDeviceDetailDialog extends StatefulWidget {
  final SensorDeviceEntity sensorDeviceEntity;

  const SensorDeviceDetailDialog({super.key, required this.sensorDeviceEntity});

  @override
  State<SensorDeviceDetailDialog> createState() =>
      _SensorDeviceDetailDialogState();
}

class _SensorDeviceDetailDialogState extends State<SensorDeviceDetailDialog> {
  int selectedTab = 0;

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
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildToggleButtons(),
              SizedBox(height: 2.h),
              if (selectedTab == 0) _buildCoachInfoCard(),
              SizedBox(height: 2.h),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  text: 'Close',
                  padding:
                      EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                  textSize: 12,
                  radius: 6,
                  color: const Color(0xFFF2F3F5),
                  textColor: Colors.black,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'View Configuration Details',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, size: 18.sp, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    final List<String> tabs = ['View All', 'Select Device', 'Select Sensor'];

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedTab == index;
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: CustomButton(
              text: tabs[index],
              padding: EdgeInsets.symmetric(vertical: 1.6.h),
              textSize: 12,
              radius: 6,
              color: isSelected ? ColorConstants.primary : Colors.white,
              textColor: isSelected ? Colors.white : Colors.black,
              onPressed: () {
                selectedTab = index;
                setState(() {});
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCoachInfoCard() {
    final entity = widget.sensorDeviceEntity;

    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Coach Information",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTwoCols("Coach ID", entity.coachUniqueId?.toString(), "Master Module",
              entity.moduleUniqueId?.toString()),
          _buildTwoCols("Total Devices", entity.totalDevicesAttached.toString(),
              "Sensor ID", entity.noOfSensors.toString()),
        ],
      ),
    );
  }


  Widget _buildTwoCols(
      String label1, String? value1, String label2, String? value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildItem(label: label1, value: value1)),
        SizedBox(width: 3.w),
        Expanded(child: _buildItem(label: label2, value: value2)),
      ],
    );
  }

  Widget _buildItem({
    required String label,
    required String? value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
          SizedBox(height: 0.3.h),
          Text(value ?? 'N/A',
              style: TextStyle(fontSize: 12.5.sp, color: Colors.black)),
        ],
      ),
    );
  }

  String _formatDateTime(String? datetime) {
    return Utils.formatReadableDate(datetime,
            dateFormat: Constants.dateTimeFormatToShowInTable) ??
        '';
  }
}
