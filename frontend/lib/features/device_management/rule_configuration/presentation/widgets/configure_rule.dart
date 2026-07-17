import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_multi_select_field.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/screen_card_padding.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/condition_block_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/sub_condition_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_message_template_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

class ChipModel {
  dynamic id;
  String? name;

  ChipModel(this.id, this.name);
}

class SubCondition {
  String? operator;
  String? threshold;
  TextEditingController? thresholdTextEditingController;
  String? connector;
  int? sortOrder;

  SubCondition({this.operator, this.threshold, this.connector, this.sortOrder}) {
    thresholdTextEditingController = TextEditingController(text: threshold?.trim() ?? '');
  }
  void dispose() {
    thresholdTextEditingController?.dispose();
  }
}

class ConditionBlockModel {
  int? valueTypeId;
  String? valueFormat;
  String? siUnit;
  int? siUnitId;
  String? operator;
  String? threshold;
  TextEditingController? thresholdTextEditingController;
  String? connector;
  List<SubCondition> subConditions = [];
  int? alertType;
  String? alertMessageTemplate;
  TextEditingController? alertMessageTemplateTextEditingController;
  String? alertDescription;
  TextEditingController? alertDescriptionTemplateTextEditingController;

  ConditionBlockModel({
    this.valueTypeId,
    this.valueFormat,
    this.siUnit,
    this.siUnitId,
    this.operator,
    this.threshold,
    this.thresholdTextEditingController,
    this.alertMessageTemplate,
    this.alertDescription,
    this.connector,
    this.alertType,
    List<SubCondition>? subConditions,
  }) : subConditions = subConditions ?? [] {
    thresholdTextEditingController = TextEditingController(text: threshold?.trim() ?? '');
    alertMessageTemplateTextEditingController = TextEditingController(text: alertMessageTemplate?.trim() ?? '');
    alertDescriptionTemplateTextEditingController = TextEditingController(text: alertDescription?.trim() ?? '');
  }

  void dispose() {
    thresholdTextEditingController?.dispose();
    alertMessageTemplateTextEditingController?.dispose();
    alertDescriptionTemplateTextEditingController?.dispose();
    for (final sub in subConditions) {
      sub.dispose();
    }
  }
}

class ConfigureRule extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final RuleConfigurationEntity? selectedRuleItem;

  const ConfigureRule(
      {super.key, required this.onGoToListAndRefresh, this.selectedRuleItem});

  @override
  State<ConfigureRule> createState() => _ConfigureRuleState();
}

class _ConfigureRuleState extends State<ConfigureRule> {
  late RuleConfigurationBloc _ruleConfigurationBloc;

  final TextEditingController ruleNameController = TextEditingController();
  final TextEditingController evaluationFrequencyController =
      TextEditingController();

  List<String> selectedApplicableDevices = [];

  List<int> selectedSensorType = [];

  List<ConditionBlockModel> conditions = [ConditionBlockModel()];

  String? selectedEvaluationUnit;

  bool isActive = true;
  
