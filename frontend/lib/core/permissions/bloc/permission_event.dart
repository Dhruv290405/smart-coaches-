import 'package:equatable/equatable.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();
}

/// Initialize permissions based on user role
class InitializePermissions extends PermissionEvent {
  final int roleId;
  final String? roleName;

  const InitializePermissions({
    required this.roleId,
    this.roleName,
  });

  @override
  List<Object?> get props => [roleId, roleName];
}

/// Update permissions when role changes
class UpdatePermissions extends PermissionEvent {
  final int roleId;
  final String? roleName;

  const UpdatePermissions({
    required this.roleId,
    this.roleName,
  });

  @override
  List<Object?> get props => [roleId, roleName];
}

/// Clear all permissions (on logout)
class ClearPermissions extends PermissionEvent {
  const ClearPermissions();

  @override
  List<Object?> get props => [];
}
