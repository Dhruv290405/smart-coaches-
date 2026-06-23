import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/widgets/configure_device.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/widgets/device_list.dart';

class DeviceConfigurationScreen extends StatefulWidget {
  const DeviceConfigurationScreen({super.key});

  @override
  State<DeviceConfigurationScreen> createState() =>
      _DeviceConfigurationScreenState();
}

class _DeviceConfigurationScreenState extends State<DeviceConfigurationScreen> {
  int selectedTab = 0;
  DeviceEntity? selectedDeviceItem;

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
          "Device Configuration",
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
                  selectedDeviceItem = null;
                  selectedTab = index;
                  setState(() {});
                },
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureDevice(
                        selectedDeviceItem: selectedDeviceItem,
                        onGoToListAndRefresh: () {
                          selectedTab = 1;
                          setState(
                            () {},
                          );
                        },
                      )
                    : DeviceList(
                        onTapEdit: (DeviceEntity device) {
                          selectedDeviceItem = device;
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
