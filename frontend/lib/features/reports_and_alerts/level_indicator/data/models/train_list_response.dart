import 'package:json_annotation/json_annotation.dart';

part 'train_list_response.g.dart';

/// ---------------- Train List Response ----------------
@JsonSerializable()
class TrainListResponseForReport {
  final bool success;
  final String message;
  final List<TrainItem> data;

  TrainListResponseForReport({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TrainListResponseForReport.fromJson(Map<String, dynamic> json) =>
      _$TrainListResponseForReportFromJson(json);

  Map<String, dynamic> toJson() => _$TrainListResponseForReportToJson(this);
}

/// ---------------- Coach List Response ----------------
@JsonSerializable()
class CoachListResponseForReport {
  final bool success;
  final String message;
  final List<BasicCoachItem> data;

  CoachListResponseForReport({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CoachListResponseForReport.fromJson(Map<String, dynamic> json) =>
      _$CoachListResponseForReportFromJson(json);

  Map<String, dynamic> toJson() => _$CoachListResponseForReportToJson(this);
}

/// ---------------- Train Item ----------------
@JsonSerializable()
class TrainItem {
  @JsonKey(name: "train_number")
  final String trainNumber;

  @JsonKey(name: "train_name")
  final String trainName;

  @JsonKey(name: "train_id")
  final int trainId;

  TrainItem({
    required this.trainNumber,
    required this.trainName,
    required this.trainId,
  });

  factory TrainItem.fromJson(Map<String, dynamic> json) =>
      _$TrainItemFromJson(json);

  Map<String, dynamic> toJson() => _$TrainItemToJson(this);
}

/// ---------------- Coach Item ----------------
@JsonSerializable()
class BasicCoachItem {
  @JsonKey(name: "coach_id")
  final int coach_id;

  @JsonKey(name: "coach_unique_id")
  final String coach_unique_id;

  BasicCoachItem({
    required this.coach_id,
    required this.coach_unique_id,
  });

  factory BasicCoachItem.fromJson(Map<String, dynamic> json) =>
      _$BasicCoachItemFromJson(json);

  Map<String, dynamic> toJson() => _$BasicCoachItemToJson(this);
}

/// -------------------------- Basic Sensor Item -------------------------

@JsonSerializable()
class SensorListResponseForReport {
  final bool success;
  final String message;
  final List<BasicSensorItem> data;

  SensorListResponseForReport({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SensorListResponseForReport.fromJson(Map<String, dynamic> json) =>
      _$SensorListResponseForReportFromJson(json);

  Map<String, dynamic> toJson() => _$SensorListResponseForReportToJson(this);
}


@JsonSerializable()
class BasicSensorItem {
  @JsonKey(name: "sensor_config_id")
  final int sensor_config_id;

  @JsonKey(name: "sensor_id")
  final String sensor_id;

  @JsonKey(name: "sensor_type_id")
  final int sensor_type_id;

  BasicSensorItem({
    required this.sensor_config_id,
    required this.sensor_id,
    required this.sensor_type_id,
  });

  factory BasicSensorItem.fromJson(Map<String, dynamic> json) =>
      _$BasicSensorItemFromJson(json);

  Map<String, dynamic> toJson() => _$BasicSensorItemToJson(this);
}
