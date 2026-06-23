
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/image_utils.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:smart_coach_new/core/utils/device_id_mapper.dart';
import 'package:smart_coach_new/features/dashboard/presentation/widgets/counts_data_view.dart';
import 'package:smart_coach_new/features/dashboard/presentation/widgets/custom_drawer.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_event.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_state.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class DashboardScreen extends StatefulWidget {
  final dynamic user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = context.read<DashboardBloc>();
    _dashboardBloc.add(LoadDashboardData());
    _initializePermissions();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  void _initializePermissions() {
    final permissionBloc = context.read<PermissionBloc>();

    if (!permissionBloc.isInitialized) {
      final prefs = GetIt.I<Prefs>();
      final user = prefs.getUser();

      print('DASHBOARD: Initializing permissions for user role_id: ${user?.roleId}');

      if (user != null && user.roleId != null) {
        permissionBloc.add(InitializePermissions(
          roleId: user.roleId!,
          roleName: null,
        ));
      }
    } else {
      print('DASHBOARD: Permissions already initialized. Role: ${permissionBloc.currentRoleId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy - EEEE').format(now);
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardNavigateToNotifications) {
          context.push(AppRouter.notificationsRoute);
        } else if (state is DashboardNavigateToSettings) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings feature coming soon')),
          );
        } else if (state is DashboardNavigateToProfile) {
          context.push(AppRouter.profileRoute);
        }
      },
      child: Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: 22.sp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Image.asset(
          ImageUtils.pisolveName,
          height: 4.0.h,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.push(AppRouter.profileRoute);
            },
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3883F8),
              radius: 12.sp,
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: 2.w),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final unreadCount =
                  state is NotificationLoaded ? state.unreadCount : 0;
              return GestureDetector(
                onTap: () => context.push(AppRouter.notificationsRoute),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.black,
                        size: 20.sp,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 10,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: () {
              _showLogoutDialog();
            },
            child: Icon(
              Icons.logout,
              color: Colors.red,
              size: 18.sp,
            ),
          ),

          SizedBox(width: 4.w),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _dashboardBloc.add(LoadDashboardData());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.5.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.0.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Coach Dashboard',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.0.h),
                        Text(
                          'Today is $formattedDate',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is DashboardDataLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CountsDataView(
                              totalTrains: state.totalTrains,
                              smartCoaches: state.smartCoaches,
                              activeDevices: state.activeDevices,
                              activeSensors: state.activeSensors,
                              criticalAlerts: state.recentAlerts.length + state.recentPneumaticAlerts.length,
                              warnings: state.warnings,
                              moderate: state.moderate,
                              normalState: state.normalState,
                              acpDeployed: state.acpDeployed,
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Critical & Maintenance Alerts',
                                  style:
                                  TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                                ),
                                GestureDetector(
                                  onTap: () => context.push(AppRouter.alertsRoute),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(fontSize: 10.sp, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.5.h),
                            state.recentAlerts.isNotEmpty || state.recentPneumaticAlerts.isNotEmpty
                              ? ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    // ACP Alerts
                                    ...state.recentAlerts.map((alert) {
                                      final isCritical = alert.acpStatus?.toLowerCase().contains('active') ?? false;
                                      return _buildAlertCard(
                                        context,
                                        title: 'ACP - Train: ${alert.trainNo ?? "N/A"}',
                                        subtitle: 'Coach: ${alert.commCoachNo ?? "N/A"} (${alert.techCoachNo ?? "N/A"})',
                                        status: alert.acpStatus?.toUpperCase() ?? "N/A",
                                        isCritical: isCritical,
                                        icon: Icons.notifications_active_outlined,
                                        onTap: () => context.push(AppRouter.acpMonitoringRoute),
                                      );
                                    }),
                                    
                                    // Pneumatic Alerts
                                    ...state.recentPneumaticAlerts.map((alert) {
                                      final fault = alert.brakeFault?.toString().toLowerCase() ?? "";
                                      final statusText = alert.brakeStatus?.toString().toUpperCase() ?? "N/A";
                                      final isCritical = (fault.isNotEmpty && fault != "null" && fault != "none");
                                      
                                      return Padding(
                                        padding: EdgeInsets.only(top: 1.h),
                                        child: _buildAlertCard(
                                          context,
                                          title: 'Brake - Train: ${alert.trainNo ?? "N/A"}',
                                          subtitle: 'Coach: ${alert.coachNo ?? "N/A"} (Device: ${DeviceIdMapper.resolve(alert.deviceId?.toString())})',
                                          status: statusText,
                                          isCritical: isCritical,
                                          icon: Icons.settings_input_component_outlined,
                                          onTap: () => context.push(AppRouter.breakBinding),
                                        ),
                                      );
                                    }),
                                  ],
                                )
                              : Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: Text(
                                      'No active alerts',
                                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      } else if (state is DashboardError) {
                        return Center(
                          child: Column(
                            children: [
                              Text(state.message, style: const TextStyle(color: Colors.red)),
                              ElevatedButton(
                                onPressed: () => _dashboardBloc.add(LoadDashboardData()),
                                child: const Text("Retry"),
                              )
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String status,
    required bool isCritical,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCritical ? Colors.red : Colors.orange,
                size: 14.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: isCritical ? Colors.red : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await GetIt.I<Prefs>().clear();
                if (context.mounted) {
                  context.go(AppRouter.loginRoute);
                }
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
