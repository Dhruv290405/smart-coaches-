import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_coach_new/features/auth/login/data/models/login_response.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/create_coach_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/delete_coach_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/edit_coach_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/create_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/delete_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/edit_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_list_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/create_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/delete_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/edit_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/create_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/delete_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/edit_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configs_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/create_device_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/delete_device_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/edit_device_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/create_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/delete_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/edit_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rules_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/create_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/delete_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/edit_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/all_regions_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/all_roles_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_or_reject_response.dart';
import 'package:smart_coach_new/features/user_management/data/models/general_response.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';
import 'package:smart_coach_new/features/profile/data/models/profile_response.dart';
import '../../features/reports_and_alerts/break_binding/data/models/break_binding_response.dart';
import '../../features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_filters_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_coach_history_response.dart';
import '../../features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
import '../../features/reports_and_alerts/break_binding/data/models/coach_by_location_response.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_history_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_response.dart';
import 'package:smart_coach_new/features/notifications/data/models/notifications_response.dart';
import 'api_constants.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: ApiConstants.devUrl)
// @RestApi(baseUrl: "https://smartcoachez.com/smart_coach_api/api")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST(ApiConstants.registerApiEndpoint)
  Future<RegisterResponse> register(@Body() Map<String, dynamic> body);

  @POST('/auth/send-otp')
  Future<dynamic> sendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-otp')
  Future<dynamic> verifyOtp(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.loginApiEndpoint)
  @Extra({'requiresAuth': false})
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.getZonesApiEndpoint)
  @Extra({'requiresAuth': false})
  Future<ZoneListResponse> getZones();

  @GET(ApiConstants.getGetDivisionsApiEndpoint)
  @Extra({'requiresAuth': false})
  Future<DivisionListResponse> getDivisions(@Query("zone_id") int zoneId);

  @GET(ApiConstants.getGetRegionsApiEndpoint)
  @Extra({'requiresAuth': false})
  Future<RegionListResponse> getRegions(@Query("division_id") int divisionId);

  // @GET("/masters/roles")
  // @Extra({'requiresAuth': false})
  // Future<RoleListResponse> getRoles(
  //   @Query("organisation_type") String organisationType,
  // );

  @GET("/roles")
  @Extra({'requiresAuth': false})
  Future<RoleListResponse> getDefaultRoles(
      @Query("zone_id") int? zoneId,
      @Query("division_id") int? divisionId,
      @Query("region_id", encoded: true) String? regionId,
      @Query("train_ids", encoded: true) String? trainIds,
      );

  @GET("/roles")
  Future<RoleListResponse> getDefaultRolesWithToken(
      @Query("zone_id") int? zoneId,
      @Query("division_id") int? divisionId,
      @Query("region_id", encoded: true) String? regionId,
      @Query("train_ids", encoded: true) String? trainIds,
      );

  @GET("/roles/get-all-roles")
  @Extra({'requiresAuth': false})
  Future<AllRolesResponse> getAllRoles();

  @GET("/trains/getAllTrains")
  @Extra({'requiresAuth': false})
  Future<TrainListResponse> getTrains(
      @Query("targer_user_id") int? targetUserId,
      @Query("zone_id") int? zoneId,
      @Query("division_id") int? divisionId,
      @Query("region_id", encoded: true) String? regionId,
      );

  @GET("/trains/getAllTrains")
  Future<TrainListResponse> getTrainsWithToken(
      @Query("targer_user_id") int? targetUserId,
      @Query("zone_id") int? zoneId,
      @Query("division_id") int? divisionId,
      @Query("region_id", encoded: true) String? regionId,
      );

  // @GET("/trains/usertrains")
  // Future<UserTrainResponse> getUserTrains(@Query("user_id") int? userId);

  @GET("/auth/users/pending")
  Future<UserManagementResponse> getPendingUsers(
      @Query("user_id") int userId, {
        @Query("status") String? status,
        @Query("organisation_type") String? organisationType,
        @Query("from_date") String? fromDate,
        @Query("to_date") String? toDate,
      });

  @GET("/auth/users/pending")
  Future<UserManagementResponse> getPendingUsersNew(
      @Query("user_id") int userId,
      @Queries() Map<String, dynamic>? queryParams,
      );

  @PUT("/auth/users/approve")
  Future<ApproveOrRejectResponse> approveUser(
      @Query("user_id") int userId,
      @Body() Map<String, dynamic> body,
      );

  @PUT("/auth/users/approve")
  Future<GeneralResponse> changeRole(@Body() Map<String, dynamic> body);

  @GET("/auth/profile")
  Future<ProfileResponse> getProfile();

  @PUT("/trains/update/usertrains")
  Future<GeneralResponse> changeTrain(@Body() Map<String, dynamic> body);

  @PUT("/auth/users/approve/bulk")
  Future<ApproveOrRejectResponse> approveBulkUser(
      @Query("user_id") int userId,
      @Body() Map<String, dynamic> body,
      );

  @GET(ApiConstants.devicesApiEndpoint)
  Future<DeviceListResponse> getDeviceList();

  @POST(ApiConstants.devicesApiEndpoint)
  Future<CreateDeviceConfigurationResponse> createDeviceConfiguration(
      @Body() Map<String, dynamic> body,
      );

  @PUT('${ApiConstants.devicesApiEndpoint}/{device_id}')
  Future<EditDeviceConfigurationResponse> editDeviceConfiguration(
      @Path("device_id") String? deviceId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.devicesApiEndpoint}/{device_id}')
  Future<DeleteDeviceConfigurationResponse> deleteDeviceConfiguration(
      @Path("device_id") String? deviceId,
      );

  @GET("/sensors/categories")
  Future<SensorCategoryListResponse> getCategories();

  @GET("/sensors/categories/{category_id}/units")
  Future<SiUnitListResponse> getSiUnits(@Path("category_id") int? categoryId);

  @GET(ApiConstants.sensorsApiEndpoint)
  Future<SensorListResponse> getSensorList();

  @POST(ApiConstants.sensorsApiEndpoint)
  Future<CreateSensorTypeConfigurationResponse> createSensorTypeConfiguration(
      @Body() Map<String, dynamic> body,
      );

  @PUT('${ApiConstants.sensorsApiEndpoint}/{sensor_id}')
  Future<EditSensorTypeConfigurationResponse> editSensorTypeConfiguration(
      @Path("sensor_id") int? sensorId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.sensorsApiEndpoint}/{sensor_id}')
  Future<DeleteSensorTypeConfigurationResponse> deleteSensorTypeConfiguration(
      @Path("sensor_id") int? sensorId,
      );

  @GET(ApiConstants.rulesApiEndpoint)
  Future<RulesListResponse> getRulesList();

  @POST(ApiConstants.rulesApiEndpoint)
  Future<CreateRuleConfigurationResponse> createRuleConfiguration(
      @Body() Map<String, dynamic> body,
      );

  @PUT('${ApiConstants.rulesApiEndpoint}/{rule_id}')
  Future<EditRuleConfigurationResponse> editRuleConfiguration(
      @Path("rule_id") int? ruleId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.rulesApiEndpoint}/{rule_id}')
  Future<DeleteRuleConfigurationResponse> deleteRuleConfiguration(
      @Path("rule_id") int? ruleId,
      );

  @GET("${ApiConstants.rulesApiEndpoint}/alert-types")
  Future<AlertTypeResponse> getAlertTypes();

  @GET("${ApiConstants.masterModulesApiEndpoint}/user")
  Future<MasterModuleListResponse> getMasterModuleList();

  @POST(ApiConstants.masterModulesApiEndpoint)
  Future<CreateMasterModuleConfigurationResponse>
  createMasterModuleConfiguration(@Body() Map<String, dynamic> body);

  @PUT('${ApiConstants.masterModulesApiEndpoint}/{module_id}')
  Future<EditMasterModuleConfigurationResponse> editMasterModuleConfiguration(
      @Path("module_id") int? moduleId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.masterModulesApiEndpoint}/{module_id}')
  Future<DeleteMasterModuleConfigurationResponse>
  deleteMasterModuleConfiguration(@Path("module_id") int? moduleId);

  @GET(ApiConstants.trainConfigsApiEndpoint)
  Future<TrainConfigsListResponse> getTrainList();

  @GET(ApiConstants.trainConfigsApiEndpoint)
  Future<TrainListResponseForBreakBinding> getTrainListBasic();

  @GET("/coaches/coachfortrain")
  Future<CoachListResponseForBreakBinding> getCoachListBasic(@Query("train_id") int? trainId);

  @GET("/trains/getTrainsForUsers")
  Future<TrainListResponseForReport> getTrainListForReport();

  @GET("/coaches/coachfortrain")
  Future<CoachListResponseForReport> getCoachesForReport(@Query("train_id") int? trainId);

  @GET("/sensors/watersensorsforcoach")
  Future<SensorListResponseForReport> getSensorsForReport(@Query("coach_id") int? trainId);

  @POST(ApiConstants.trainConfigsApiEndpoint)
  Future<CreateTrainConfigurationResponse> createTrainConfiguration(
      @Body() Map<String, dynamic> body,
      );

  @PUT('${ApiConstants.trainConfigsApiEndpoint}/{train_id}')
  Future<EditTrainConfigurationResponse> editTrainConfiguration(
      @Path("train_id") int? trainId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.trainConfigsApiEndpoint}/{train_id}')
  Future<DeleteTrainConfigurationResponse> deleteTrainConfiguration(
      @Path("train_id") int? trainId,
      );

  @GET(ApiConstants.coachesApiEndpoint)
  Future<CoachListResponse> getCoachList();

  @POST(ApiConstants.coachesApiEndpoint)
  Future<CreateCoachConfigurationResponse> createCoachConfiguration(
      @Body() Map<String, dynamic> body,
      );

  @PUT('${ApiConstants.coachesApiEndpoint}/{coach_id}')
  Future<EditCoachConfigurationResponse> editCoachConfiguration(
      @Path("coach_id") int? coachId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('${ApiConstants.coachesApiEndpoint}/{coach_id}')
  Future<DeleteCoachConfigurationResponse> deleteCoachConfiguration(
      @Path("coach_id") int? coachId,
      );

  @GET(ApiConstants.sensorConfigsApiEndpoint)
  Future<SensorDeviceListResponse> getSensorDeviceList();

  @POST(ApiConstants.sensorConfigsApiEndpoint)
  Future<CreateSensorDeviceConfigurationResponse>
  createSensorDeviceConfiguration(@Body() Map<String, dynamic> body);

  @PUT('${ApiConstants.sensorConfigsApiEndpoint}/{sensor_id}')
  Future<EditSensorDeviceConfigurationResponse> editSensorDeviceConfiguration(
      @Path("sensor_id") int? sensorId,
      @Body() Map<String, dynamic> body,
      );

  @DELETE('/sensors/sensors-configs/{sensor_id}')
  Future<DeleteSensorDeviceConfigurationResponse>
  deleteSensorDeviceConfiguration(@Path("sensor_id") int? sensorId);

  @GET(ApiConstants.coachMakesApiEndpoint)
  Future<CoachMakeListResponse> getCoachMakeList();

  @GET(ApiConstants.coachTypesApiEndpoint)
  Future<CoachTypeListResponse> getCoachTypeList();

  @GET(ApiConstants.sensorMakesApiEndpoint)
  Future<SensorMakeListResponse> getSensorMakeList();

  @GET(ApiConstants.allRegionsApiEndpoint)
  Future<AllRegionListResponse> getAllRegions();

  @GET(ApiConstants.allStationsApiEndpoint)
  Future<StationListResponse> getAllStations();

  @GET("${ApiConstants.masterModulesApiEndpoint}/coach")
  Future<MasterModuleListResponse> getMasterModulesForCoach(@Query("coach_id") int coachId);

  @GET(ApiConstants.acpLogsApiEndpoint)
  Future<AcpLogResponse> getAcpLogs();
  
  @GET(ApiConstants.acpSummaryApiEndpoint)
  Future<AcpLogResponse> getAcpSummary();

  @GET(ApiConstants.acpFiltersApiEndpoint)
  Future<AcpFiltersResponse> getAcpFilters(
    @Query("trainNo") String? trainNo,
    @Query("coachType") String? coachType,
  );

  @GET(ApiConstants.acpFilteredLogsApiEndpoint)
  Future<AcpLogResponse> getAcpFilteredLogs(
    @Query("trainNo") String? trainNo,
    @Query("techCoachNo") String? techCoachNo,
  );

  @GET(ApiConstants.acpCoachHistoryApiEndpoint)
  Future<AcpCoachHistoryResponse> getAcpCoachHistory(
    @Query("coachNo") String coachId,
    @Query("fromDate") String? fromDate,
    @Query("toDate") String? toDate,
  );



  @GET(ApiConstants.pneumaticCoachesByLocationApiEndpoint)
  Future<CoachByLocationResponse> getPneumaticCoachesByLocation();

  @GET(ApiConstants.pneumaticStatusApiEndpoint)
  Future<PneumaticStatusResponse> getPneumaticStatus(
      @Query("train_no") String? trainNo,
      @Query("coach_no") String? coachNo,
      @Query("deviceId") String? deviceId,
      @Query("from_date") String? fromDate,
      @Query("to_date") String? toDate,
      @Query("limit") int? limit,
      );

  @GET("${ApiConstants.coachConfigApiEndpoint}/{coach_no}")
  Future<CoachConfigResponse> getCoachConfig(@Path("coach_no") String coachNo);

  @POST(ApiConstants.fsdsReceiveDataApiEndpoint)
  Future<dynamic> postFsdsData(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.hotAxleReceiveDataApiEndpoint)
  Future<dynamic> postHotAxleData(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.hotAxleGetDataApiEndpoint)
  Future<HotAxleResponse> getHotAxleData(
    @Query("trainNo") String? trainNo,
    @Query("deviceId") String? deviceId,
  );

  @GET(ApiConstants.hotAxleFiltersApiEndpoint)
  Future<dynamic> getHotAxleFilters();

  @GET(ApiConstants.hotAxleDashboardApiEndpoint)
  Future<HotAxleDashboardResponse> getHotAxleDashboard(
    @Query("trainNo") String? trainNo,
    @Query("deviceId") String? deviceId,
    @Query("coachType") String? coachType,
    @Query("owningRly") String? owningRly,
    @Query("coachNumber") String? coachNumber,
  );

  @GET(ApiConstants.hotAxleHistoryApiEndpoint)
  Future<HotAxleHistoryResponse> getHotAxleHistory(
    @Query("coachNumber") String coachNumber,
    @Query("startDate") String startDate,
    @Query("endDate") String endDate,
    @Query("page") int page,
  );

  @GET(ApiConstants.bcPressureGetDataApiEndpoint)
  Future<BcPressureResponse> getBcPressureData(
    @Query("trainNo") String? trainNo,
    @Query("deviceId") String? deviceId,
  );

  @POST(ApiConstants.pressureReceiveDataApiEndpoint)
  Future<dynamic> postPressureData(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.wliReceiveDataApiEndpoint)
  Future<dynamic> postWliData(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.notificationsApiEndpoint)
  Future<NotificationsResponse> getNotifications(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @PATCH('${ApiConstants.notificationsApiEndpoint}/{id}/read')
  Future<GeneralResponse> markNotificationAsRead(@Path('id') int id);

  @PUT(ApiConstants.markAllNotificationsReadApiEndpoint)
  Future<GeneralResponse> markAllNotificationsAsRead();

  @DELETE('${ApiConstants.notificationsApiEndpoint}/{id}')
  Future<GeneralResponse> deleteNotification(@Path('id') int id);
}
