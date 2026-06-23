// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:smart_coach_new/core/di/injectable.dart' as _i152;
import 'package:smart_coach_new/core/network/api_client.dart' as _i689;
import 'package:smart_coach_new/core/network/rest_client.dart' as _i100;
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart'
    as _i416;
import 'package:smart_coach_new/core/utils/prefs.dart' as _i1038;
import 'package:smart_coach_new/features/auth/login/data/datasources/login_remote_data_source.dart'
    as _i563;
import 'package:smart_coach_new/features/auth/login/domain/repositories/login_repository.dart'
    as _i954;
import 'package:smart_coach_new/features/auth/login/domain/repositories/login_repository_impl.dart'
    as _i461;
import 'package:smart_coach_new/features/auth/login/domain/usecases/login_usecase.dart'
    as _i259;
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_bloc.dart'
    as _i401;
import 'package:smart_coach_new/features/auth/register/data/datasources/register_remote_data_source.dart'
    as _i914;
import 'package:smart_coach_new/features/auth/register/domain/repositories/register_repository.dart'
    as _i725;
import 'package:smart_coach_new/features/auth/register/domain/repositories/register_repository_impl.dart'
    as _i455;
import 'package:smart_coach_new/features/auth/register/domain/usecases/register_usecase.dart'
    as _i490;
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart'
    as _i596;
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_bloc.dart'
    as _i115;
import 'package:smart_coach_new/features/configuration/coach_configuration/data/datasources/coach_configuration_remote_data_source.dart'
    as _i495;
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/repositories/coach_configuration_repository.dart'
    as _i328;
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/repositories/coach_configuration_repository_impl.dart'
    as _i566;
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart'
    as _i781;
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_bloc.dart'
    as _i603;
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/datasources/master_module_configuration_remote_data_source.dart'
    as _i1069;
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/repositories/master_module_configuration_repository.dart'
    as _i550;
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/repositories/master_module_configuration_repository_impl.dart'
    as _i359;
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/usecases/master_module_configuration_usecase.dart'
    as _i423;
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_bloc.dart'
    as _i75;
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/datasources/sensor_device_configuration_remote_data_source.dart'
    as _i56;
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/repositories/sensor_device_configuration_repository.dart'
    as _i677;
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/repositories/sensor_device_configuration_repository_impl.dart'
    as _i469;
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/usecases/sensor_device_configuration_usecase.dart'
    as _i1056;
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart'
    as _i225;
import 'package:smart_coach_new/features/configuration/train_configuration/data/datasources/train_configuration_remote_data_source.dart'
    as _i519;
import 'package:smart_coach_new/features/configuration/train_configuration/domain/repositories/train_configuration_repository.dart'
    as _i953;
import 'package:smart_coach_new/features/configuration/train_configuration/domain/repositories/train_configuration_repository_impl.dart'
    as _i793;
import 'package:smart_coach_new/features/configuration/train_configuration/domain/usecases/train_configuration_usecase.dart'
    as _i406;
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_bloc.dart'
    as _i519;
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i461;
import 'package:smart_coach_new/features/device_management/device_configuration/data/datasources/device_configuration_remote_data_source.dart'
    as _i983;
import 'package:smart_coach_new/features/device_management/device_configuration/domain/repositories/device_configuration_repository.dart'
    as _i580;
import 'package:smart_coach_new/features/device_management/device_configuration/domain/repositories/device_configuration_repository_impl.dart'
    as _i901;
import 'package:smart_coach_new/features/device_management/device_configuration/domain/usecases/device_configuration_usecase.dart'
    as _i258;
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_bloc.dart'
    as _i616;
import 'package:smart_coach_new/features/device_management/rule_configuration/data/datasources/rule_configuration_remote_data_source.dart'
    as _i883;
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/repositories/rule_configuration_repository.dart'
    as _i782;
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/repositories/rule_configuration_repository_impl.dart'
    as _i517;
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/usecases/rule_configuration_usecase.dart'
    as _i853;
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_bloc.dart'
    as _i402;
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/datasources/sensor_type_configuration_remote_data_source.dart'
    as _i691;
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart'
    as _i718;
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository_impl.dart'
    as _i1013;
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/usecases/sensor_type_configuration_usecase.dart'
    as _i849;
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_bloc.dart'
    as _i681;
