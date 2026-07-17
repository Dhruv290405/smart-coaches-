import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/screen_card_padding.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

class SensorFormModel {
  String? sensorId;
  int? sensorMakeId;
  DateTime? installDate;
  String? placement;
  String? location;
  String? remarks;

  SensorFormModel({
    this.sensorId,
    this.sensorMakeId,
    DateTime? installDate,
    this.placement,
    this.location,
    this.remarks,
  }) : installDate = installDate ?? DateTime.now();

  bool isValid() {
    return sensorId?.isNotEmpty == true &&
        sensorMakeId != null &&
        installDate != null &&
        placement?.isNotEmpty == true;
  }
}

class ConfigureSensorDevice extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final SensorDeviceEntity? selectedSensorDeviceItem;

  const ConfigureSensorDevice({
    super.key,
    required this.onGoToListAndRefresh,
    this.selectedSensorDeviceItem,
  });

  @override
  State<ConfigureSensorDevice> createState() => _ConfigureSensorDeviceState();
}

class _ConfigureSensorDeviceState extends State<ConfigureSensorDevice> {
  late SensorDeviceConfigurationBloc _sensorDeviceConfigurationBloc;

  CoachEntity? selectedCoach;
  int? selectedMasterModuleId;
  String? selectedDevicesId;

  bool showDeviceSection = false;
  bool showSensorSection = false;

  void _loadDevices() {
    if (selectedCoach != null && selectedMasterModuleId != null) {
      setState(() {
        _sensorDeviceConfigurationBloc.add(LoadDeviceListData());
        showDeviceSection = true;
      });
    }
  }

  Future<void> _showCoachSearchDialog() async {
    final state = _sensorDeviceConfigurationBloc.state;
    final coaches = state.coachList;
    if (coaches.isEmpty) return;
    final selected = await showDialog<CoachEntity>(
      context: context,
      builder: (ctx) => _SearchableSelectionDialog(
        title: 'Select Coach',
        items: coaches,
        displayText: (e) => e.coachUniqueId ?? '',
        searchFilter: (e, q) => (e.coachUniqueId ?? '').toLowerCase().contains(q.toLowerCase()),
      ),
    );
    if (selected != null) {
      setState(() {
        selectedCoach = selected;
        selectedMasterModuleId = null;
        selectedDevicesId = null;
        showDeviceSection = false;
        showSensorSection = false;
      });
      final coachId = selected.coachId is int
          ? selected.coachId as int
          : int.tryParse(selected.coachId?.toString() ?? '');
      if (coachId != null) {
        _sensorDeviceConfigurationBloc.add(LoadMasterModulesForCoach(coachId));
      } else {
        Utils.showApiErrorMessageOrList(context, message: 'Invalid coach ID format');
      }
    }
  }

