import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/permissions/permission_constants.dart';
import 'package:smart_coach_new/core/permissions/permission_helper.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final Map<String, bool> _expanded = {
    'User Management': false,
    'Configurations': false,
    'Device Management': false,
    'Reports & Alerts': false,
    'FSDS': false,
  };

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  void _initializePermissions() async {
    final permissionBloc = context.read<PermissionBloc>();
    if (!permissionBloc.isInitialized) {
      final prefs = GetIt.I<Prefs>();
      final user = prefs.getUser();

      if (user != null && user.roleId != null) {
        permissionBloc.add(
          InitializePermissions(roleId: user.roleId!, roleName: null),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionBloc = context.read<PermissionBloc>();
    final prefs = GetIt.I<Prefs>();
    final user = prefs.getUser();
    final roleId = user?.roleId ?? 0;
    final regionName = user?.regionName ?? '';
    final isDanapur = regionName == 'Danapur';

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          children: [
            if (isDanapur || context.hasAnyPermission([
              PermissionConstants.canViewUserRegistration,
              PermissionConstants.canApproveUsers,
              PermissionConstants.canCreateUsers,
            ]))
              _drawerSection(
                title: 'User Management',
                icon: Icons.person_outline,
                isExpanded: _expanded['User Management']!,
                onTap: () {
                  setState(
                    () => _expanded['User Management'] =
                        !_expanded['User Management']!,
                  );
                },
                children: [
                  if (isDanapur || context.hasPermission(PermissionConstants.canCreateUsers))
                    _drawerItem(
                      'User Registration',
                      icon: Icons.app_registration,
                      onTap: () {
                        context.push(AppRouter.registerRoute);
                      },
                    ),
                  if (isDanapur || context.hasPermission(PermissionConstants.canApproveUsers))
                    _drawerItem(
                      'User Approval',
                      icon: Icons.verified_user,
                      onTap: () {
                        context.push(AppRouter.userManagementRoute);
                      },
                    ),
                ],
              ),
            // Hide Configuration section for read-only roles (Region Operator, Train Operator)
            if (roleId != 6 && roleId != 7)
              _drawerSection(
                title: 'Configurations',
                icon: Icons.settings,
                isExpanded: _expanded['Configurations']!,
                onTap: () {
                  setState(
                    () => _expanded['Configurations'] =
                        !_expanded['Configurations']!,
                  );
                },
                children: [
                  _drawerItem(
                    'Coach Config',
                    onTap: () {
                      context.push(AppRouter.coachConfigurationRoute);
                    },
                  ),
                  _drawerItem(
                    'Master Module Config',
                    onTap: () {
                      context.push(AppRouter.masterModuleConfigurationRoute);
                    },
                  ),
                  _drawerItem(
                    'Train Config',
                    onTap: () {
                      context.push(AppRouter.trainConfigurationRoute);
                    },
                  ),
                  _drawerItem(
                    'Sensor Config',
                    onTap: () {
                      context.push(AppRouter.sensorDeviceConfigurationRoute);
                    },
                  ),
                ],
              ),
            _drawerSection(
              title: 'Reports & Alerts',
              icon: Icons.assessment,
              isExpanded: _expanded['Reports & Alerts']!,
              onTap: () {
                setState(
                  () => _expanded['Reports & Alerts'] =
                      !_expanded['Reports & Alerts']!,
                );
              },
              children: [
                if (!isDanapur) ...[
                  _drawerItem(
                    'Coach Dashboard',
                    icon: Icons.dashboard_customize_outlined,
                    onTap: () {
                      context.push(AppRouter.coachDashboardRoute);
                    },
                  ),
                ],
                _drawerItem(
                  'ACP Monitoring',
                  onTap: () {
                    context.push(AppRouter.acpMonitoringRoute);
                  },
                ),
                if (!isDanapur)
                  _drawerSection(
                    title: 'FSDS',
                    isExpanded: _expanded['FSDS']!,
                    onTap: () {
                      setState(() => _expanded['FSDS'] = !_expanded['FSDS']!);
                    },
                    children: [
                      _drawerItem(
                        'FSDS Bypass',
                        onTap: () {
                          context.push(AppRouter.fsdsMonitoringRoute,
                              extra: 'FSDS Bypass');
                        },
                      ),
                      _drawerItem(
                        'FSDS MCB',
                        onTap: () {
                          context.push(AppRouter.fsdsMonitoringRoute,
                              extra: 'FSDS MCB');
                        },
                      ),
                    ],
                  ),
                _drawerItem(
                  'Hot Axle Monitoring',
                  onTap: () {
                    context.push(AppRouter.hotAxleMonitoringRoute);
                  },
                ),
                _drawerItem(
                  'BC Pressure Monitoring',
                  onTap: () {
                    context.push(AppRouter.bcPressureMonitoringRoute);
                  },
                ),
                if (!isDanapur) ...[
                  _drawerItem(
                    'Diesel Level Monitoring',
                    onTap: () {
                      context.push(AppRouter.dieselLevelMonitoringRoute);
                    },
                  ),
                  _drawerItem(
                    'Water Tank Monitoring',
                    onTap: () {
                      context.push(AppRouter.waterTankMonitoringRoute);
                    },
                  ),
                  _drawerItem(
                    'Odour Management Report',
                    onTap: () {
                      context.push(AppRouter.odourManagement);
                    },
                  ),
                  _drawerItem(
                    'Brake Binding',
                    onTap: () {
                      context.push(AppRouter.breakBinding);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerSection({
    required String title,
    IconData? icon,
    required VoidCallback onTap,
    List<Widget> children = const [],
    bool isExpanded = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          visualDensity: VisualDensity(horizontal: -2),
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 0,
          leading: icon != null ? Icon(icon, size: 16.sp) : null,
          title: Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
          trailing: children.isNotEmpty
              ? Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18.sp,
                )
              : null,
          onTap: onTap,
        ),
        if (children.isNotEmpty && isExpanded)
          Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _drawerItem(
    String label, {
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      visualDensity: VisualDensity(horizontal: -2),
      leading: icon != null ? Icon(icon, size: 18.sp) : null,
      title: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
      ),
      onTap: onTap,
    );
  }
}
