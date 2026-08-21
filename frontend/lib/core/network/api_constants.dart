class ApiConstants {
  static const String loginApiEndpoint = '/auth/login';
  static const String registerApiEndpoint = '/auth/register';
  static const String getZonesApiEndpoint = '/masters/zones';
  static const String getGetDivisionsApiEndpoint = '/masters/divisions';
  static const String getGetRegionsApiEndpoint = '/masters/regions';
  static const String getGetRolesApiEndpoint = '/masters/roles';
  static const String getApprovalListApiEndpoint = '/auth/users/pending';
  static const String approveUserApiEndpoint = '/auth/users';
  static const String acpLogsApiEndpoint = '/acp/logs';
  static const String acpSummaryApiEndpoint = '/acp/summary';
  static const String acpFiltersApiEndpoint = '/acp/filters';
  static const String acpFilteredLogsApiEndpoint = '/acp/filtered-logs';
  static const String acpCoachHistoryApiEndpoint = '/acp/coach-history';
  static const String pneumaticStatusApiEndpoint = '/pneumatic/status';
  static const String pneumaticCoachesByLocationApiEndpoint = '/pneumatic/coaches-by-location';
  static const String trainConfigsApiEndpoint = '/trains';
  static const String coachesApiEndpoint = '/coaches';
  static const String sensorConfigsApiEndpoint = '/sensors-config';
  static const String devicesApiEndpoint = '/devices';
  static const String sensorsApiEndpoint = '/sensors';
  static const String rulesApiEndpoint = '/rules';
  static const String masterModulesApiEndpoint = '/master-modules';
  static const String allRegionsApiEndpoint = '/regions';
  static const String allStationsApiEndpoint = '/stations';
  static const String coachMakesApiEndpoint = '/coach-makes';
  static const String coachTypesApiEndpoint = '/coach-types';
  static const String sensorMakesApiEndpoint = '/sensors-make';
  static const String odourReceiveDataApiEndpoint = '/odour-logs/receive-data';
  static const String odourCoachesApiEndpoint = '/odour-logs/coaches';
  static const String odourSection2ApiEndpoint = '/odour-logs/section2-coaches';
  static const String odourHistoryApiEndpoint = '/odour-logs/history';
  static const String fsdsReceiveDataApiEndpoint = '/fsds/receive-data';
  static const String fsdsGetDataApiEndpoint = '/fsds/get-data';
  static const String fsdsBaseUrl = 'https://api.vaspsystemic.com/smart_coach_api/api';
  static const String coachConfigApiEndpoint = '/coach-config';
  static const String hotAxleReceiveDataApiEndpoint = '/hot-axle/receive-data';
  static const String hotAxleGetDataApiEndpoint = '/hot-axle/get-data';
  static const String hotAxleDashboardApiEndpoint = '/hot-axle/dashboard-status';
  static const String hotAxleFiltersApiEndpoint = '/hot-axle/filters';
  static const String hotAxleHistoryApiEndpoint = '/hot-axle/history';
  static const String bcPressureGetDataApiEndpoint = '/pressure/dashboard-status';
  static const String pressureReceiveDataApiEndpoint = '/pressure/receive-data';
  static const String wliReceiveDataApiEndpoint = '/wli/receive-data';
  static const String wliCoachesApiEndpoint = '/wli/coaches';
  static const String dieselReadingsApiEndpoint = '/diesel/readings';
  static const String dieselHistoryApiEndpoint = '/diesel/history';
  static const String notificationsApiEndpoint = '/notifications';
  static const String markAllNotificationsReadApiEndpoint = '/notifications/mark-all-read';
  static const String notificationLimitDefault = '10';

  //API PARAMETERS
  static const String email = 'email';
  static const String password = 'password';
  static const String userId = 'user_id';

  static const String healthApiEndpoint = '/health';

  // ─── URL CONFIGURATION ────────────────────────────────────────────────────
  // PRODUCTION: deployed Railway backend
  static const String devUrl =
      'https://api.vaspsystemic.com/smart_coach_api/api'; // Railway backend - Supabase

  // LOCAL: comment above and uncomment below to use local backend (port 3000)
  // static const String devUrl = 'http://10.0.2.2:3000/smart_coach_api/api';   // Android emulator
  // static const String devUrl = 'http://localhost:3000/smart_coach_api/api';  // Web / iOS sim
}
