import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_state.dart';
import 'package:smart_coach_new/core/permissions/role_permissions.dart';

@singleton
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionState.initial()) {
    on<InitializePermissions>(_onInitializePermissions);
    on<UpdatePermissions>(_onUpdatePermissions);
    on<ClearPermissions>(_onClearPermissions);
  }

  void _onInitializePermissions(
    InitializePermissions event,
    Emitter<PermissionState> emit,
  ) {
    final permissions = RolePermissions.getPermissionsForRole(event.roleId);
    emit(state.copyWith(
      roleId: event.roleId,
      roleName: event.roleName,
      permissions: permissions,
      isInitialized: true,
    ));
  }

  void _onUpdatePermissions(
    UpdatePermissions event,
    Emitter<PermissionState> emit,
  ) {
    final permissions = RolePermissions.getPermissionsForRole(event.roleId);
    emit(state.copyWith(
      roleId: event.roleId,
      roleName: event.roleName,
      permissions: permissions,
      isInitialized: true,
    ));
  }

  void _onClearPermissions(
    ClearPermissions event,
    Emitter<PermissionState> emit,
  ) {
    emit(PermissionState.initial());
  }

  /// Helper methods for easy permission checking

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return state.permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => state.permissions.contains(permission));
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => state.permissions.contains(permission));
  }

  /// Check if user has a specific role
  bool hasRole(int roleId) {
    return state.roleId == roleId;
  }

  /// Check if user has any of the given roles
  bool hasAnyRole(List<int> roleIds) {
    return state.roleId != null && roleIds.contains(state.roleId);
  }

  /// Get current role ID
  int? get currentRoleId => state.roleId;

  /// Get current role name
  String? get currentRoleName => state.roleName;

  /// Check if permissions are initialized
  bool get isInitialized => state.isInitialized;
}
