import 'package:equatable/equatable.dart';

class PermissionState extends Equatable {
  final int? roleId;
  final String? roleName;
  final Set<String> permissions;
  final bool isInitialized;

  const PermissionState({
    this.roleId,
    this.roleName,
    this.permissions = const {},
    this.isInitialized = false,
  });

  factory PermissionState.initial() => const PermissionState();

  PermissionState copyWith({
    int? roleId,
    String? roleName,
    Set<String>? permissions,
    bool? isInitialized,
  }) {
    return PermissionState(
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? this.permissions,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [roleId, roleName, permissions, isInitialized];
}
