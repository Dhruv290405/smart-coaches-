import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_state.dart';

class ConfigureDevice extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final DeviceEntity? selectedDeviceItem;

  const ConfigureDevice(
      {super.key, required this.onGoToListAndRefresh, this.selectedDeviceItem});

  @override
  State<ConfigureDevice> createState() => _ConfigureDeviceState();
}

class _ConfigureDeviceState extends State<ConfigureDevice> {
  late DeviceConfigurationBloc _deviceConfigurationBloc;

  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController shortNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  bool isActive = true;
  String? selectedDataType;
  String? selectedTimeUnit;
  int? selectedMaxSensors;

  List<int> maxSensorsValues = List.generate(99, (index) => index + 1);

  @override
  void dispose() {
    deviceIdController.dispose();
    shortNameController.dispose();
    fullNameController.dispose();
    descriptionController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _deviceConfigurationBloc = context.read<DeviceConfigurationBloc>();
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedDeviceItem;
    if (item != null) {
      deviceIdController.text = (item.deviceUniqueId ?? '').toString();
      shortNameController.text = item.shortName ?? '';
      fullNameController.text = item.fullName ?? '';
      descriptionController.text = item.description ?? '';
      frequencyController.text = (item.frequency ?? '').toString();

      if (Utils.isValidDropDownSelectedItem(
          maxSensorsValues, item.numberOfSensors)) {
        selectedMaxSensors = item.numberOfSensors;
      }

      if (Utils.isValidDropDownSelectedItem(Constants.valueFormats, item.dataType)) {
        selectedDataType = item.dataType;
      }
      if (Utils.isValidDropDownSelectedItem(Constants.evaluationUnitValues, item.timeUnit)) {
        selectedTimeUnit = item.timeUnit;
      }
      isActive = item.isActive == 1;
    }
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
        child: BlocListener<DeviceConfigurationBloc, DeviceConfigurationState>(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: deviceIdController,
                labelText: 'Device ID',
                hintText: 'Enter Device ID',
                isRequired: true,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: shortNameController,
                labelText: 'Short Name',
                hintText: 'Max 10 characters',
                isRequired: true,
                maxLength: 10,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: fullNameController,
                labelText: 'Full Name',
                hintText: 'Max 100 characters',
                isRequired: true,
                maxLength: 100,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Enter device description',
                maxLines: 4,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 2.h),
              CustomDropDown<String>(
                label: 'Data Type',
                hintText: 'Select Type',
                value: selectedDataType,
                items: Constants.valueFormats,
                onChanged: (value) {
                  if (selectedDataType != value) {
                    selectedDataType = value;
                    if (isRequiredSamplingFrequency() == false) {
                      frequencyController.text = '';
                    }
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 2.h),
              CustomDropDown<int>(
                label: 'Max Sensors',
                hintText: 'Select no. of max sensors',
                value: selectedMaxSensors,
                items: maxSensorsValues,
                isRequired: true,
                onChanged: (value) {
                  if (selectedMaxSensors != value) {
                    selectedMaxSensors = value;
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  if (isRequiredSamplingFrequency())
                    Expanded(
                      child: CustomTextField(
                        controller: frequencyController,
                        labelText: 'Sampling Frequency',
                        hintText: 'Enter frequency',
                        isRequired: true,
                        textInputType: TextInputType.number,
                      ),
                    ),
                  if (isRequiredSamplingFrequency()) SizedBox(width: 3.w),
                  Expanded(
                    child: CustomDropDown<String>(
                      label: 'Time Unit',
                      hintText: 'Select Unit',
                      value: selectedTimeUnit,
                      items: Constants.evaluationUnitValues,
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          selectedTimeUnit = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Is Active',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                    child: Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    color: Color(0xFFF2F3F5),
                    textColor: Colors.black,
                    textSize: 12,
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    radius: 6,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  SizedBox(width: 3.w),
                  CustomButton(
                    text: 'Save',
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    textSize: 12,
                    radius: 6,
                    onPressed: () {
                      _doProcess();
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

  void _doProcess() {
    String deviceId = deviceIdController.text.trim();
    String shortName = shortNameController.text.trim();
    String fullName = fullNameController.text.trim();
    String frequency = frequencyController.text.trim();

    if (_doValidate(deviceId, shortName, fullName, frequency)) {
      final request = DeviceConfigurationRequest(
        deviceUniqueId: deviceId,
        dataType: selectedDataType,
        timeUnit: selectedTimeUnit,
        description: descriptionController.text.trim(),
        isActive: isActive,
        frequency: frequency.isNotEmpty ? double.parse(frequency) : null,
        fullName: fullName,
        shortName: shortName,
        numberOfSensors: selectedMaxSensors,
      );

      _deviceConfigurationBloc.add(CreateEditDeviceConfiguration(request,
          deviceId: widget.selectedDeviceItem?.deviceId));
    }
  }

  bool _doValidate(
      String deviceId, String shortName, String fullName, String frequency) {
    if (deviceId.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter device id');
      return false;
    } else if (shortName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter short name');
      return false;
    } else if (fullName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter full name');
      return false;
    } else if (selectedMaxSensors == null) {
      ToastMessageUtils.showMessage(context, 'Please select number of sensors');
      return false;
    } else if (isRequiredSamplingFrequency() && frequency.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter sampling frequency');
      return false;
    } else if (selectedTimeUnit == null) {
      ToastMessageUtils.showMessage(context, 'Please select time unit');
      return false;
    } else {
      return true;
    }
  }

  bool isRequiredSamplingFrequency() {
    return selectedDataType == DataTypes.number.name ||
        selectedDataType == DataTypes.decimal.name;
  }
}
