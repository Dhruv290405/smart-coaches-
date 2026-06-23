import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_checkbox.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_event.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_state.dart';

class EditView extends StatefulWidget {
  final UserManagementBloc userManagementBloc;
  final UserEntity user;
  final Function(int?, List<int>) onTapSave;
  final bool isEditable;

  const EditView({
    super.key,
    required this.user,
    required this.userManagementBloc,
    required this.onTapSave,
    required this.isEditable,
  });

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  bool isTrainIsSelected = false;
  int? selectedJobRoleId;

  @override
  void initState() {
    selectedJobRoleId = widget.user.roleId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementBloc, UserManagementState>(
      bloc: widget.userManagementBloc,
      builder: (mContext, state) {
        if (state is LoadTrainsSuccess) {
          return Container(
            padding: EdgeInsets.all(2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.isEditable ? 'EDIT' : 'VIEW',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                _title("Train"),
                _regionMultiSelectField(
                  context,
                  'Select train',
                  state.trains ?? [],
                  state,
                ),
                SizedBox(height: 2.h),
                _title("Job Role"),
                _jobRoleDropdownField('Select job role', state.roles ?? []),
                SizedBox(height: 2.h),
                if (widget.isEditable)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        text: 'Cancel',
                        color: Color(0xFFF2F3F5),
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
                        text: 'Save',
                        padding: EdgeInsets.symmetric(
                          vertical: 1.6.h,
                          horizontal: 5.w,
                        ),
                        textSize: 12,
                        radius: 6,
                        onPressed: () {
                          if (selectedJobRoleId == null) {
                            ToastMessageUtils.showMessage(
                              context,
                              'Please select your job role',
                              useFlutterToast: true,
                            );
                          } else {
                            List<int> currentSelected = (state.trains ?? [])
                                .where((item) => item.isMapped == true)
                                .map((i) => i.trainId!)
                                .toList();

                            Navigator.pop(context);
                            widget.onTapSave.call(
                              selectedJobRoleId,
                              currentSelected,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        }
        return Container(height: 10.h);
      },
    );
  }

  Widget _regionMultiSelectField(
    BuildContext context,
    String hintText,
    List<TrainItem>? trains,
    UserManagementState state,
  ) {
    String selectedNames = '';
    if ((trains ?? []).isNotEmpty) {
      selectedNames = (trains ?? [])
          .where((item) => item.isMapped == true)
          .map((r) => r.trainName ?? '')
          .join(', ');
    }

    return GestureDetector(
      onTap: () {
        _showMultiRegionDialog(context, hintText, trains, state);
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

  void _showMultiRegionDialog(
    BuildContext context,
    String title,
    List<TrainItem>? trains,
    UserManagementState state,
  ) {
    int? allItemId;
    List<int> currentSelected = (trains ?? [])
        .where((item) => item.isMapped == true)
        .map((i) => i.trainId!)
        .toList();
    int itemCount = (trains ?? []).length;
    int indexOfAllItem = (trains ?? []).indexWhere(
      (item) => (item.trainName ?? '').toLowerCase() == 'all',
    );
    if (indexOfAllItem != -1) {
      allItemId = (trains ?? [])[indexOfAllItem].trainId;
    }

    if (itemCount <= 1) {
      return;
    }

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
                    TrainItem item = (trains ?? [])[index];
                    String? name = item.trainName;
                    int? id = item.trainId;
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
                            currentSelected.clear();
                            currentSelected = (trains ?? [])
                                .map((item) => item.trainId!)
                                .toList();
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
                      widget.user.roleId = null;
                      selectedJobRoleId = null;
                      // List<TrainItem>? selectedTrains = (trains ?? [])
                      //     .where(
                      //       (item) => currentSelected.contains(item.trainId),
                      //     )
                      //     .toList();


                      int i=0;
                      for (TrainItem allTrainItem in (trains ?? [])) {

                        int index = (trains ?? []).indexWhere((defaultItem) => currentSelected.contains(allTrainItem.trainId));
                        if(index != -1) {
                          (trains ?? [])[i].isMapped = true;
                        } else {
                          (trains ?? [])[i].isMapped = false;
                        }
                        i++;
                      }

                      // int i = 0;
                      // for (TrainItem item in selectedTrains) {
                      //
                      //   int index = (trains ?? []).indexWhere((defaultItem) => defaultItem.trainId == item.trainId);
                      //   if(index != -1) {
                      //     if((trains ?? []).isNotEmpty) {
                      //       (trains ?? [])[index].isMapped = true;
                      //     }
                      //   }
                      //
                      //   // selectedTrains[i].isMapped = true;
                      //   i++;
                      // }

                      widget.userManagementBloc.add(
                        OnChangeTrain(
                          zoneId: widget.user.zoneId,
                          divisionId: widget.user.divisionId,
                          regionId: widget.user.regionIds,
                          selectedTrains: trains,
                        ),
                      );
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

  Widget _jobRoleDropdownField(String hintText, List<RoleItem> items) {
    return DropdownButtonFormField<int>(
      initialValue: widget.user.roleId,
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
      items: items
          .map(
            (RoleItem item) => DropdownMenuItem(
              value: item.roleId,
              child: _dropDownTextView(item.name),
            ),
          )
          .toList(),
      icon: widget.isEditable ? null : const SizedBox.shrink(),
      onChanged: widget.isEditable
          ? (value) {
              if (value != null) {
                selectedJobRoleId = value;
              }
            }
          : null,
    );
  }

  Widget _title(String title) => Padding(
    padding: EdgeInsets.only(bottom: 0.5.h),
    child: FieldLabelTextView(labelText: title),
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
}
