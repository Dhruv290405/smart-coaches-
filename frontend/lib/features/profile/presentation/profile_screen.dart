import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_state.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = context.read<ProfileBloc>();
    _profileBloc.add(FetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          Loader.show();
        } else {
          Loader.dismiss();
        }

        if (state is ProfileFailure) {
          ToastMessageUtils.showMessage(context, state.message);
        }

        if (state is ProfileLogoutSuccess) {
          context.go(AppRouter.loginRoute);
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.screenBgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20.sp),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return _buildProfileContent(state.profile);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(ProfileEntity profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF3883F8),
                    radius: 35.sp,
                    child: Text(
                      "${profile.firstName[0]}${profile.lastName[0]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${profile.firstName} ${profile.lastName}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: profile.status == 'Active'
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      profile.status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: profile.status == 'Active'
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildInfoRow('Mobile Number', profile.mobileNumber),
                  _buildInfoRow('Gender', profile.gender),
                  _buildInfoRow('Employee ID', profile.employeeId),
                  _buildInfoRow('PAN Card', profile.panCardNo),
                  _buildInfoRow('Aadhar Number', profile.aadharNo),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organisation Details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildInfoRow('Organisation Type', profile.organisationType),
                  if(profile.organisationName.isNotEmpty)
                  _buildInfoRow('Organisation Name', profile.organisationName),
                  _buildInfoRow('Zone ID', profile.zoneId.toString()),
                  _buildInfoRow('Division ID', profile.divisionId.toString()),
                  _buildInfoRow('Region ID', profile.regionId.toString()),
                  _buildInfoRow('Approval Status', profile.approvalStatus),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            CustomButton(
              text: 'Logout',
              onPressed: () {
                _showLogoutDialog();
              },
              color: Colors.red[600],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 12.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _profileBloc.add(LogoutRequested());
              },
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 11.sp, color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }
}
