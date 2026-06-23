import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_event.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_state.dart';
import 'package:smart_coach_new/features/user_management/presentation/widgets/edit_view.dart';
import 'package:smart_coach_new/features/user_management/presentation/widgets/filter_dialog.dart';
import 'package:smart_coach_new/features/user_management/presentation/widgets/user_table.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late UserManagementBloc _userManagementBloc;

  int selectedCount = 0;
  int totalCount = 10;

  @override
  void initState() {
    super.initState();
    _userManagementBloc = context.read<UserManagementBloc>()
      ..add(LoadUserManagement());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Registration Management",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Manage and approve user registration requests",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
              BlocBuilder<UserManagementBloc, UserManagementState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        CustomButton(
                          text: "Filter",
                          prefixIcon: Icons.filter_list,
                          color: Color(0xFFF1F5F6),
                          textColor: Colors.black,
                          onPressed: () {
                            showFilterDialog(context, state.request);
                          },
                          textSize: 12,
                          iconSize: 4,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 2.h,
                          ),
                          radius: 6,
                        ),
                        SizedBox(width: 2.5.w),
                        // CustomButton(
                        //   text: "Search",
                        //   prefixIcon: Icons.search,
                        //   color: Color(0xFFF1F5F6),
                        //   textColor: Colors.black,
                        //   onPressed: () {},
                        //   textSize: 12,
                        //   iconSize: 4,
                        //   padding:
                        //       EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
                        //   radius: 6,
                        // ),
                        // SizedBox(width: 6.w),
                      ],
                    );
                  }),
              SizedBox(height: 1.5.h),
              Expanded(
                child: BlocConsumer<UserManagementBloc, UserManagementState>(
                  listener: (context, state) {
                    if (state is UserManagementLoading ||
                        state is UserManagementActionInProgress) {
                      Loader.show();
                    } else {
                      Loader.dismiss();
                    }

                    if (state is UserManagementActionSuccess) {
                      ToastMessageUtils.showMessage(context, state.message);
                    } else if (state is UserManagementFailure) {
                      ToastMessageUtils.showMessage(context, state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state.users.isEmpty) {
                      return const Center(child: Text("No users found"));
                    }
                    bool isActionEnabled = state.selectedUsers.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Opacity(
                              opacity: isActionEnabled ? 1 : 0.5,
                              child: CustomButton(
                                text: "Approve Selected",
                                prefixIcon: Icons.check_circle,
                                color: Colors.green,
                                textColor: Colors.white,
                                iconSize: 5,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.4.h, horizontal: 4.w),
                                textSize: 12,
                                onPressed: isActionEnabled
                                    ? () {
                                  context.read<UserManagementBloc>().add(
                                    ApproveOrRejectUsers(state
                                        .selectedUsers
                                        .map((e) =>
                                        ApproveUserRequest(
                                            targetUserId:
                                            e.userId!,
                                            approvalStatus:
                                            UserApprovalStatus
                                                .approved
                                                .name))
                                        .toList()),
                                  );
                                }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.2.h),
                        Row(
                          children: [
                            Opacity(
                              opacity: isActionEnabled ? 1 : 0.5,
                              child: CustomButton(
                                text: "Reject Selected",
                                prefixIcon: Icons.block,
                                color: Colors.red,
                                iconSize: 5,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.4.h, horizontal: 4.w),
                                textSize: 12,
                                textColor: Colors.white,
                                onPressed: isActionEnabled
                                    ? () {
                                  context.read<UserManagementBloc>().add(
                                    ApproveOrRejectUsers(state
                                        .selectedUsers
                                        .map((e) =>
                                        ApproveUserRequest(
                                            targetUserId:
                                            e.userId!,
                                            approvalStatus:
                                            UserApprovalStatus
                                                .rejected
                                                .name))
                                        .toList()),
                                  );
                                }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 2.w),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${state.selectedUsers.length} of ${state.users.length} selected",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Expanded(
                          child: UserTable(
                            users: state.users,
                            selectedUsers: state.selectedUsers,
                            onSelectUser: (UserEntity user) {
                              context.read<UserManagementBloc>().add(
                                  ToggleUserSelection(
                                      user: user, actionRemoveUser: false));
                            },
                            onUnSelectUser: (UserEntity user) {
                              context.read<UserManagementBloc>().add(
                                  ToggleUserSelection(
                                      user: user, actionRemoveUser: true));
                            },
                            onApproveReject: (int? userId, String status) {
                              context.read<UserManagementBloc>().add(
                                ApproveOrRejectUsers(
                                  [
                                    ApproveUserRequest(
                                        targetUserId: userId!,
                                        approvalStatus: status)
                                  ],
                                ),
                              );
                            },
                            onTapEdit: (UserEntity user) {
                              _showJobRoleBottomSheet(context, user);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFilterDialog(BuildContext context, PendingUsersRequest? request) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        request: request,
        onTapReset: () {
          _userManagementBloc.add(LoadUserManagement());
        },
      ),
    ).then((selectedFilterValue) {
      if (selectedFilterValue != null) {
        _userManagementBloc
            .add(LoadUserManagement(request: selectedFilterValue));
      }
    });
  }

  void _showJobRoleBottomSheet(BuildContext context, UserEntity user) {
    String regionIds = user.regionIds ?? '';
    List<int> regionIdsList = [];
    if (regionIds.isNotEmpty) {
      regionIdsList = regionIds.split(',').map((e) => int.parse(e)).toList();
    }

    _userManagementBloc.add(LoadTrainsDropdowns(
        targetUserId: user.userId,
        zoneId: user.zoneId,
        divisionId: user.divisionId,
        regionId: regionIdsList));
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2.h)),
      ),
      builder: (context) {
        return EditView(
          user: user,
          userManagementBloc: _userManagementBloc,
          isEditable: (user.regionIds ?? '') == '-1' ? false : true,
          onTapSave: (int? selectedJobRoleId, List<int> selectedTrainIdList) {
            _userManagementBloc.add(UpdateTrainAndRole(
                targetUserId: user.userId,
                roleId: selectedJobRoleId,
                trainIds: selectedTrainIdList));
          },
        );
      },
    );
  }
}