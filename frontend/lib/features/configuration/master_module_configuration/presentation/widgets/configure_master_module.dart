import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_multi_select_field.dart';
import 'package:smart_coach_new/core/widgets/custom_switch.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/positive_integer_input_formatter.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart' hide CoachEntity;
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/widgets/configure_rule.dart';

class ConfigureMasterModule extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final MasterModuleEntity? selectedMasterModuleItem;

  const ConfigureMasterModule(
      {super.key,
      required this.onGoToListAndRefresh,
      this.selectedMasterModuleItem});

  @override
  State<ConfigureMasterModule> createState() => _ConfigureMasterModuleState();
}

class _ConfigureMasterModuleState extends State<ConfigureMasterModule> {
  late MasterModuleConfigurationBloc _masterModuleConfigurationBloc;
  final TextEditingController moduleIdController = TextEditingController();
  final TextEditingController makeModelController = TextEditingController();
  final TextEditingController firmwareVersionController =
      TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController installationDateController =
      TextEditingController();
  final TextEditingController simNumberController = TextEditingController();
  final TextEditingController activationDateController =
      TextEditingController();
  final TextEditingController rechargeDateController = TextEditingController();
  final TextEditingController batteryRechargeDateController =
      TextEditingController();
  final TextEditingController batteryReplacementDateController =
      TextEditingController();
  final TextEditingController batteryCapacityController =
      TextEditingController();

  int? selectedCoachId;
  String? selectedLocation;
  String? selectedPlacementType;
  String? selectedProviderPrimary;
  String? selectedProviderSecondary;
  String? selectedSimStatus;
  String? selectedBatteryType;

  bool isDualProfileSupported = false;
  bool isLoraEnabled = false;
  bool isESimEnabled = false;

  List<String> selectedApplicableDevices = [];

