import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/widgets/configure_sensor_type.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/widgets/sensor_type_list.dart';

class SensorTypeConfigurationScreen extends StatefulWidget {
  const SensorTypeConfigurationScreen({super.key});

  @override
  State<SensorTypeConfigurationScreen> createState() =>
      _SensorTypeConfigurationScreenState();
}

class _SensorTypeConfigurationScreenState
    extends State<SensorTypeConfigurationScreen> {
  int selectedTab = 0;
  SensorTypeEntity? selectedSensorItem;

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
          "Sensor Type Configuration",
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
              CustomToggleButtons(
                selectedIndex: selectedTab,
                labels: const ['Configure', 'List'],
                onTap: (index) {
                  selectedSensorItem = null;
                  selectedTab = index;
                  setState(() {});
                },
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureSensorType(
                        selectedSensorItem: selectedSensorItem,
                        onGoToListAndRefresh: () {
                          selectedTab = 1;
                          setState(
                            () {},
                          );
                        },
                      )
                    : SensorTypeList(
                        onTapEdit: (SensorTypeEntity device) {
                          selectedSensorItem = device;
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