import 'package:smart_coach_new/features/drop_down_value/data/datasources/drop_down_value_remote_data_source.dart'
    as _i159;
import 'package:smart_coach_new/features/drop_down_value/domain/repositories/drop_down_value_repository.dart'
    as _i204;
import 'package:smart_coach_new/features/drop_down_value/domain/repositories/register_repository_impl.dart'
    as _i32;
import 'package:smart_coach_new/features/drop_down_value/domain/usecases/drop_down_value_usecase.dart'
    as _i685;
import 'package:smart_coach_new/features/notifications/data/datasources/notification_remote_data_source.dart'
    as _i792;
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository.dart'
    as _i668;
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository_impl.dart'
    as _i565;
import 'package:smart_coach_new/features/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i648;
import 'package:smart_coach_new/features/notifications/domain/usecases/get_notifications_usecase.dart'
    as _i597;
import 'package:smart_coach_new/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart'
    as _i17;
import 'package:smart_coach_new/features/notifications/domain/usecases/mark_notification_read_usecase.dart'
    as _i642;
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_bloc.dart'
    as _i862;
import 'package:smart_coach_new/features/profile/data/datasources/profile_remote_data_source.dart'
    as _i676;
import 'package:smart_coach_new/features/profile/data/repositories/profile_repository_impl.dart'
    as _i282;
import 'package:smart_coach_new/features/profile/domain/repositories/profile_repository.dart'
    as _i713;
import 'package:smart_coach_new/features/profile/domain/usecases/profile_usecase.dart'
    as _i489;
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_bloc.dart'
    as _i1011;
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/datasource/acp_remote_data_source.dart'
    as _i201;
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart'
    as _i626;
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/datasource/bc_pressure_remote_data_source.dart'
    as _i513;
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/repository/bc_pressure_repository.dart'
    as _i343;
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/datasource/break_binding_remote_data_source.dart'
    as _i406;
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_binding_repository_impl.dart'
    as _i352;
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_bindinng_repository.dart'
    as _i790;
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/usecases/break_binding_usecases.dart'
    as _i902;
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/presentation/bloc/break_binding_bloc.dart'
    as _i209;
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_remote_data_source.dart'
    as _i858;
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/repository/hot_axle_repository.dart'
    as _i385;
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/datasources/train_list_remote_data_source.dart'
    as _i215;
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/repositories/train_list_configuration_repository.dart'
    as _i149;
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/repositories/train_list_configuration_repository_impl.dart'
    as _i716;
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/usecases/train_list_usecase.dart'
    as _i122;
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/bloc/train_list_bloc.dart'
    as _i33;
import 'package:smart_coach_new/features/user_management/data/datasources/user_manaagement_remote_data_source.dart'
    as _i536;
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository.dart'
    as _i737;
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository_impl.dart'
    as _i491;
