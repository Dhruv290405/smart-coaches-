class CoachConfigResponse {
  final bool success;
  final String message;
  final CoachInfo? coachInfo;
  final List<String> fittedDevices;
  final FullConfig? fullConfig;

  CoachConfigResponse({
    required this.success,
    this.message = '',
    this.coachInfo,
    this.fittedDevices = const [],
    this.fullConfig,
  });

  factory CoachConfigResponse.fromJson(Map<String, dynamic> json) {
    return CoachConfigResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      coachInfo: json['coach_info'] != null ? CoachInfo.fromJson(json['coach_info']) : null,
      fittedDevices: List<String>.from(json['fitted_devices'] ?? []),
      fullConfig: json['full_config'] != null ? FullConfig.fromJson(json['full_config']) : null,
    );
  }
}

class CoachInfo {
  final String coachNo;
  final String coachType;
  final String rakeNo;
  final String wspMake;

  CoachInfo({
    required this.coachNo,
    required this.coachType,
    required this.rakeNo,
    required this.wspMake,
  });

  factory CoachInfo.fromJson(Map<String, dynamic> json) {
    return CoachInfo(
      coachNo: json['coach_no'] ?? '',
      coachType: json['coach_type'] ?? '',
      rakeNo: json['rake_no'] ?? '',
      wspMake: json['wsp_make'] ?? '',
    );
  }
}

class FullConfig {
  final int id;
  final String rakeNo;
  final String coachNo;
  final String coachType;
  final String wspMake;
  final String wliSensor;
  final String fsdsSensor;
  final String bcPressure;
  final String wspWifi;
  final String hotAxleDetector;
  final String acpBuzzerAlert;
  final String acpElectricalConn;
  final String badOdourAlert;
  final String createdAt;

  FullConfig({
    required this.id,
    required this.rakeNo,
    required this.coachNo,
    required this.coachType,
    required this.wspMake,
    required this.wliSensor,
    required this.fsdsSensor,
    required this.bcPressure,
    required this.wspWifi,
    required this.hotAxleDetector,
    required this.acpBuzzerAlert,
    required this.acpElectricalConn,
    required this.badOdourAlert,
    required this.createdAt,
  });

  factory FullConfig.fromJson(Map<String, dynamic> json) {
    return FullConfig(
      id: json['id'] ?? 0,
      rakeNo: json['rake_no'] ?? '',
      coachNo: json['coach_no'] ?? '',
      coachType: json['coach_type'] ?? '',
      wspMake: json['wsp_make'] ?? '',
      wliSensor: json['wli_sensor'] ?? 'NOT FITTED',
      fsdsSensor: json['fsds_sensor'] ?? 'NOT FITTED',
      bcPressure: json['bc_pressure'] ?? 'NOT FITTED',
      wspWifi: json['wsp_wifi'] ?? 'NOT FITTED',
      hotAxleDetector: json['hot_axle_detector'] ?? 'NOT FITTED',
      acpBuzzerAlert: json['acp_buzzer_alert'] ?? 'NOT FITTED',
      acpElectricalConn: json['acp_electrical_conn'] ?? 'NOT FITTED',
      badOdourAlert: json['bad_odour_alert'] ?? 'NOT FITTED',
      createdAt: json['created_at'] ?? '',
    );
  }
}