  @override
  void dispose() {
    for (final condition in conditions) {
      condition.dispose();
    }
    ruleNameController.dispose();
    evaluationFrequencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ruleConfigurationBloc = context.read<RuleConfigurationBloc>()
      ..add(LoadInitialData());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedRuleItem;
    if (item == null) return;

    ruleNameController.text = item.ruleName ?? '';
    evaluationFrequencyController.text =
        item.evaluationFrequency?.toString() ?? '';
    selectedEvaluationUnit = item.evaluationUnit;
    selectedApplicableDevices = item.deviceIds;
    selectedSensorType = item.sensorTypeIds;
    isActive = item.isActive ?? false;

    conditions = item.conditions.map((c) {
      final model = ConditionBlockModel(
        valueTypeId: c.valueTypeId,
        valueFormat: c.valueFormat,
        siUnit: c.siUnit,
        siUnitId: c.unitId,
        operator: c.operator,
        threshold: c.threshold.toString(),
        alertType: c.alertTypeId,
        alertMessageTemplate: c.alertMessageTemplate,
        alertDescription: c.alertDescription,
        connector: c.connector,
      );

      if (model.valueTypeId != null) {
        _ruleConfigurationBloc.add(LoadSensorCategorySiUnits(model.valueTypeId!));
      }

      // Add sub conditions
      model.subConditions = c.subConditions.map((sub) {
        return SubCondition(
          operator: sub.operator,
          threshold: sub.threshold.toString(),
          connector: sub.connector,
          sortOrder: 0,
        );
      }).toList();

      return model;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<RuleConfigurationBloc, RuleConfigurationState>(
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
              _ruleDetailsView(state),
              SizedBox(
                height: 2.h,
              ),
              _conditionsView(state),
              SizedBox(
                height: 2.h,
              ),
              _ruleSettingsView(),
              SizedBox(
                height: 2.h,
              ),
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
                    text: 'Save Rule',
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
          );
        },
      ),
    );
  }

  void _doProcess() {
    if (_doValidate()) {
      final List<ConditionBlockRequest> conditionRequests =
          conditions.map((condition) {
        final updatedSubConditions = <SubConditionRequest>[];
        int sortOrder = 1;

// First, add the main condition operator and threshold
        updatedSubConditions.add(
          SubConditionRequest(
            operator: condition.operator,
            thresholdValue: double.tryParse(condition.threshold ?? ''),
            connector: condition.connector,
            sortOrder: sortOrder++,
          ),
        );

// Now, add the user-defined subconditions
        for (final sub in condition.subConditions) {
          updatedSubConditions.add(
            SubConditionRequest(
              operator: sub.operator,
              thresholdValue: double.tryParse(sub.threshold ?? ''),
              connector: sub.connector,
              sortOrder: sortOrder++,
            ),
          );
        }

        return ConditionBlockRequest(
          valueTypeId: condition.valueTypeId,
          valueFormat: condition.valueFormat,
          siUnitId: condition.siUnitId,
          alertTypeId: condition.alertType,
          connector: condition.connector,
          alertMessageTemplate: AlertMessageTemplateRequest(
            title: condition.alertMessageTemplate,
            body: condition.alertDescription ?? '',
            level: 'critical',
          ),
          subConditions: updatedSubConditions,
        );
      }).toList();

      final request = RuleConfigurationRequest(
        ruleName: ruleNameController.text.trim(),
        evaluationFrequency: evaluationFrequencyController.text.trim(),
        evaluationUnit: selectedEvaluationUnit,
        isActive: isActive,
        deviceIds: selectedApplicableDevices,
        sensorTypeIds: selectedSensorType,
        conditions: conditionRequests,
      );

      _ruleConfigurationBloc.add(CreateEditRuleConfiguration(request,
          ruleId: widget.selectedRuleItem?.ruleId));
    }
  }

  bool _doValidate() {

    if (ruleNameController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter rule name');
      return false;
    }

    if (selectedApplicableDevices.isEmpty) {
      ToastMessageUtils.showMessage(
          context, 'Please select at least one device');
      return false;
    }

    if (selectedSensorType.isEmpty) {
      ToastMessageUtils.showMessage(
          context, 'Please select at least one sensor type');
      return false;
    }

    for (int i = 0; i < conditions.length; i++) {
      final condition = conditions[i];

      if (condition.valueTypeId == null) {
        ToastMessageUtils.showMessage(
            context, 'Please select value type in Condition ${i + 1}');
        return false;
      }

      if (condition.valueFormat == null) {
        ToastMessageUtils.showMessage(
            context, 'Please select value format in Condition ${i + 1}');
        return false;
      }

      if (condition.siUnitId == null) {
        ToastMessageUtils.showMessage(
            context, 'Please select SI unit in Condition ${i + 1}');
        return false;
      }

      if (condition.operator == null) {
        ToastMessageUtils.showMessage(
            context, 'Please select operator in Condition ${i + 1}');
        return false;
      }

      if (condition.threshold?.trim().isEmpty ?? true) {
        ToastMessageUtils.showMessage(context, 'Please enter threshold in Condition ${i + 1}');
        return false;
      }

      for (int j = 0; j < condition.subConditions.length; j++) {
        final sub = condition.subConditions[j];

        if (sub.operator == null) {
          ToastMessageUtils.showMessage(context, 'Please select operator in Sub Condition ${j + 1} of Condition ${i + 1}');
          return false;
        }

        if (sub.threshold?.trim().isEmpty ?? true) {
          ToastMessageUtils.showMessage(context,
              'Please enter threshold in Sub Condition ${j + 1} of Condition ${i + 1}');
          return false;
        }
      }

      if (condition.alertType == null) {
        ToastMessageUtils.showMessage(
            context, 'Please select alert type in Condition ${i + 1}');
        return false;
      }

      if (condition.alertMessageTemplate?.trim().isEmpty ?? true) {
        ToastMessageUtils.showMessage(context,
            'Please enter alert message template in Condition ${i + 1}');
        return false;
      }
    }

    if (evaluationFrequencyController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(
          context, 'Please enter evaluation frequency');
      return false;
    }

    if (selectedEvaluationUnit == null) {
      ToastMessageUtils.showMessage(context, 'Please select evaluation unit');
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

  Widget _buildConditionBlock(int index, RuleConfigurationState state) {
    final condition = conditions[index];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ScreenCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Condition ${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      conditions.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: CustomDropDown<SensorCategoryEntity>(
                    label: 'Value Type/Category',
                    hintText: 'Select here',
                    value: condition.valueTypeId,
                    items: state.sensorCategoriesList,
                    getValue: (e) => e.id,
                    displayText: (e) => e.name ?? '',
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        condition.valueTypeId = value;
                        condition.siUnitId = null;
                        _ruleConfigurationBloc.add(LoadSensorCategorySiUnits(value));
                      });
                    },
                  ),
                ),
                SizedBox(width: 1.h),
                Expanded(
                  child: CustomDropDown<String>(
                    label: 'Value Format',
                    isRequired: true,
                    value: condition.valueFormat,
                    hintText: 'Select format',
                    items: Constants.valueFormats,
                    onChanged: (val) =>
                        setState(() => condition.valueFormat = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: CustomDropDown<SiUnitEntity>(
                    label: 'SI Unit',
                    hintText: 'Select unit',
                    value: condition.siUnitId,
                    items: state.sensorCategorySiUnitsMap[condition.valueTypeId] ?? [],
                    getValue: (e) => e.id,
                    displayText: (e) => e.unit ?? '',
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        condition.siUnitId = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 1.h),
                Expanded(
                  child: CustomDropDown<OperatorOption>(
                    label: 'Operator',
                    isRequired: true,
                    value: condition.operator,
                    hintText: 'Select operator',
                    items: Constants.operatorOptions,
                    displayText: (item) => item.label,
                    getValue: (item) => item.value,
                    onChanged: (val) =>
                        setState(() => condition.operator = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            CustomTextField(
              labelText: 'Threshold',
              hintText: 'Enter threshold value',
              isRequired: true,
              textInputType: TextInputType.number,
              controller: condition.thresholdTextEditingController,
              onChanged: (val) => condition.threshold = val,
            ),
            SizedBox(height: 2.h),
            CustomDropDown<String>(
              label: 'Sub Condition Connector',
              value: condition.connector,
              hintText: 'Select connector',
              items: Constants.conditionConnectors,
              onChanged: (val) {
                setState(() {
                  if (val == ConditionConnectors.none.name) {
                    condition.subConditions.clear();
                  }
                  condition.connector = val;
                });
              },
            ),
            if (condition.connector != ConditionConnectors.none.name)
              SizedBox(height: 1.h),
            if (condition.connector != ConditionConnectors.none.name)
              ..._buildSubConditions(condition),
            if (condition.connector != ConditionConnectors.none.name)
              GestureDetector(
                onTap: () {
                  setState(() {
                    final index = condition.subConditions.length + 1;
                    condition.subConditions.add(
                      SubCondition(
                        connector: condition.connector,
                        sortOrder: index,
                      ),
                    );
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16.sp,
                      color: ColorConstants.blueColorDark,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Add Sub Condition',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 2.h),
            CustomDropDown<AlertTypeItem>(
              label: 'Alert Type',
              hintText: 'Select alert',
              value: condition.alertType,
              items: state.alertTypeList,
              getValue: (e) => e.alertTypeId,
              displayText: (e) => e.alertTypeName ?? '',
              isRequired: true,
              onChanged: (value) {
                setState(() {
                  condition.alertType = value;
                });
              },
            ),
            SizedBox(height: 2.h),
            CustomTextField(
              onChanged: (val) => condition.alertMessageTemplate = val,
              labelText: 'Alert Message Template',
              hintText: 'Enter alert message template',
              maxLines: 4,
              textInputAction: TextInputAction.next,
              controller: condition.alertMessageTemplateTextEditingController,
              isRequired: true,
            ),
            SizedBox(height: 2.h),
            CustomTextField(
              onChanged: (val) => condition.alertDescription = val,
              labelText: 'Alert Description',
              hintText: 'Enter alert description',
              maxLines: 4,
              textInputAction: TextInputAction.done,
              controller: condition.alertDescriptionTemplateTextEditingController,
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSubConditions(ConditionBlockModel condition) {
    return List.generate(
      condition.subConditions.length,
      (i) {
        final sub = condition.subConditions[i];

        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 1,
                height: 6.h,
                color: Colors.grey.shade400,
                margin: EdgeInsets.only(right: 3.w),
              ),
              Expanded(
                child: CustomDropDown<OperatorOption>(
                  label: 'Operator',
                  value: sub.operator,
                  hintText: 'Select operator',
                  items: Constants.operatorOptions,
                  isRequired: true,
                  displayText: (item) => item.label,
                  getValue: (item) => item.value,
                  onChanged: (val) => setState(() => sub.operator = val),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: CustomTextField(
                  labelText: 'Threshold',
                  hintText: 'Enter value',
                  isRequired: true,
                  textInputType: TextInputType.number,
                  controller: sub.thresholdTextEditingController,
                  onChanged: (val) => sub.threshold = val,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => condition.subConditions.removeAt(i));
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ruleDetailsView(RuleConfigurationState state) {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rule Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            controller: ruleNameController,
            labelText: 'Rule Name',
            hintText: 'Enter rule name',
            isRequired: true,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 2.h),
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
                  .map((device) => ChipModel(device.deviceId, device.fullName))
                  .toList(), (ChipModel item) {
            selectedApplicableDevices.removeWhere((ee) {
              return ee == item.id;
            });
            setState(() {});
          }),
          SizedBox(height: 2.h),
          CustomMultiSelectField<SensorTypeEntity, int>(
            label: 'Sensor Type(s)',
            title: 'Select Sensor Types',
            hintText: 'Select sensor type',
            items: state.sensorList,
            selectedItems: selectedSensorType,
            isRequired: true,
            onSelectionDone: (newSelected) {
              selectedSensorType = newSelected;
              setState(() {});
            },
            itemIdBuilder: (d) => d.sensorTypeId ?? -1,
            itemLabelBuilder: (d) => d.name ?? '',
          ),
          SizedBox(height: 1.h),
          _buildChips(
              state.sensorList
                  .where((device) =>
                      selectedSensorType.contains(device.sensorTypeId))
                  .map((device) =>
                      ChipModel(device.sensorTypeId, device.name))
                  .toList(), (ChipModel item) {
            selectedSensorType.removeWhere((ee) => ee == item.id);
            setState(() {});
          }),
          SizedBox(height: 0.5.h),
        ],
      ),
    );
  }

  Widget _conditionsView(RuleConfigurationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (conditions.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(
                conditions.length,
                (index) {
                  return _buildConditionBlock(index, state);
                },
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              setState(() {
                conditions.add(ConditionBlockModel());
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 16.sp,
                  color: ColorConstants.blueColorDark,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Add Condition',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF007BFF),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 0.5.h,
        ),
      ],
    );
  }

  Widget _ruleSettingsView() {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rule Settings',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: evaluationFrequencyController,
                  labelText: 'Evaluation Frequency',
                  hintText: 'Enter frequency',
                  isRequired: true,
                  textInputType: TextInputType.number,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomDropDown<String>(
                  label: 'Evaluation Unit',
                  hintText: 'Select unit',
                  value: selectedEvaluationUnit,
                  items: Constants.evaluationUnitValues,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedEvaluationUnit = value;
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
        ],
      ),
    );
  }
}
