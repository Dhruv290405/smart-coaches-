import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/configure_sensor_device.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/sensor_device_list.dart';

class SensorDeviceConfigurationScreen extends StatefulWidget {
  const SensorDeviceConfigurationScreen({super.key});

  @override
  State<SensorDeviceConfigurationScreen> createState() =>
      _SensorDeviceConfigurationScreenState();
}

class _SensorDeviceConfigurationScreenState extends State<SensorDeviceConfigurationScreen> {
  int selectedTab = 0;
  SensorDeviceEntity? selectedSensorDeviceItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Sensor Configuration",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.0.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomToggleButtons(
                        selectedIndex: selectedTab,
                        labels: const ['Configure', 'List'],
                        onTap: (index) {
                          selectedSensorDeviceItem = null;
                          selectedTab = index;
                          setState(() {});
                        },
                      ),
                    ),
                    if (selectedTab == 1)
                      SizedBox(
                        width: 4.w,
                      ),
                    if (selectedTab == 1)
                      CustomButton(
                        text: 'Export',
                        color: Colors.white,
                        textColor: Colors.black,
                        textSize: 12,
                        showBorder: true,
                        prefixIcon: Icons.download_outlined,
                        iconSize: 4,
                        padding: EdgeInsets.symmetric(
                          vertical: 1.3.h,
                          horizontal: 3.w,
                        ),
                        radius: 8,
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureSensorDevice(
                        selectedSensorDeviceItem: selectedSensorDeviceItem,
                        onGoToListAndRefresh: () {
                          selectedTab = 1;
                          setState(
                            () {},
                          );
                        },
                      )
                    : SensorDeviceList(
                        onTapEdit: (SensorDeviceEntity sensorDeviceEntity) {
                          selectedSensorDeviceItem = sensorDeviceEntity;
                          selectedTab = 0;
                          setState(() {});
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