import 'package:smart_coach_new/features/user_management/domain/usecases/user_management_usecase.dart'
    as _i99;
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_bloc.dart'
    as _i615;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i416.PermissionBloc>(() => _i416.PermissionBloc());
    gh.lazySingleton<_i1038.Prefs>(
      () => _i1038.Prefs(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.provideDio(gh<_i1038.Prefs>()),
    );
    gh.lazySingleton<_i689.ApiClient>(
      () => _i689.ApiClient(gh<_i1038.Prefs>()),
    );
    gh.lazySingleton<_i100.RestClient>(
      () => registerModule.provideRestClient(gh<_i361.Dio>()),
    );
    gh.factory<_i513.BcPressureRemoteDataSource>(
      () => _i513.BcPressureRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i676.ProfileRemoteDataSource>(
      () => _i676.ProfileRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i201.AcpRemoteDataSource>(
      () => _i201.AcpRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i563.LoginRemoteDataSourceImpl>(
      () => _i563.LoginRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i914.RegisterRemoteDataSourceImpl>(
      () => _i914.RegisterRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i495.SensorDeviceConfigurationRemoteDataSourceImpl>(
      () => _i495.SensorDeviceConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i1069.MasterModuleConfigurationRemoteDataSourceImpl>(
      () => _i1069.MasterModuleConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i56.SensorDeviceConfigurationRemoteDataSourceImpl>(
      () => _i56.SensorDeviceConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i519.CoachConfigurationRemoteDataSourceImpl>(
      () => _i519.CoachConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i983.DeviceConfigurationRemoteDataSourceImpl>(
      () => _i983.DeviceConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i883.RuleConfigurationRemoteDataSourceImpl>(
      () => _i883.RuleConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i691.SensorTypeConfigurationRemoteDataSourceImpl>(
      () => _i691.SensorTypeConfigurationRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i159.DropDownValueRemoteDataSourceImpl>(
      () => _i159.DropDownValueRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i406.BreakBindingRemoteDataSourceImpl>(
      () => _i406.BreakBindingRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i215.TrainRemoteDataSourceImpl>(
      () => _i215.TrainRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i536.UserManagementRemoteDataSourceImpl>(
      () => _i536.UserManagementRemoteDataSourceImpl(
        gh<_i100.RestClient>(),
        gh<_i1038.Prefs>(),
      ),
    );
    gh.factory<_i954.LoginRepository>(
      () => _i461.LoginRepositoryImpl(
        remoteDataSource: gh<_i563.LoginRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i782.RuleConfigurationRepository>(
      () => _i517.RuleConfigurationRepositoryImpl(
        remoteDataSource: gh<_i883.RuleConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i725.RegisterRepository>(
      () => _i455.RegisterRepositoryImpl(
        remoteDataSource: gh<_i914.RegisterRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i550.MasterModuleConfigurationRepository>(
      () => _i359.MasterModuleConfigurationRepositoryImpl(
        remoteDataSource:
            gh<_i1069.MasterModuleConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i149.TrainListRepository>(
      () => _i716.TrainListRepositoryImpl(
        remoteDataSource: gh<_i215.TrainRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i328.SensorDeviceConfigurationRepository>(
      () => _i566.CoachConfigurationRepositoryImpl(
        remoteDataSource:
            gh<_i495.SensorDeviceConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i792.NotificationRemoteDataSource>(
      () => _i792.NotificationRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i423.MasterModuleConfigurationUseCase>(
      () => _i423.MasterModuleConfigurationUseCase(
        gh<_i550.MasterModuleConfigurationRepository>(),
      ),
    );
    gh.factory<_i737.UserManagementRepository>(
      () => _i491.UserManagementRepositoryRepositoryImpl(
        remoteDataSource: gh<_i536.UserManagementRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i953.CoachConfigurationRepository>(
      () => _i793.TrainConfigurationRepositoryImpl(
        remoteDataSource: gh<_i519.CoachConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i580.DeviceConfigurationRepository>(
      () => _i901.DeviceConfigurationRepositoryImpl(
        remoteDataSource: gh<_i983.DeviceConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i343.BcPressureRepository>(
      () => _i343.BcPressureRepositoryImpl(
        gh<_i513.BcPressureRemoteDataSource>(),
      ),
    );
    gh.factory<_i781.CoachConfigurationUseCase>(
      () => _i781.CoachConfigurationUseCase(
        gh<_i328.SensorDeviceConfigurationRepository>(),
      ),
    );
    gh.factory<_i713.ProfileRepository>(
      () => _i282.ProfileRepositoryImpl(gh<_i676.ProfileRemoteDataSource>()),
    );
    gh.factory<_i75.MasterModuleConfigurationBloc>(
      () => _i75.MasterModuleConfigurationBloc(
        masterModuleConfigurationUseCase:
            gh<_i423.MasterModuleConfigurationUseCase>(),
      ),
    );
    gh.factory<_i258.DeviceConfigurationUseCase>(
      () => _i258.DeviceConfigurationUseCase(
        gh<_i580.DeviceConfigurationRepository>(),
      ),
    );
    gh.factory<_i626.AcpRepository>(
      () => _i626.AcpRepositoryImpl(gh<_i201.AcpRemoteDataSource>()),
    );
    gh.factory<_i853.RuleConfigurationUseCase>(
      () => _i853.RuleConfigurationUseCase(
        gh<_i782.RuleConfigurationRepository>(),
      ),
    );
    gh.factory<_i858.HotAxleRemoteDataSource>(
      () => _i858.HotAxleRemoteDataSourceImpl(gh<_i100.RestClient>()),
    );
    gh.factory<_i122.TrainListUsecase>(
      () => _i122.TrainListUsecase(repository: gh<_i149.TrainListRepository>()),
    );
    gh.factory<_i718.SensorTypeConfigurationRepository>(
      () => _i1013.SensorTypeConfigurationRepositoryImpl(
        remoteDataSource:
            gh<_i691.SensorTypeConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i33.TrainListBloc>(
      () => _i33.TrainListBloc(trainListUsecase: gh<_i122.TrainListUsecase>()),
    );
    gh.factory<_i616.DeviceConfigurationBloc>(
      () => _i616.DeviceConfigurationBloc(
        deviceConfigurationUseCase: gh<_i258.DeviceConfigurationUseCase>(),
      ),
    );
    gh.factory<_i677.SensorDeviceConfigurationRepository>(
      () => _i469.SensorDeviceConfigurationRepositoryImpl(
        remoteDataSource:
            gh<_i56.SensorDeviceConfigurationRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i402.RuleConfigurationBloc>(
      () => _i402.RuleConfigurationBloc(
        ruleConfigurationUseCase: gh<_i853.RuleConfigurationUseCase>(),
      ),
    );
    gh.factory<_i204.DropDownValueRepository>(
      () => _i32.DropDownValueRepositoryImpl(
        remoteDataSource: gh<_i159.DropDownValueRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i1056.SensorDeviceConfigurationUseCase>(
      () => _i1056.SensorDeviceConfigurationUseCase(
        gh<_i677.SensorDeviceConfigurationRepository>(),
      ),
    );
    gh.factory<_i259.LoginUseCase>(
      () => _i259.LoginUseCase(gh<_i954.LoginRepository>()),
    );
    gh.factory<_i790.BreakBindinngRepository>(
      () => _i352.TrainListRepositoryImpl(
        bindingRemoteDataSourceImpl:
            gh<_i406.BreakBindingRemoteDataSourceImpl>(),
      ),
    );
    gh.factory<_i489.ProfileUseCase>(
      () => _i489.ProfileUseCase(gh<_i713.ProfileRepository>()),
    );
    gh.factory<_i115.CoachDashboardBloc>(
      () => _i115.CoachDashboardBloc(
        coachConfigurationUseCase: gh<_i781.CoachConfigurationUseCase>(),
        acpRepository: gh<_i626.AcpRepository>(),
      ),
    );
    gh.factory<_i849.SensorTypeConfigurationUseCase>(
      () => _i849.SensorTypeConfigurationUseCase(
        gh<_i718.SensorTypeConfigurationRepository>(),
      ),
    );
    gh.factory<_i385.HotAxleRepository>(
      () => _i385.HotAxleRepositoryImpl(gh<_i858.HotAxleRemoteDataSource>()),
    );
    gh.factory<_i490.RegisterUseCase>(
      () => _i490.RegisterUseCase(gh<_i725.RegisterRepository>()),
    );
    gh.factory<_i668.NotificationRepository>(
      () => _i565.NotificationRepositoryImpl(
        gh<_i792.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i99.UserManagementUseCase>(
      () => _i99.UserManagementUseCase(gh<_i737.UserManagementRepository>()),
    );
    gh.factory<_i401.LoginBloc>(
      () => _i401.LoginBloc(
        loginUseCase: gh<_i259.LoginUseCase>(),
        prefs: gh<_i1038.Prefs>(),
        permissionBloc: gh<_i416.PermissionBloc>(),
      ),
    );
    gh.factory<_i603.CoachConfigurationBloc>(
      () => _i603.CoachConfigurationBloc(
        coachConfigurationUseCase: gh<_i781.CoachConfigurationUseCase>(),
      ),
    );
    gh.factory<_i597.GetNotificationsUseCase>(
      () => _i597.GetNotificationsUseCase(gh<_i668.NotificationRepository>()),
    );
    gh.factory<_i17.MarkAllNotificationsReadUseCase>(
      () => _i17.MarkAllNotificationsReadUseCase(
        gh<_i668.NotificationRepository>(),
      ),
    );
    gh.factory<_i642.MarkNotificationReadUseCase>(
      () =>
          _i642.MarkNotificationReadUseCase(gh<_i668.NotificationRepository>()),
    );
    gh.factory<_i648.DeleteNotificationUseCase>(
      () => _i648.DeleteNotificationUseCase(gh<_i668.NotificationRepository>()),
    );
    gh.factory<_i406.CoachConfigurationUseCase>(
      () => _i406.CoachConfigurationUseCase(
        gh<_i953.CoachConfigurationRepository>(),
      ),
    );
    gh.factory<_i461.DashboardBloc>(
      () => _i461.DashboardBloc(
        gh<_i626.AcpRepository>(),
        gh<_i953.CoachConfigurationRepository>(),
        gh<_i328.SensorDeviceConfigurationRepository>(),
        gh<_i580.DeviceConfigurationRepository>(),
        gh<_i718.SensorTypeConfigurationRepository>(),
        gh<_i790.BreakBindinngRepository>(),
      ),
    );
    gh.factory<_i902.BreakBindingUsecases>(
      () => _i902.BreakBindingUsecases(
        repository: gh<_i790.BreakBindinngRepository>(),
      ),
    );
    gh.factory<_i225.SensorDeviceConfigurationBloc>(
      () => _i225.SensorDeviceConfigurationBloc(
        coachConfigurationUseCase: gh<_i781.CoachConfigurationUseCase>(),
        sensorDeviceConfigurationUseCase:
            gh<_i1056.SensorDeviceConfigurationUseCase>(),
        masterModuleConfigurationUseCase:
            gh<_i423.MasterModuleConfigurationUseCase>(),
      ),
    );
    gh.factory<_i519.TrainConfigurationBloc>(
      () => _i519.TrainConfigurationBloc(
        trainConfigurationUseCase: gh<_i406.CoachConfigurationUseCase>(),
      ),
    );
    gh.factory<_i681.SensorTypeConfigurationBloc>(
      () => _i681.SensorTypeConfigurationBloc(
        sensorTypeConfigurationUseCase:
            gh<_i849.SensorTypeConfigurationUseCase>(),
      ),
    );
    gh.factory<_i685.DropDownValueUseCase>(
      () => _i685.DropDownValueUseCase(gh<_i204.DropDownValueRepository>()),
    );
    gh.factory<_i1011.ProfileBloc>(
      () => _i1011.ProfileBloc(
        profileUseCase: gh<_i489.ProfileUseCase>(),
        prefs: gh<_i1038.Prefs>(),
        permissionBloc: gh<_i416.PermissionBloc>(),
      ),
    );
    gh.factory<_i615.UserManagementBloc>(
      () => _i615.UserManagementBloc(
        userManagementUseCase: gh<_i99.UserManagementUseCase>(),
        dropDownValueUseCase: gh<_i685.DropDownValueUseCase>(),
      ),
    );
    gh.factory<_i862.NotificationBloc>(
      () => _i862.NotificationBloc(
        gh<_i597.GetNotificationsUseCase>(),
        gh<_i642.MarkNotificationReadUseCase>(),
        gh<_i17.MarkAllNotificationsReadUseCase>(),
        gh<_i648.DeleteNotificationUseCase>(),
      ),
    );
    gh.factory<_i209.BrakeBindingBloc>(
      () => _i209.BrakeBindingBloc(
        breakBindingUsecases: gh<_i902.BreakBindingUsecases>(),
      ),
    );
    gh.factory<_i596.RegisterBloc>(
      () => _i596.RegisterBloc(
        registerUseCase: gh<_i490.RegisterUseCase>(),
        dropDownValueUseCase: gh<_i685.DropDownValueUseCase>(),
        prefs: gh<_i1038.Prefs>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i152.RegisterModule {}
