class PermissionConstants {
  static const String canViewUserRegistration = 'can_view_user_registration';
  static const String canApproveUsers = 'can_approve_users';
  static const String canEditUsers = 'can_edit_users';
  static const String canDeleteUsers = 'can_delete_users';

  static const String canViewTrainConfiguration = 'can_view_train_configuration';
  static const String canEditTrainConfiguration = 'can_edit_train_configuration';
  static const String canViewCoachConfiguration = 'can_view_coach_configuration';
  static const String canEditCoachConfiguration = 'can_edit_coach_configuration';
  static const String canViewSensorConfiguration = 'can_view_sensor_configuration';
  static const String canEditSensorConfiguration = 'can_edit_sensor_configuration';

  static const String canViewDeviceManagement = 'can_view_device_management';
  static const String canEditDeviceManagement = 'can_edit_device_management';

  static const String canViewAllReports = 'can_view_all_reports';
  static const String canViewOwnReports = 'can_view_own_reports';
  static const String canExportReports = 'can_export_reports';

  static const String canViewDashboard = 'can_view_dashboard';
  static const String canViewAnalytics = 'can_view_analytics';

  static const String canEditOwnProfile = 'can_edit_own_profile';
  static const String canViewProfile = 'can_view_profile';
}

class RoleIds {
  static const int superAdmin = 1;
  static const int master = 2;
  static const int regionalMaster = 3;
  static const int trainOperator = 4;
}

class RoleNames {
  static const String superAdmin = 'Super Admin';
  static const String master = 'Master';
  static const String regionalMaster = 'Regional Master';
  static const String trainOperator = 'Train Operator';
}
