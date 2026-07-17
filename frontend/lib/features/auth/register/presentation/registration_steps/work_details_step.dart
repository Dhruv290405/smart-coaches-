import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_checkbox.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_event.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_state.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';

class WorkDetailsStep extends StatelessWidget {
  final RegisterState state;
  final TextEditingController? organizationNameController;
  final TextEditingController? employeeIdController;
  final TextEditingController? companyIdController;

  const WorkDetailsStep({
    super.key,
    required this.state,
    required this.organizationNameController,
    required this.employeeIdController,
    required this.companyIdController,
  });

  @override
  Widget build(BuildContext context) {
    RegisterBloc bloc = context.read<RegisterBloc>();
    bool isOrganisationTypeIsContractor = bloc.state.registerRequest
        .isOrganisationTypeIsContractor();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Organization type"),
          _organizationTypeDropdownField(bloc, 'Select type'),
          if (isOrganisationTypeIsContractor) SizedBox(height: 2.h),
          if (isOrganisationTypeIsContractor)
            CustomTextField(
              labelText: "Organisation Name",
              hintText: "Enter Organisation Name",
              controller: organizationNameController,
              isRequired: true,
            ),
          SizedBox(height: 2.h),
          _title("Job Role"),
          _jobRoleDropdownField(bloc, 'Select job role'),
          SizedBox(height: 2.h),
          _title("Zone"),
          _zoneDropdownField(bloc, 'Select zone'),
          SizedBox(height: 2.h),
          _title("Division"),
          _divisionDropdownField(bloc, 'Select division'),
          SizedBox(height: 2.h),
          _title("Region"),
          _regionMultiSelectField(
            context,
            bloc.regionDropDownKey,
            state,
            bloc,
            'Select region',
          ),
          if (_isTrainOperatorSelected(bloc)) SizedBox(height: 2.h),
          if (_isTrainOperatorSelected(bloc)) _title("Train", isRequired: true),
          if (_isTrainOperatorSelected(bloc))
            _regionMultiSelectField(
              context,
              bloc.trainDropDownKey,
              state,
              bloc,
              'Select train',
            ),
          SizedBox(height: 2.h),
          CustomTextField(
            labelText: "Employee ID Number",
            hintText: "Enter ID number",
            controller: employeeIdController,
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            labelText: "Company ID",
            hintText: "Enter company ID",
            controller: companyIdController,
          ),
        ],
      ),
    );
  }

  Widget _regionMultiSelectField(
    BuildContext context,
    String key,
    RegisterState stateas,
    RegisterBloc bloc,
    String hintText,
  ) {
    String selectedNames = '';
    if (key == bloc.regionDropDownKey) {
      if ((bloc.state.registerRequest.regionIdList ?? []).isNotEmpty) {
        selectedNames = bloc.state.regions
            .where(
              (r) =>
                  bloc.state.registerRequest.regionIdList!.contains(r.regionId),
            )
            .map((r) => r.name ?? '')
            .join(', ');
      }
    } else {
      if ((bloc.state.registerRequest.trainIdList ?? []).isNotEmpty) {
        selectedNames = bloc.state.trains
            .where(
              (r) =>
                  bloc.state.registerRequest.trainIdList!.contains(r.trainId),
            )
            .map((r) => r.trainName ?? '')
            .join(', ');
      }
    }

    return GestureDetector(
      onTap: () {
        _showMultiRegionDialog(context, key, bloc, hintText);
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.5.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.h),
            ),
          ),
          controller: TextEditingController(text: selectedNames),
          style: TextStyle(fontSize: 12.5.sp, color: Colors.black),
        ),
      ),
    );
  }

  Widget _organizationTypeDropdownField(RegisterBloc bloc, String hintText) {
    final uniqueOrgTypes = <String, dynamic>{};
    for (var item in bloc.state.organizationTypes) {
      if (!uniqueOrgTypes.containsKey(item.name)) {
        uniqueOrgTypes[item.name] = item;
      }
    }

    final currentValue = bloc.state.registerRequest.organisationType;
    final valueExists = currentValue != null && uniqueOrgTypes.containsKey(currentValue);

    return DropdownButtonFormField<String>(
      initialValue: valueExists ? currentValue : null,
      hint: Text(
        hintText,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.h)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      items: uniqueOrgTypes.values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.name,
              child: _dropDownTextView(item.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          bloc.add(
            UpdateDropdownValue(
              key: bloc.organizationTypeDropDownKey,
              value: value,
            ),
          );
          // bloc.add(LoadRolesDropdowns(organisationType: value));
          // setState(() {});
        }
      },
    );
  }

  Widget _zoneDropdownField(RegisterBloc bloc, String hintText) {
    final uniqueZones = <int, dynamic>{};
    for (var item in bloc.state.zones) {
      if (item.zoneId != null && !uniqueZones.containsKey(item.zoneId)) {
        uniqueZones[item.zoneId!] = item;
      }
    }

    final currentValue = bloc.state.registerRequest.zoneId;
    final valueExists = currentValue != null && uniqueZones.containsKey(currentValue);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? currentValue : null,
      hint: Text(
        hintText,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.h)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      items: uniqueZones.values
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.zoneId,
              child: _dropDownTextView(item.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null && bloc.state.registerRequest.zoneId != value) {
          bloc.add(
            UpdateDropdownValue(key: bloc.zoneDropDownKey, value: value),
          );
          bloc.add(LoadDivisionsDropdowns(zoneId: value));
        }
      },
    );
  }

  Widget _divisionDropdownField(RegisterBloc bloc, String hintText) {
    final uniqueDivisions = <int, dynamic>{};
    for (var item in bloc.state.divisions) {
      if (item.divisionId != null && !uniqueDivisions.containsKey(item.divisionId)) {
        uniqueDivisions[item.divisionId!] = item;
      }
    }

    final currentValue = bloc.state.registerRequest.divisionId;
    final valueExists = currentValue != null && uniqueDivisions.containsKey(currentValue);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? currentValue : null,
      hint: Text(
        hintText,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.h)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      items: uniqueDivisions.values
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.divisionId,
              child: _dropDownTextView(item.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null && bloc.state.registerRequest.divisionId != value) {
          bloc.add(
            UpdateDropdownValue(key: bloc.divisionDropDownKey, value: value),
          );
          bloc.add(LoadRegionsDropdowns(divisionId: value));
        }
      },
    );
  }

  void _showMultiRegionDialog(
      BuildContext context,
      String key,
      RegisterBloc bloc,
      String title,
      ) {
    List<int> currentSelected = [];
    int itemCount = 0;
    int? allItemId;

    if (key == bloc.regionDropDownKey) {
      currentSelected = List.from(bloc.state.registerRequest.regionIdList ?? []);
      itemCount = bloc.state.regions.length;
      int indexOfAllItem = bloc.state.regions.indexWhere(
            (item) => (item.name ?? '').toLowerCase() == 'all',
      );
      if (indexOfAllItem != -1) {
        allItemId = bloc.state.regions[indexOfAllItem].regionId;
      }
    } else {
      currentSelected = List.from(bloc.state.registerRequest.trainIdList ?? []);
      itemCount = bloc.state.trains.length;
      int indexOfAllItem = bloc.state.trains.indexWhere(
            (item) => (item.trainName ?? '').toLowerCase() == 'all',
      );
      if (indexOfAllItem != -1) {
        allItemId = bloc.state.trains[indexOfAllItem].trainId;
      }
    }

    if (itemCount == 1) {
      if (key == bloc.regionDropDownKey) {
        int regionId = bloc.state.regions.first.regionId!;
        bloc.add(UpdateDropdownValue(key: bloc.regionDropDownKey, value: [regionId]));
        if (_isTrainOperatorSelected(bloc)) {
          bloc.add(LoadTrainsDropdowns(
            zoneId: bloc.state.registerRequest.zoneId,
            divisionId: bloc.state.registerRequest.divisionId,
            regionId: [regionId],
          ));
        }
      } else {
        int trainId = bloc.state.trains.first.trainId!;
        bloc.add(UpdateDropdownValue(key: bloc.trainDropDownKey, value: [trainId]));
      }
      return;
    }

    if (itemCount == 0) return;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2.h)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 2.h,
            left: 4.w,
            right: 4.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.h),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    String? name;
                    int? id;
                    if (key == bloc.regionDropDownKey) {
                      RegionItem item = bloc.state.regions[index];
                      name = item.name;
                      id = item.regionId;
                    } else {
                      TrainItem item = bloc.state.trains[index];
                      name = item.trainName;
                      id = item.trainId;
                    }
                    final isChecked = currentSelected.contains(id);
                    return CustomCheckbox(
                      value: isChecked,
                      text: name,
                      fontSize: 12.5,
                      onChange: (bool? value) {
                        if ((name ?? '').toLowerCase() == 'all') {
                          if (currentSelected.isNotEmpty) {
                            currentSelected.clear();
                            currentSelected.add(id!);
                          } else {
                            if (key == bloc.regionDropDownKey) {
                              currentSelected.clear();
                              currentSelected = bloc.state.regions
                                  .map((item) => item.regionId!)
                                  .toList();
                            } else {
                              currentSelected.clear();
                              currentSelected = bloc.state.trains
                                  .map((item) => item.trainId!)
                                  .toList();
                            }
                          }
                        } else {
                          if (value == true) {
                            if (allItemId != null &&
                                currentSelected.contains(allItemId)) {
                              currentSelected.remove(allItemId);
                            }
                            currentSelected.add(id!);
                          } else {
                            currentSelected.remove(id);
                          }
                        }
                        (context as Element).markNeedsBuild();
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Apply',
                    padding: EdgeInsets.symmetric(
                      vertical: 1.6.h,
                      horizontal: 5.w,
                    ),
                    textSize: 12,
                    radius: 6,
                    onPressed: () {
                      bloc.add(
                        UpdateDropdownValue(key: key, value: currentSelected),
                      );
                      if (key == bloc.regionDropDownKey) {
                        bloc.add(
                          UpdateDropdownValue(
                            key: bloc.regionDropDownKey,
                            value: currentSelected,
                          ),
                        );
                        if (_isTrainOperatorSelected(bloc)) {
                          bloc.add(
                            LoadTrainsDropdowns(
                              zoneId: bloc.state.registerRequest.zoneId,
                              divisionId: bloc.state.registerRequest.divisionId,
                              regionId: currentSelected,
                            ),
                          );
                        }
                      } else {
                        bloc.add(
                          UpdateDropdownValue(
                            key: bloc.trainDropDownKey,
                            value: currentSelected,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _jobRoleDropdownField(RegisterBloc bloc, String hintText) {
    final uniqueRoles = <int, dynamic>{};
    for (var item in bloc.state.jobRoles) {
      if (item.roleId != null && !uniqueRoles.containsKey(item.roleId)) {
        uniqueRoles[item.roleId!] = item;
      }
    }

    final currentValue = bloc.state.registerRequest.roleId;
    final valueExists = currentValue != null && uniqueRoles.containsKey(currentValue);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? currentValue : null,
      hint: Text(
        hintText,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.h)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      items: uniqueRoles.values
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.roleId,
              child: _dropDownTextView(item.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null && bloc.state.registerRequest.roleId != value) {
          bloc.add(
            UpdateDropdownValue(key: bloc.roleDropDownKey, value: value),
          );
        }
      },
    );
  }

  Widget _title(String title, {bool isRequired = true}) => Padding(
    padding: EdgeInsets.only(bottom: 0.5.h),
    child: FieldLabelTextView(labelText: title, isRequired: isRequired),
  );

  Widget _dropDownTextView(String? name) {
    return Text(
      name ?? '',
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  bool _isTrainOperatorSelected(RegisterBloc bloc) {
    final roleId = bloc.state.registerRequest.roleId;
    if (roleId == null) return false;

    final selectedRole = bloc.state.jobRoles.firstWhere(
      (role) => role.roleId == roleId,
      orElse: () => bloc.state.jobRoles.first,
    );

    return selectedRole.name?.toLowerCase() == 'train operator';
  }
}
