import 'permission_constants.dart';

class RolePermissions {
  static Set<String> getPermissionsForRole(int roleId) {
    switch (roleId) {
      case RoleIds.masterAdmin:
        return _masterAdminPermissions;
      case RoleIds.superAdmin:
        return _superAdminPermissions;
      case RoleIds.admin:
        return _adminPermissions;
      case RoleIds.manager:
        return _managerPermissions;
      case RoleIds.editor:
        return _editorPermissions;
      case RoleIds.regionOperator:
        return _regionOperatorPermissions;
      case RoleIds.trainOperator:
        return _trainOperatorPermissions;
      default:
        return {};
    }
  }

  static final Set<String> _masterAdminPermissions = {
    PermissionConstants.canViewUserRegistration,
    PermissionConstants.canApproveUsers,
    PermissionConstants.canEditUsers,
    PermissionConstants.canDeleteUsers,
    PermissionConstants.canCreateUsers,
    PermissionConstants.canManageRoles,

    PermissionConstants.canViewTrainConfiguration,
    PermissionConstants.canEditTrainConfiguration,
    PermissionConstants.canViewCoachConfiguration,
    PermissionConstants.canEditCoachConfiguration,
    PermissionConstants.canViewSensorConfiguration,
    PermissionConstants.canEditSensorConfiguration,

    PermissionConstants.canViewDeviceManagement,
    PermissionConstants.canEditDeviceManagement,

    PermissionConstants.canViewAllReports,
    PermissionConstants.canExportReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _superAdminPermissions = {
    PermissionConstants.canViewUserRegistration,
    PermissionConstants.canApproveUsers,
    PermissionConstants.canEditUsers,
    PermissionConstants.canDeleteUsers,
    PermissionConstants.canCreateUsers,

    PermissionConstants.canViewTrainConfiguration,
    PermissionConstants.canEditTrainConfiguration,
    PermissionConstants.canViewCoachConfiguration,
    PermissionConstants.canEditCoachConfiguration,
    PermissionConstants.canViewSensorConfiguration,
    PermissionConstants.canEditSensorConfiguration,

    PermissionConstants.canViewDeviceManagement,
    PermissionConstants.canEditDeviceManagement,

    PermissionConstants.canViewAllReports,
    PermissionConstants.canExportReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _adminPermissions = {
    PermissionConstants.canViewUserRegistration,
    PermissionConstants.canApproveUsers,
    PermissionConstants.canEditUsers,
    PermissionConstants.canCreateUsers,

    PermissionConstants.canViewTrainConfiguration,
    PermissionConstants.canEditTrainConfiguration,
    PermissionConstants.canViewCoachConfiguration,
    PermissionConstants.canEditCoachConfiguration,
    PermissionConstants.canViewSensorConfiguration,
    PermissionConstants.canEditSensorConfiguration,

    PermissionConstants.canViewDeviceManagement,
    PermissionConstants.canEditDeviceManagement,

    PermissionConstants.canViewAllReports,
    PermissionConstants.canExportReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _managerPermissions = {
    PermissionConstants.canViewUserRegistration,
    PermissionConstants.canApproveUsers,
    PermissionConstants.canEditUsers,
    PermissionConstants.canCreateUsers,

    PermissionConstants.canViewTrainConfiguration,
    PermissionConstants.canViewCoachConfiguration,
    PermissionConstants.canViewSensorConfiguration,

    PermissionConstants.canViewDeviceManagement,

    PermissionConstants.canViewAllReports,
    PermissionConstants.canExportReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _editorPermissions = {
    PermissionConstants.canViewUserRegistration,
    PermissionConstants.canApproveUsers,
    PermissionConstants.canEditUsers,
    PermissionConstants.canCreateUsers,

    PermissionConstants.canViewTrainConfiguration,
    PermissionConstants.canViewCoachConfiguration,
    PermissionConstants.canViewSensorConfiguration,

    PermissionConstants.canViewDeviceManagement,

    PermissionConstants.canViewAllReports,
    PermissionConstants.canExportReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _regionOperatorPermissions = {
    PermissionConstants.canViewOwnReports,

    PermissionConstants.canViewDashboard,
    PermissionConstants.canViewAnalytics,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static final Set<String> _trainOperatorPermissions = {
    PermissionConstants.canViewOwnReports,

    PermissionConstants.canViewDashboard,

    PermissionConstants.canEditOwnProfile,
    PermissionConstants.canViewProfile,
  };

  static bool hasPermission(int roleId, String permission) {
    final permissions = getPermissionsForRole(roleId);
    return permissions.contains(permission);
  }

  static bool hasAnyPermission(int roleId, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(roleId);
    return permissions.any((permission) => rolePermissions.contains(permission));
  }

  static bool hasAllPermissions(int roleId, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(roleId);
    return permissions.every((permission) => rolePermissions.contains(permission));
  }
}