  Future<void> _showMasterModuleSearchDialog() async {
    final state = _sensorDeviceConfigurationBloc.state;
    final modules = state.masterModuleList;
    if (modules.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'No master modules found for this coach'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final selected = await showDialog<MasterModuleEntity>(
      context: context,
      builder: (ctx) => _SearchableSelectionDialog(
        title: 'Select Master Module',
        items: modules,
        displayText: (e) => e.moduleUniqueId ?? '',
        searchFilter: (e, q) => (e.moduleUniqueId ?? '').toLowerCase().contains(q.toLowerCase()),
      ),
    );
    if (selected != null) {
      setState(() {
        selectedMasterModuleId = selected.moduleId;
        showDeviceSection = false;
      });
    }
  }

  int sensorCount = 1;
  List<SensorFormModel> sensorForms = [SensorFormModel()];

  final List<String> placementOptions = ['Internal', 'External'];

  void updateSensorCount(int count) {
    setState(() {
      sensorCount = count;
      sensorForms = List.generate(
        count,
        (index) =>
            index < sensorForms.length ? sensorForms[index] : SensorFormModel(),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sensorDeviceConfigurationBloc =
        context.read<SensorDeviceConfigurationBloc>()..add(LoadInitialData());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedSensorDeviceItem;
    if (item == null) return;
    setState(() {
      selectedMasterModuleId = item.masterModuleId;
      selectedDevicesId = item.deviceId;

      showDeviceSection =
          selectedMasterModuleId != null && selectedCoach != null;
      showSensorSection = selectedDevicesId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:
          BlocConsumer<
            SensorDeviceConfigurationBloc,
            SensorDeviceConfigurationState>( listener: (context, state) {
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
                Utils.showApiErrorMessageOrList(
                  context,
                  message: state.errorMessage!,
                );
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _coachModuleView(state),
                  SizedBox(height: 2.h),
                  _deviceView(state),
                  SizedBox(height: 2.h),
                  if (showSensorSection) _sensorsView(state),
                  if (showSensorSection) SizedBox(height: 2.h),
                  if (showSensorSection)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          color: const Color(0xFFF2F3F5),
                          textColor: Colors.black,
                          textSize: 12,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.6.h,
                            horizontal: 5.w,
                          ),
                          radius: 6,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 3.w),
                        CustomButton(
                          text: 'Save Sensors',
                          textSize: 12,
                          radius: 6,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.6.h,
                            horizontal: 5.w,
                          ),
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
    );
  }

  void _doProcess() {
    if (!_doValidate()) return;

    Utils.showYesNoDialog(
      context: context,
      message: Constants.saveSensorConfirmationMessage,
      title: Constants.confirmSave,
      onYes: () {
        final request = SensorDeviceConfigurationRequest(
          coachId: selectedCoach?.coachId,
          masterModuleId: selectedMasterModuleId,
          deviceId: selectedDevicesId,
          sensors: sensorForms
              .map(
                (form) => SensorRequest(
                  sensorId: form.sensorId,
                  sensorMakeId: form.sensorMakeId,
                  installDate: form.installDate.toString(),
                  placement: form.placement,
                  location: form.location,
                  remarks: form.remarks,
                ),
              )
              .toList(),
        );

        _sensorDeviceConfigurationBloc.add(
          CreateEditSensorDeviceConfiguration(
            request,
            sensorId: widget.selectedSensorDeviceItem?.coachId,
          ),
        );
      },
    );
  }

  bool _doValidate() {
    for (int i = 0; i < sensorCount; i++) {
      final form = sensorForms[i];
      final sensorNumber = i + 1;

      if (form.sensorId?.isEmpty ?? true) {
        ToastMessageUtils.showMessage(
          context,
          'Please enter Sensor ID in Sensor $sensorNumber',
        );
        return false;
      }
      if (form.sensorMakeId == null) {
        ToastMessageUtils.showMessage(
          context,
          'Please select Make in Sensor $sensorNumber',
        );
        return false;
      }
      if (form.installDate == null) {
        ToastMessageUtils.showMessage(
          context,
          'Please select Install Date in Sensor $sensorNumber',
        );
        return false;
      }
      if (form.placement?.isEmpty ?? true) {
        ToastMessageUtils.showMessage(
          context,
          'Please enter Placement in Sensor $sensorNumber',
        );
        return false;
      }
    }
    return true;
  }

  Widget _buildStatusView(String? deviceName, DeviceStatus deviceStatus) {
    bool isActive =
        deviceStatus.name.toLowerCase() ==
        DeviceStatus.active.name.toLowerCase();
    bool isInActive =
        deviceStatus.name.toLowerCase() ==
        DeviceStatus.inactive.name.toLowerCase();
    Color color = Colors.grey;
    Color textColor = Colors.black;

    if (isActive) {
      color = Colors.green.withValues(alpha: 0.13);
      textColor = Colors.green;
    } else if (isInActive) {
      color = Colors.red.withValues(alpha: 0.13);
      textColor = Colors.red;
    }
    final statusLabel = isActive ? 'Online' : 'Offline';
    return _chipView(
      getStatusIcon(deviceStatus),
      '${(deviceName != null && deviceName.isNotEmpty) ? deviceName : '---'} ($statusLabel)',
      color,
      textColor,
    );
  }

  IconData getStatusIcon(DeviceStatus status) {
    if (status == DeviceStatus.active) {
      return Icons.check_circle_outline;
    } else if (status == DeviceStatus.inactive) {
      return Icons.remove_circle_outline;
    } else {
      return Icons.help_outline;
    }
  }

  Widget _chipView(
    IconData icon,
    String? text,
    Color bgColor,
    Color textColor,
  ) {
    return ChipView(
      text: text,
      icon: icon,
      bgColor: bgColor,
      textColor: textColor,
    );
  }

  String _displayFormatText(String text) {
    if (text.trim().isEmpty) {
      return '';
    }
    return Utils.formatReadableDate(text.trim()) ?? '';
  }

  Widget _coachModuleView(SensorDeviceConfigurationState state) {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Coach & Module',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: _showCoachSearchDialog,
            child: AbsorbPointer(
              child: CustomTextField(
                labelText: 'Coach',
                hintText: 'Select Coach',
                isRequired: true,
                controller: TextEditingController(
                  text: selectedCoach?.coachUniqueId ?? '',
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: _showMasterModuleSearchDialog,
            child: AbsorbPointer(
              child: CustomTextField(
                labelText: 'Master Module',
                hintText: 'Select Master Module',
                isRequired: true,
                controller: TextEditingController(
                  text: state.masterModuleList
                      .where((m) => m.moduleId == selectedMasterModuleId)
                      .map((m) => m.moduleUniqueId ?? '')
                      .firstOrNull ?? '',
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          if (selectedCoach != null && selectedMasterModuleId != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Load Devices',
                    onPressed: _loadDevices,
                    textSize: 12,
                    radius: 6,
                    padding: EdgeInsets.symmetric(
                      vertical: 1.6.h,
                      horizontal: 5.w,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _deviceView(SensorDeviceConfigurationState state) {
    return ScreenCardPadding(
      color: showDeviceSection ? Colors.white : const Color(0xFFF5F5F5),
      child: AbsorbPointer(
        absorbing: !showDeviceSection,
        child: Opacity(
          opacity: showDeviceSection ? 1.0 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Device',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Device Configuration Status:',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: state.deviceList.map((device) {
                    return _buildStatusView(
                      (device.shortName != null && device.shortName!.isNotEmpty)
                          ? device.shortName
                          : (device.fullName != null && device.fullName!.isNotEmpty)
                              ? device.fullName
                              : device.deviceUniqueId ?? '---',
                      DeviceStatusHelper.fromId(device.isActive),
                    );
                }).toList(),
              ),
              SizedBox(height: 2.h),
              CustomDropDown<DeviceEntity>(
                label: 'Device',
                hintText: 'Select Device',
                value: selectedDevicesId,
                items: state.deviceList,
                getValue: (e) => e.deviceId,
                displayText: (e) => (e.shortName != null && e.shortName!.isNotEmpty)
                    ? e.shortName!
                    : (e.fullName != null && e.fullName!.isNotEmpty)
                        ? e.fullName!
                        : e.deviceUniqueId ?? '---',
                isRequired: true,
                onChanged: (value) {
                  setState(() {
                    selectedDevicesId = value;
                  });
                },
              ),
              SizedBox(height: 2.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Configure Sensors',
                    onPressed: () {
                      if (selectedDevicesId != null) {
                        showSensorSection = true;
                      }
                      setState(() {});
                    },
                    textSize: 12,
                    isDisabled: selectedDevicesId == null,
                    radius: 6,
                    padding: EdgeInsets.symmetric(
                      vertical: 1.6.h,
                      horizontal: 5.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorsView(SensorDeviceConfigurationState state) {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropDown<int>(
            label: 'Number of Sensors:',
            hintText: 'Select Number of Sensors:',
            value: sensorCount,
            isRequired: true,
            items: [1, 2, 3, 4],
            onChanged: (value) {
              updateSensorCount(value);
            },
          ),
          SizedBox(height: 2.h),
          ...List.generate(sensorCount, (index) {
            final SensorFormModel form = sensorForms[index];
            return Container(
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sensor ${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ID: SNS-${1815 + index + 1}',
                          style: TextStyle(
                            color: Color(0xFF545C67),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    labelText: 'Sensor ID',
                    isRequired: true,
                    hintText: 'Enter sensor ID',
                    onChanged: (val) => form.sensorId = val,
                  ),
                  SizedBox(height: 2.h),
                  CustomDropDown<SensorMakeItem>(
                    label: 'Make',
                    hintText: 'Select Make',
                    value: form.sensorMakeId,
                    items: state.sensorMakeList,
                    getValue: (e) => e.sensorMakeId,
                    displayText: (e) => e.name ?? '',
                    isRequired: true,
                    onChanged: (value) =>
                      setState(() =>
                        form.sensorMakeId = value
                      )
                  ),
                  SizedBox(height: 2.h),
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => form.installDate = picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: CustomTextField(
                        labelText: 'Install Date',
                        controller: TextEditingController(
                          text: _displayFormatText(form.installDate.toString()),
                        ),
                        hintText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_today, size: 5.w),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomDropDown<String>(
                    label: 'Placement',
                    isRequired: true,
                    hintText: 'Select Placement',
                    items: placementOptions,
                    value: form.placement,
                    onChanged: (val) => setState(() => form.placement = val),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    labelText: 'Location',
                    hintText: 'e.g. Front panel, Rear axle',
                    onChanged: (val) => form.location = val,
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    labelText: 'Remarks',
                    hintText: 'Any additional notes',
                    onChanged: (val) => form.remarks = val,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SearchableSelectionDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayText;
  final bool Function(T, String) searchFilter;

  const _SearchableSelectionDialog({
    required this.title,
    required this.items,
    required this.displayText,
    required this.searchFilter,
  });

  @override
  State<_SearchableSelectionDialog<T>> createState() => _SearchableSelectionDialogState<T>();
}

class _SearchableSelectionDialogState<T> extends State<_SearchableSelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
                contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              ),
              onChanged: (q) {
                setState(() {
                  _filteredItems = widget.items.where((e) => widget.searchFilter(e, q)).toList();
                });
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(widget.displayText(_filteredItems[i])),
                onTap: () => Navigator.pop(context, _filteredItems[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