  @override
  void dispose() {
    moduleIdController.dispose();
    makeModelController.dispose();
    firmwareVersionController.dispose();
    serialNumberController.dispose();
    installationDateController.dispose();
    simNumberController.dispose();
    activationDateController.dispose();
    rechargeDateController.dispose();
    batteryRechargeDateController.dispose();
    batteryReplacementDateController.dispose();
    batteryCapacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toString();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _masterModuleConfigurationBloc =
        context.read<MasterModuleConfigurationBloc>()..add(LoadInitialData());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedMasterModuleItem;
    if (item == null) return;
    selectedCoachId = item.coach?.coachId;
    moduleIdController.text = item.moduleUniqueId ?? '';
    makeModelController.text = item.makeModel ?? '';
    firmwareVersionController.text = item.firmwareVersion ?? '';
    serialNumberController.text = item.serialNumber ?? '';
    installationDateController.text = item.installationDate ?? '';
    selectedLocation = item.location;
    selectedPlacementType = item.placementType;
    simNumberController.text = item.simNo ?? '';
    isESimEnabled = item.esimEnabled ?? false;
    isDualProfileSupported = item.dualProfileSupported ?? false;
    selectedProviderPrimary = item.serviceProviderPrimary;
    selectedProviderSecondary = item.serviceProviderSecondary;
    activationDateController.text = item.activationDate ?? '';
    rechargeDateController.text = item.rechargeDate ?? '';
    selectedSimStatus = item.simStatus;
    selectedApplicableDevices =
        (item.devices ?? []).map((d) => d.deviceId!).toList();
    batteryReplacementDateController.text = item.batteryReplacementDate ?? '';
    batteryRechargeDateController.text = item.batteryRechargeDate ?? '';
    batteryCapacityController.text = item.batteryCapacity?.toString() ?? '';
    selectedBatteryType = item.batteryType;
    isLoraEnabled = item.loraEnabled ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: BlocConsumer<MasterModuleConfigurationBloc,
            MasterModuleConfigurationState>(
          listener: (context, state) {
            if (state.isLoading) {
              Loader.show();
            } else {
              Loader.dismiss();
            }

            if (state.actionMessage != null) {
              ToastMessageUtils.showMessage(context, state.actionMessage!);
              widget.onGoToListAndRefresh.call();
            }

            if (state.errorMessage != null) {
              Utils.showApiErrorMessageOrList(context,
                  message: state.errorMessage!);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module Information',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                CustomDropDown<CoachEntity>(
                  label: 'Coach Number',
                  hintText: 'Select Coach Number',
                  value: selectedCoachId,
                  items: state.coachList,
                  getValue: (e) => e.coachId,
                  displayText: (e) => e.coachUniqueId ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedCoachId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: moduleIdController,
                  labelText: 'Master Module Technical No',
                  hintText: 'Enter Module ID',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),

                /// Make/Model
                CustomTextField(
                  controller: makeModelController,
                  labelText: 'Make/Model',
                  hintText: 'Enter Make/Model',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),

                /// Firmware Version
                CustomTextField(
                  controller: firmwareVersionController,
                  labelText: 'Firmware Version',
                  hintText: 'Enter Firmware version',
                ),
                SizedBox(height: 2.h),

                /// Serial Number
                CustomTextField(
                  controller: serialNumberController,
                  labelText: 'Serial Number',
                  hintText: 'Enter serial number',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),

                /// Installation Date (with calendar icon tap)
                GestureDetector(
                  onTap: () => _selectDate(installationDateController),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      // controller: installationDateController,
                      controller: TextEditingController(
                          text: _displayFormatText(installationDateController)),
                      labelText: 'Installation Date',
                      hintText: 'dd-mm-yyyy',
                      isRequired: true,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Location',
                  hintText: 'Select Location',
                  value: selectedLocation,
                  isRequired: true,
                  items: Constants.locationList,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Placement Type',
                  hintText: 'Select placement type',
                  value: selectedPlacementType,
                  isRequired: true,
                  items: Constants.placementTypeList,
                  onChanged: (value) {
                    setState(() {
                      selectedPlacementType = value;
                    });
                  },
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'SIM Details',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                CustomSwitch(
                  text: 'E-Sim Enabled',
                  value: isESimEnabled,
                  onChanged: (value) {
                    setState(() {
                      isESimEnabled = value;
                      if (!value) {
                        isDualProfileSupported = false;
                        selectedProviderPrimary = null;
                        selectedProviderSecondary = null;
                      }
                    });
                  },
                ),
                if (isESimEnabled) SizedBox(height: 1.h),
                if (isESimEnabled)
                  CustomSwitch(
                    text: 'Dual Profile Supported',
                    value: isDualProfileSupported,
                    onChanged: (value) {
                      setState(() {
                        isDualProfileSupported = value;
                        if (!value) {
                          selectedProviderSecondary = null;
                        }
                      });
                    },
                  ),
                SizedBox(height: 1.h),
                CustomDropDown<String>(
                  label: 'Service Provider Primary',
                  hintText: 'Select Service Provider Primary',
                  value: selectedProviderPrimary,
                  items: Constants.serviceProviderList,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedProviderPrimary = value;
                    });
                  },
                ),
                if (isDualProfileSupported) SizedBox(height: 2.h),
                if (isDualProfileSupported)
                  CustomDropDown<String>(
                    label: 'Service Provider Secondary',
                    hintText: 'Select Service Provider Secondary',
                    value: selectedProviderSecondary,
                    items: Constants.serviceProviderList,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        selectedProviderSecondary = value;
                      });
                    },
                  ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: simNumberController,
                  labelText: 'SIM Number',
                  hintText: 'Enter SIM Number',
                  isRequired: true,
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () => _selectDate(activationDateController),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: TextEditingController(
                          text: _displayFormatText(activationDateController)),
                      labelText: 'Activation Date',
                      hintText: 'dd-mm-yyyy',
                      isRequired: true,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () => _selectDate(rechargeDateController),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      // controller: rechargeDateController,
                      controller: TextEditingController(
                          text: _displayFormatText(rechargeDateController)),
                      labelText: 'Recharge Date',
                      hintText: 'dd-mm-yyyy',
                      isRequired: true,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'SIM Status',
                  hintText: 'Select SIM Status',
                  value: selectedSimStatus,
                  items: Constants.simStatusList,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedSimStatus = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                Text(
                  'Device Attachment',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                CustomMultiSelectField<DeviceEntity, String>(
                  label: 'Device(s)',
                  title: 'Select Devices',
                  hintText: 'Select device',
                  items: state.deviceList,
                  selectedItems: selectedApplicableDevices,
                  isRequired: true,
                  onSelectionDone: (newSelected) {
                    selectedApplicableDevices = newSelected;
                    setState(() {});
                  },
                  itemIdBuilder: (d) => d.deviceId ?? '',
                  itemLabelBuilder: (d) => (d.fullName != null && d.fullName!.isNotEmpty)
                      ? d.fullName!
                      : (d.shortName != null && d.shortName!.isNotEmpty)
                          ? d.shortName!
                          : d.deviceUniqueId ?? '---',
                ),
                SizedBox(height: 1.h),
                _buildChips(
                    state.deviceList
                        .where((device) =>
                            selectedApplicableDevices.contains(device.deviceId))
                        .map((device) =>
                            ChipModel(device.deviceId, device.fullName))
                        .toList(), (ChipModel item) {
                  selectedApplicableDevices.removeWhere((ee) {
                    return ee == item.id;
                  });
                  setState(() {});
                }),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => _selectDate(batteryReplacementDateController),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      // controller: batteryReplacementDateController,
                      controller: TextEditingController(
                          text: _displayFormatText(
                              batteryReplacementDateController)),
                      labelText: 'Battery Replacement Date',
                      hintText: 'dd-mm-yyyy',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => _selectDate(batteryRechargeDateController),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      // controller: batteryRechargeDateController,
                      controller: TextEditingController(
                          text: _displayFormatText(
                              batteryRechargeDateController)),
                      labelText: 'Battery Recharge Date',
                      hintText: 'dd-mm-yyyy',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                CustomTextField(
                  controller: batteryCapacityController,
                  labelText: 'Battery Capacity',
                  hintText: 'Enter Battery Capacity',
                  isRequired: true,
                  textInputType: TextInputType.number,
                  inputFormatters: [PositiveIntegerInputFormatter()],
                ),
                SizedBox(height: 1.h),
                CustomDropDown<String>(
                  label: 'Battery Type',
                  hintText: 'Select Battery Type',
                  value: selectedBatteryType,
                  items: Constants.batteryTypeList,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedBatteryType = value;
                    });
                  },
                ),
                SizedBox(height: 1.h),
                CustomSwitch(
                  text: 'Lora Enabled',
                  value: isLoraEnabled,
                  onChanged: (value) => setState(() => isLoraEnabled = value),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'Cancel',
                      color: const Color(0xFFF2F3F5),
                      textColor: Colors.black,
                      textSize: 12,
                      padding: EdgeInsets.symmetric(
                          vertical: 1.6.h, horizontal: 5.w),
                      radius: 6,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 3.w),
                    CustomButton(
                      text: 'Save Module',
                      textSize: 12,
                      radius: 6,
                      padding: EdgeInsets.symmetric(
                          vertical: 1.6.h, horizontal: 5.w),
                      onPressed: () {
                        _doProcess();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _doProcess() {
    if (!_doValidate()) return;

    final request = MasterModuleConfigurationRequest(
      coachId: selectedCoachId,
      moduleUniqueId: moduleIdController.text.trim(),
      makeModel: makeModelController.text.trim(),
      firmwareVersion: firmwareVersionController.text.trim(),
      serielNumber: serialNumberController.text.trim(),
      installationDate: installationDateController.text.trim(),
      location: selectedLocation,
      placementType: selectedPlacementType,
      simNo: simNumberController.text.trim(),
      rechargeDate: rechargeDateController.text.trim(),
      serviceProviderPrimary: selectedProviderPrimary,
      serviceProviderSecondary: selectedProviderSecondary,
      activationDate: activationDateController.text.trim(),
      simStatus: selectedSimStatus,
      batteryReplacementDate: batteryReplacementDateController.text.trim(),
      dualProfileSupported: isDualProfileSupported,
      loraEnabled: isLoraEnabled,
      esimEnabled: isESimEnabled,
      batteryCapacity: int.tryParse(batteryCapacityController.text.trim()) ?? 0,
      batteryType: selectedBatteryType,
      batteryRechargeDate: batteryRechargeDateController.text.trim(),
      deviceIds: selectedApplicableDevices,
    );

    _masterModuleConfigurationBloc.add(
      CreateEditMasterModuleConfiguration(
        request,
        moduleId: widget.selectedMasterModuleItem?.moduleId,
      ),
    );
  }

  bool _doValidate() {
    if (selectedCoachId == null) {
      ToastMessageUtils.showMessage(context, 'Please select Coach ID');
      return false;
    } else if (moduleIdController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Master Module ID');
      return false;
    } else if (makeModelController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Make/Model');
      return false;
    } else if (serialNumberController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Serial Number');
      return false;
    } else if (installationDateController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select Installation Date');
      return false;
    } else if (selectedLocation == null) {
      ToastMessageUtils.showMessage(context, 'Please select Location');
      return false;
    } else if (selectedPlacementType == null) {
      ToastMessageUtils.showMessage(context, 'Please select Placement Type');
      return false;
    } else if (simNumberController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter SIM Number');
      return false;
    } else if (selectedProviderPrimary == null) {
      ToastMessageUtils.showMessage(
          context, 'Please select SIM Provider Primary');
      return false;
    } else if (isDualProfileSupported && selectedProviderSecondary == null) {
      ToastMessageUtils.showMessage(
          context, 'Please select SIM Provider Secondary');
      return false;
    } else if (activationDateController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select Activation Date');
      return false;
    } else if (rechargeDateController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select Recharge Date');
      return false;
    } else if (batteryCapacityController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter battery capacity');
      return false;
    } else if (selectedSimStatus == null) {
      ToastMessageUtils.showMessage(context, 'Please select SIM Status');
      return false;
    } else if (selectedBatteryType == null) {
      ToastMessageUtils.showMessage(context, 'Please select battery type');
      return false;
    } else if (selectedApplicableDevices.isEmpty) {
      ToastMessageUtils.showMessage(
          context, 'Please attach at least one device');
      return false;
    }
    return true;
  }

  Widget _buildChips(List<ChipModel> items, Function(ChipModel) onRemove) {
    if (items.isEmpty) return SizedBox.shrink();
    return Wrap(
      spacing: 1.w,
      runSpacing: 0.8.h,
      children: items.map((item) {
        return ChipView(
          text: item.name,
          bgColor: Color(0xFFE6F3FF),
          textColor: Color(0xFF007BFF),
          isRemovable: true,
          onRemove: () {
            onRemove.call(item);
          },
        );
      }).toList(),
    );
  }

  String _displayFormatText(TextEditingController activationDateController) {
    if (activationDateController.text.trim().isEmpty) {
      return '';
    }
    return Utils.formatReadableDate(activationDateController.text.trim()) ?? '';
  }
}
