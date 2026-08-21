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

const Map<String, List<String>> _divisionModuleMap = {
  'Danapur': ['acp', 'hot_axle_section2', 'bc_pressure', 'sensor_config', 'odour'],
  'Nagpur': ['brake_binding', 'hot_axle_section1', 'sensor_config', 'odour'],
  'Howrah': ['brake_binding', 'odour'],
  'Kolkata': ['brake_binding', 'odour'],
  'South Eastern': ['brake_binding', 'odour'],
  'Jaipur': ['brake_binding'],
};

String _moduleKeyFor(String label) {
  if (label.contains('Coach Dashboard')) return 'coach_dashboard';
  if (label.contains('ACP')) return 'acp';
  if (label.contains('FSDS')) return 'fsds';
  if (label.contains('Hot Axle')) return 'hot_axle';
  if (label.contains('BC Pressure')) return 'bc_pressure';
  if (label.contains('Diesel')) return 'diesel';
  if (label.contains('Water Tank')) return 'water_tank';
  if (label.contains('Odour')) return 'odour';
  if (label.contains('Brake Binding')) return 'brake_binding';
  return '';
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

    final divisionName = user?.divisionName;
    final allowedModules = divisionName != null
        ? (_divisionModuleMap.entries
            .firstWhere(
              (e) => e.key.toLowerCase() == divisionName.toLowerCase(),
              orElse: () => const MapEntry('', <String>[]),
            )
            .value)
        : null;

    bool isModuleAllowed(String label) {
      if (allowedModules == null || allowedModules.isEmpty) return true;
      final key = _moduleKeyFor(label);
      if (key == 'hot_axle') {
        return allowedModules.contains('hot_axle') ||
               allowedModules.contains('hot_axle_section1') ||
               allowedModules.contains('hot_axle_section2');
      }
      return allowedModules.contains(key);
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          children: [
            if (context.hasAnyPermission([
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
                  if (context.hasPermission(PermissionConstants.canCreateUsers))
                    _drawerItem(
                      'User Registration',
                      icon: Icons.app_registration,
                      onTap: () {
                        context.push(AppRouter.registerRoute);
                      },
                    ),
                  if (context.hasPermission(PermissionConstants.canApproveUsers))
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
                if (isModuleAllowed('Coach Dashboard'))
                  _drawerItem(
                    'Coach Dashboard',
                    icon: Icons.dashboard_customize_outlined,
                    onTap: () {
                      context.push(AppRouter.coachDashboardRoute);
                    },
                  ),
                if (isModuleAllowed('ACP Monitoring'))
                  _drawerItem(
                    'ACP Monitoring',
                    onTap: () {
                      context.push(AppRouter.acpMonitoringRoute);
                    },
                  ),
                if (isModuleAllowed('FSDS'))
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
                if (isModuleAllowed('Hot Axle Monitoring'))
                  _drawerItem(
                    'Hot Axle Monitoring',
                    onTap: () {
                      context.push(AppRouter.hotAxleMonitoringRoute);
                    },
                  ),
                if (isModuleAllowed('BC Pressure'))
                  _drawerItem(
                    'BC Pressure Monitoring',
                    onTap: () {
                      context.push(AppRouter.bcPressureMonitoringRoute);
                    },
                  ),
                if (isModuleAllowed('Diesel'))
                  _drawerItem(
                    'Diesel Level Monitoring',
                    onTap: () {
                      context.push(AppRouter.dieselLevelMonitoringRoute);
                    },
                  ),
                if (isModuleAllowed('Water Tank'))
                  _drawerItem(
                    'Water Tank Monitoring',
                    onTap: () {
                      context.push(AppRouter.waterTankMonitoringRoute);
                    },
                  ),
                if (isModuleAllowed('Odour'))
                  _drawerItem(
                    'Odour Management Report',
                    onTap: () {
                      context.push(AppRouter.odourManagement);
                    },
                  ),
                if (isModuleAllowed('Brake Binding'))
                  _drawerItem(
                    'Brake Binding',
                    onTap: () {
                      context.push(AppRouter.breakBinding);
                    },
                  ),
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
