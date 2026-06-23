import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';

import 'bloc/permission_state.dart';

class PermissionGuard extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final int? roleId;
  final List<int>? roleIds;
  final bool requireAll;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    this.permission,
    this.permissions,
    this.roleId,
    this.roleIds,
    this.requireAll = false,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        final permissionBloc = context.read<PermissionBloc>();
        bool hasAccess = false;

        if (roleId != null) {
          hasAccess = permissionBloc.hasRole(roleId!);
        } else if (roleIds != null && roleIds!.isNotEmpty) {
          hasAccess = permissionBloc.hasAnyRole(roleIds!);
        }
        else if (permission != null) {
          hasAccess = permissionBloc.hasPermission(permission!);
        } else if (permissions != null && permissions!.isNotEmpty) {
          if (requireAll) {
            hasAccess = permissionBloc.hasAllPermissions(permissions!);
          } else {
            hasAccess = permissionBloc.hasAnyPermission(permissions!);
          }
        }

        if (hasAccess) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

extension PermissionExtension on BuildContext {
  PermissionBloc get permissionBloc => read<PermissionBloc>();

  bool hasPermission(String permission) {
    return permissionBloc.hasPermission(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissionBloc.hasAnyPermission(permissions);
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissionBloc.hasAllPermissions(permissions);
  }

  bool hasRole(int roleId) {
    return permissionBloc.hasRole(roleId);
  }

  bool hasAnyRole(List<int> roleIds) {
    return permissionBloc.hasAnyRole(roleIds);
  }

  int? get currentRoleId => permissionBloc.currentRoleId;

  String? get currentRoleName => permissionBloc.currentRoleName;
}
