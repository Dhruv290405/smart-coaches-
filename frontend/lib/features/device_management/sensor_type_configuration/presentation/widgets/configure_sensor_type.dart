import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_multi_select_field.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/negative_integer_input_formatter.dart';
import 'package:smart_coach_new/core/widgets/positive_integer_input_formatter.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_state.dart';

class ConfigureSensorType extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final SensorTypeEntity? selectedSensorItem;

  const ConfigureSensorType(
      {super.key, required this.onGoToListAndRefresh, this.selectedSensorItem});

  @override
  State<ConfigureSensorType> createState() => _ConfigureSensorTypeState();
}

class _ConfigureSensorTypeState extends State<ConfigureSensorType> {
  late SensorTypeConfigurationBloc _sensorTypeConfigurationBloc;

  final TextEditingController sensorTypeNameController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController minExpectedValueController =
      TextEditingController();
  final TextEditingController maxExpectedValueController =
      TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  List<String> selectedApplicableDevices = [];
  int? selectedCategoryId;

  String? selectedValueFormat;
  List<int> selectedDefaultSiUnit = [];
  String? selectedTimeUnit;
  bool isActive = true;

  @override
  void dispose() {
    sensorTypeNameController.dispose();
    fullNameController.dispose();
    descriptionController.dispose();
    minExpectedValueController.dispose();
    maxExpectedValueController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sensorTypeConfigurationBloc = context.read<SensorTypeConfigurationBloc>();
    _sensorTypeConfigurationBloc.add(LoadDeviceConfigurationList());
    _sensorTypeConfigurationBloc.add(LoadSensorCategories());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedSensorItem;
    if (item != null) {
      // Text fields
      sensorTypeNameController.text = item.sensorTypeName ?? '';
      fullNameController.text = item.name ?? '';
      descriptionController.text = item.description ?? '';
      minExpectedValueController.text = item.minExpectedValue?.toString() ?? '';
      maxExpectedValueController.text = item.maxExpectedValue?.toString() ?? '';
      frequencyController.text = item.samplingFrequency?.toString() ?? '';

      // Category
      selectedCategoryId = item.category?.id;

      // Also optionally: trigger loading units for selected category
      if (selectedCategoryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sensorTypeConfigurationBloc
              .add(LoadSensorCategorySiUnits(selectedCategoryId));
        });
      }

      // Value format (String dropdown)
      if (Utils.isValidDropDownSelectedItem(
          Constants.valueFormats, item.valueFormat)) {
        selectedValueFormat = item.valueFormat;
      }

      // Time unit (String dropdown)
      if (Utils.isValidDropDownSelectedItem(
          Constants.evaluationUnitValues, item.timeInterval)) {
        selectedTimeUnit = item.timeInterval;
      }

      // Is active (bool)
      isActive = item.isActive ?? true;

      // Applicable devices (IDs)
      selectedApplicableDevices = item.devices
              ?.map((device) => device.deviceId)
              .whereType<String>()
              .toList() ??
          [];

