import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:smart_coach_new/features/auth/login/presentation/login_screen.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:smart_coach_new/features/auth/register/presentation/register_screen.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/coach_configuration_screen.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/master_module_configuration_screen.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/sensor_device_configuration_screen.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/train_configuration_screen.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:smart_coach_new/features/dashboard/presentation/dashboard_screen.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/device_configuration_screen.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/rule_configuration_screen.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/sensor_type_configuration_screen.dart';
import 'package:smart_coach_new/features/notifications/presentation/notifications_screen.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_coach_new/features/profile/presentation/profile_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/presentation/acp_dashboard.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/presentation/bc_pressure_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/diesel_level_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/fsds_dashboard.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/hot_axle_dashboard.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/bloc/train_list_bloc.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/level_indicator_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/presentation/water_level_screen.dart';
import 'package:smart_coach_new/features/splash/presentation/splash_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/alerts_screen.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:smart_coach_new/features/user_management/presentation/user_management_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/presentation/odour_dashboard.dart';
import '../features/reports_and_alerts/break_binding/presentation/bloc/break_binding_bloc.dart';
import '../features/reports_and_alerts/break_binding/presentation/brake_binding_screen.dart';
import '../features/coach_dashboard/presentation/bloc/coach_dashboard_bloc.dart';
import '../features/coach_dashboard/presentation/coach_dashboard_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String userManagementRoute = '/user_management';
  static const String deviceConfigurationRoute = '/device_configuration';
  static const String sensorTypeConfigurationRoute =
      '/sensor_type_configuration';
  static const String ruleConfigurationRoute = '/rule_configuration';
  static const String masterModuleConfigurationRoute =
      '/master_module_configuration';
  static const String trainConfigurationRoute = '/train_configuration';
  static const String coachConfigurationRoute = '/coach_configuration';
  static const String sensorDeviceConfigurationRoute = '/sensor_device_configuration';
  static const String levelIndicatorRoute = '/level_indicator';
  static const String breakBinding = '/break_binding';
  static const String odourManagement = '/odour_management';
  static const String acpMonitoringRoute = '/acp_monitoring';
  static const String bcPressureMonitoringRoute = '/bc_pressure_monitoring';
  static const String dieselLevelMonitoringRoute = '/diesel_level_monitoring';
  static const String fsdsMonitoringRoute = '/fsds_monitoring';
  static const String hotAxleMonitoringRoute = '/hot_axle_monitoring';
  static const String waterTankMonitoringRoute = '/water_tank_monitoring';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';
  static const String alertsRoute = '/alerts';
  static const String coachDashboardRoute = '/coach_dashboard';

  static final router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(
        path: splashRoute,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: loginRoute,
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.I<LoginBloc>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: registerRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<RegisterBloc>(),
            child: const RegisterScreen(),
          );
        },
      ),
      GoRoute(
        path: dashboardRoute,
        builder: (context, state) {
          final user = state.extra as String?;
          return BlocProvider(
            create: (_) => GetIt.I<DashboardBloc>(),
            child: DashboardScreen(user: user),
          );
        },
      ),
      GoRoute(
        path: userManagementRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<UserManagementBloc>(),
            child: UserManagementScreen(),
          );
        },
      ),
      GoRoute(
        path: deviceConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<DeviceConfigurationBloc>(),
            child: DeviceConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: sensorTypeConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<SensorTypeConfigurationBloc>(),
            child: SensorTypeConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: ruleConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<RuleConfigurationBloc>(),
            child: RuleConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: masterModuleConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<MasterModuleConfigurationBloc>(),
            child: MasterModuleConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: trainConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<TrainConfigurationBloc>(),
            child: TrainConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: coachConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<CoachConfigurationBloc>(),
            child: CoachConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: sensorDeviceConfigurationRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<SensorDeviceConfigurationBloc>(),
            child: SensorDeviceConfigurationScreen(),
          );
        },
      ),
      GoRoute(
        path: levelIndicatorRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<TrainListBloc>(),
            child: LevelIndicatorScreen(),
          );
        },
      ),
      GoRoute(
        path: breakBinding,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<BrakeBindingBloc>(),
            child: BrakeBindingScreen(),
          );
        },
      ),
      GoRoute(
        path: odourManagement,
        builder: (context, state) => const OdourDashboard(),
      ),
      GoRoute(
        path: acpMonitoringRoute,
        builder: (context, state) => const AcpDashboard(),
      ),
      GoRoute(
        path: alertsRoute,
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.I<DashboardBloc>(),
          child: const AlertsScreen(),
        ),
      ),
      GoRoute(
        path: bcPressureMonitoringRoute,
        builder: (context, state) => const BCPressureScreen(),
      ),
      GoRoute(
        path: dieselLevelMonitoringRoute,
        builder: (context, state) => const DieselLevelScreen(),
      ),
      GoRoute(
        path: fsdsMonitoringRoute,
        builder: (context, state) {
          final title = state.extra as String?;
          return FsdsDashboard(title: title);
        },
      ),
      GoRoute(
        path: hotAxleMonitoringRoute,
        builder: (context, state) => const HotAxleDashboard(),
      ),
      GoRoute(
        path: waterTankMonitoringRoute,
        builder: (context, state) => const WaterLevelScreen(),
      ),
      GoRoute(
        path: profileRoute,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => GetIt.I<ProfileBloc>(),
            child: const ProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: notificationsRoute,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: coachDashboardRoute,
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.I<CoachDashboardBloc>(),
          child: const CoachDashboardScreen(),
        ),
      ),

    ],
  );
}
