import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/positive_integer_input_formatter.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_state.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

class ConfigureCoach extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final CoachEntity? selectedCoachItem;

  const ConfigureCoach({
    super.key,
    required this.onGoToListAndRefresh,
    this.selectedCoachItem,
  });

  @override
  State<ConfigureCoach> createState() => _ConfigureCoachState();
}

class _ConfigureCoachState extends State<ConfigureCoach> {
  late CoachConfigurationBloc _coachConfigurationBloc;
  final TextEditingController coachUniqueIdController = TextEditingController();
  final TextEditingController coachDisplayIdController =
      TextEditingController();
  final TextEditingController manufacturingYearController =
      TextEditingController();

  String? selectedEntityType = 'Coach';
  int? selectedMakeOfId;
  int? selectedTypeOfId;
  int? selectedMasterModule;
  String? selectedCoachStatus;

  List<String> entityTypeList = ['Coach' , 'Loco'];
  List<int> masterModuleList = [1, 2, 3, 4];
  List<String> coachStatusList = ['Active', 'Under Maintenance', 'Retired'];

  @override
  void dispose() {
    coachUniqueIdController.dispose();
    coachDisplayIdController.dispose();
    manufacturingYearController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _coachConfigurationBloc = context.read<CoachConfigurationBloc>()
      ..add(LoadInitialData());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedCoachItem;
    if (item == null) return;
    coachUniqueIdController.text = item.coachUniqueId?.toString() ?? '';
    coachDisplayIdController.text = item.coachDisplayId?.toString() ?? '';
    manufacturingYearController.text = item.manufacturingYear.toString();
    selectedEntityType = entityTypeList.contains(item.entityType) ? item.entityType : null;
    selectedMakeOfId = item.makeOfCoachId;
    selectedTypeOfId = item.typeOfCoachId;
    selectedMasterModule = masterModuleList.contains(item.noOfMasterModule) ? item.noOfMasterModule : null;
    selectedCoachStatus = item.coachStatus;
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
        child: BlocConsumer<CoachConfigurationBloc, CoachConfigurationState>(
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
                Text(
                  'Coach Information',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                CustomDropDown<String>(
                  label: 'Entity Type',
                  hintText: 'Select Entity Type',
                  value: selectedEntityType,
                  isRequired: true,
                  items: entityTypeList,
                  onChanged: (value) {
                    setState(() {
                      selectedEntityType = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: coachUniqueIdController,
                  labelText: '$selectedEntityType Technical No',
                  hintText: 'Enter $selectedEntityType Technical No',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: coachDisplayIdController,
                  labelText: '$selectedEntityType Display ID',
                  hintText: 'Enter $selectedEntityType Display ID',
                  isRequired: true,
                ),

                SizedBox(height: 2.h),
                CustomDropDown<CoachMakeItem>(
                  label: 'Make of $selectedEntityType',
                  hintText: 'Select Make of $selectedEntityType',
                  value: selectedMakeOfId,
                  items: state.coachMakeList,
                  getValue: (e) => e.id,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedMakeOfId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<CoachTypeItem>(
                  label: 'Type of $selectedEntityType',
                  hintText: 'Select Type of $selectedEntityType',
                  value: selectedTypeOfId,
                  items: state.coachTypeList,
                  getValue: (e) => e.id,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedTypeOfId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: manufacturingYearController,
                  labelText: 'Manufacturing Year',
                  hintText: 'Enter Manufacturing Year',
                  isRequired: true,
                  inputFormatters: [PositiveIntegerInputFormatter()],
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 2.h),
                CustomDropDown<int>(
                  label: '# Master Modules',
                  hintText: 'Select Number of Modules',
                  value: selectedMasterModule,
                  isRequired: true,
                  items: masterModuleList,
                  onChanged: (value) {
                    setState(() {
                      selectedMasterModule = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Coach Status',
                  hintText: 'Select Coach Status',
                  value: selectedCoachStatus,
                  isRequired: true,
                  items: coachStatusList,
                  onChanged: (value) {
                    setState(() {
                      selectedCoachStatus = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
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
                      text: 'Save Coach',
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
      ),
    );
  }

  void _doProcess() {
    if (!_doValidate()) return;

    final request = CoachConfigurationRequest(
      coachUniqueId: coachUniqueIdController.text.trim(),
      coachDisplayId: coachDisplayIdController.text.trim(),
      manufacturingYear: manufacturingYearController.text.trim(),
      entityType: selectedEntityType,
      makeOfCoach: selectedMakeOfId.toString(),
      typeOfCoach: selectedTypeOfId.toString(),
      noOfMasterModule: selectedMasterModule,
      coachStatus: selectedCoachStatus,
    );

    _coachConfigurationBloc.add(
      CreateEditCoachConfiguration(
        request,
        coachId: widget.selectedCoachItem?.coachId,
      ),
    );
  }

  bool _doValidate() {
    if (coachUniqueIdController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Coach Technical No');
      return false;
    } else if (coachDisplayIdController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Coach Display ID');
      return false;
    } else if (manufacturingYearController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Manufacturing Year');
      return false;
    } else if (selectedEntityType == null) {
      ToastMessageUtils.showMessage(context, 'Please select Entity Type');
      return false;
    } else if (selectedMakeOfId == null) {
      ToastMessageUtils.showMessage(context, 'Please select Make Of Coach');
      return false;
    } else if (selectedTypeOfId == null) {
      ToastMessageUtils.showMessage(context, 'Please select Type Of Coach');
      return false;
    } else if (selectedMasterModule == null) {
      ToastMessageUtils.showMessage(context, 'Please select Master Module');
      return false;
    } else if (selectedCoachStatus == null) {
      ToastMessageUtils.showMessage(context, 'Please select Coach Status');
      return false;
    }
    return true;
  }
}