      // SI units (IDs)
      selectedDefaultSiUnit = item.units
              ?.map((unit) => unit.unitId ?? -1)
              .where((id) => id != -1)
              .toList() ??
          [];


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
        child: BlocConsumer<SensorTypeConfigurationBloc,
            SensorTypeConfigurationState>(
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
                  'Sensor Type Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                CustomMultiSelectField<DeviceEntity, String>(
                  label: 'Applicable Devices',
                  isRequired: true,
                  title: 'Select Devices',
                  hintText: 'Select device',
                  items: state.deviceList,
                  selectedItems: selectedApplicableDevices,
                  onSelectionDone: (newSelected) {
                    setState(() {
                      selectedApplicableDevices = newSelected;
                    });
                  },
                  itemIdBuilder: (d) => d.deviceId ?? '',
                  itemLabelBuilder: (d) => (d.fullName != null && d.fullName!.isNotEmpty)
                      ? d.fullName!
                      : (d.shortName != null && d.shortName!.isNotEmpty)
                          ? d.shortName!
                          : d.deviceUniqueId ?? '---',
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: sensorTypeNameController,
                  labelText: 'Sensor Type Name',
                  hintText: 'Enter sensor type name',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: fullNameController,
                  labelText: 'Full Name',
                  hintText: 'Max 50 characters',
                  isRequired: true,
                  maxLength: 50,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: descriptionController,
                  labelText: 'Description',
                  hintText: 'Enter device description',
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Value Format',
                  hintText: 'Select value format',
                  value: selectedValueFormat,
                  isRequired: true,
                  items: Constants.valueFormats,
                  onChanged: (value) {
                    setState(() {
                      selectedValueFormat = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<SensorCategoryEntity>(
                  label: 'Value Type/Category',
                  hintText: 'Select here',
                  value: selectedCategoryId,
                  items: state.sensorCategoriesList,
                  getValue: (e) => e.id,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                      _sensorTypeConfigurationBloc
                          .add(LoadSensorCategorySiUnits(selectedCategoryId));
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomMultiSelectField<SiUnitEntity, int>(
                  label: 'Default SI Unit',
                  isRequired: true,
                  title: 'Select si unit',
                  hintText: 'Select si unit',
                  items: state.sensorCategorySiUnitList,
                  selectedItems: selectedDefaultSiUnit,
                  onSelectionDone: (newSelected) {
                    setState(() {
                      selectedDefaultSiUnit = newSelected;
                    });
                  },
                  itemIdBuilder: (d) => d.id ?? -1,
                  itemLabelBuilder: (d) => d.unit ?? '',
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: minExpectedValueController,
                        labelText: 'Min Expected Value',
                        hintText: 'Enter min expected value',
                        textInputType:
                            TextInputType.numberWithOptions(signed: true),
                        inputFormatters: [NegativeIntegerInputFormatter()],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: CustomTextField(
                        controller: maxExpectedValueController,
                        labelText: 'Max Expected Value',
                        hintText: 'Enter max expected value',
                        textInputType:
                            TextInputType.numberWithOptions(signed: true),
                        inputFormatters: [NegativeIntegerInputFormatter()],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: frequencyController,
                        labelText: 'Sampling Frequency (s)',
                        hintText: 'Enter frequency',
                        isRequired: true,
                        textInputType: TextInputType.number,
                        inputFormatters: [PositiveIntegerInputFormatter()],
                      ),
                    ),
                    SizedBox(width: 3.w),
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
                      padding: EdgeInsets.symmetric(
                          vertical: 1.6.h, horizontal: 5.w),
                      radius: 6,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    SizedBox(width: 3.w),
                    CustomButton(
                      text: 'Save',
                      padding: EdgeInsets.symmetric(
                          vertical: 1.6.h, horizontal: 5.w),
                      textSize: 12,
                      radius: 6,
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
    String sensorTypeName = sensorTypeNameController.text.trim();
    String fullName = fullNameController.text.trim();
    String minExpectedValue = minExpectedValueController.text.trim();
    String maxExpectedValue = maxExpectedValueController.text.trim();
    String frequency = frequencyController.text.trim();

    if (_doValidate(sensorTypeName, fullName, frequency)) {
      final request = SensorTypeConfigurationRequest(
        sensorTypeName: sensorTypeName,
        category: selectedCategoryId,
        name: fullName,
        description: descriptionController.text.trim(),
        valueFormat: selectedValueFormat,
        minExpectedValue:
            minExpectedValue.isNotEmpty ? int.parse(minExpectedValue) : null,
        maxExpectedValue:
            maxExpectedValue.isNotEmpty ? int.parse(maxExpectedValue) : null,
        samplingFrequency:
            frequency.isNotEmpty ? double.parse(frequency) : null,
        timeInterval: selectedTimeUnit,
        isActive: isActive,
        unitIds: selectedDefaultSiUnit,
        deviceIds: selectedApplicableDevices,
      );

      _sensorTypeConfigurationBloc.add(CreateEditSensorTypeConfiguration(
          request,
          sensorId: widget.selectedSensorItem?.sensorTypeId));
    }
  }

  bool _doValidate(String sensorTypeName, String fullName, String frequency) {
    if (selectedApplicableDevices.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select applicable device');
      return false;
    } else if (sensorTypeName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter sensor type name');
      return false;
    } else if (fullName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter full name');
      return false;
    } else if (selectedValueFormat == null) {
      ToastMessageUtils.showMessage(context, 'Please select value format');
      return false;
    } else if (selectedCategoryId == null) {
      ToastMessageUtils.showMessage(context, 'Please select category id');
      return false;
    } else if (selectedDefaultSiUnit.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select SI unit');
      return false;
    } else if (frequency.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter sampling frequency');
      return false;
    } else if (selectedTimeUnit == null) {
      ToastMessageUtils.showMessage(context, 'Please select time unit');
      return false;
    } else {
      return true;
    }
  }
}
