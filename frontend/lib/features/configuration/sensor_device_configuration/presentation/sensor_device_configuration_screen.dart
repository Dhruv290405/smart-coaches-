import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/export_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart';
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

  Future<void> _exportSensorDeviceList() async {
    final state = context.read<SensorDeviceConfigurationBloc>().state;
    final devices = state.sensorDeviceList;
    if (devices.isEmpty) return;
    final data = devices.map((d) => {
      'Device ID': d.deviceUniqueId ?? '',
      'Sensor Type': d.sensorTypeName ?? '',
      'Master Module': d.moduleUniqueId ?? '',
      'Status': d.isActive == true ? 'Active' : 'Inactive',
      'Created At': d.createdAt ?? '',
      'Updated At': d.updatedAt ?? '',
    }).toList();
    final path = await ExportUtils.exportToCsv(data, 'Sensor_Device_List');
    if (path.isNotEmpty) {
      await Share.shareXFiles([XFile(path)]);
    }
  }

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
                        onPressed: _exportSensorDeviceList,
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
