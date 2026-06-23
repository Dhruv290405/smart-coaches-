import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardDataLoaded extends DashboardState {
  final int totalTrains;
  final int smartCoaches;
  final int activeDevices;
  final int activeSensors;
  final int criticalAlerts;
  final int warnings;
  final int moderate;
  final int normalState;
  final List<AcpLogData> recentAlerts;
  final List<PneumaticHistoryData> recentPneumaticAlerts;
  final int acpDeployed;

  DashboardDataLoaded({
    required this.totalTrains,
    required this.smartCoaches,
    required this.activeDevices,
    required this.activeSensors,
    required this.criticalAlerts,
    required this.warnings,
    required this.moderate,
    required this.normalState,
    required this.recentAlerts,
    required this.recentPneumaticAlerts,
    this.acpDeployed = 0,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardNavigateToNotifications extends DashboardState {}

class DashboardNavigateToSettings extends DashboardState {}

class DashboardNavigateToProfile extends DashboardState {}