import 'package:json_annotation/json_annotation.dart';

part 'pneumatic_status_model.g.dart';

@JsonSerializable()
class PneumaticStatusResponse {
  final bool success;
  final PneumaticContext? context;
  final dynamic state;
  final dynamic brakeStatus;
  final PneumaticAlerts? alerts;
  final PneumaticReadings? readings;
  final List<PneumaticEvent>? recentEvents;
  final List<PneumaticFault>? activeFaults;
  final PneumaticHistoryWrapper? history;
  final dynamic lastUpdated;

  PneumaticStatusResponse({
    required this.success,
    this.context,
    this.state,
    this.brakeStatus,
    this.alerts,
    this.readings,
    this.recentEvents,
    this.activeFaults,
    this.history,
    this.lastUpdated,
  });

  factory PneumaticStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PneumaticStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticStatusResponseToJson(this);
}

@JsonSerializable()
class PneumaticContext {
  final dynamic deviceId;
  @JsonKey(name: 'coach_no')
  final dynamic coachNo;
  @JsonKey(name: 'Train_no')
  final dynamic trainNo;
  @JsonKey(name: 'technical_id')
  final dynamic technicalId;
  final dynamic location;

  PneumaticContext({
    this.deviceId,
    this.coachNo,
    this.trainNo,
    this.technicalId,
    this.location,
  });

  factory PneumaticContext.fromJson(Map<String, dynamic> json) =>
      _$PneumaticContextFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticContextToJson(this);
}

@JsonSerializable()
class PneumaticAlerts {
  @JsonKey(name: 'binding_residual')
  final dynamic binding;
  @JsonKey(name: 'binding_severe')
  final dynamic bindingSevere;
  final dynamic leakage;
  @JsonKey(name: 'cr_overcharge')
  final dynamic cr;
  @JsonKey(name: 'dv_defect')
  final dynamic dv;
  final dynamic emergency;

  PneumaticAlerts({
    this.binding,
    this.bindingSevere,
    this.leakage,
    this.cr,
    this.dv,
    this.emergency,
  });

  factory PneumaticAlerts.fromJson(Map<String, dynamic> json) =>
      _$PneumaticAlertsFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticAlertsToJson(this);
}

@JsonSerializable()
class PneumaticReadings {
  final num? bp;
  final num? fp;
  final num? bc;
  final num? cr;
  final dynamic dropRate;
  final num? brakeDuration;
  final num? appliedTime;
  final num? releasedTime;

  PneumaticReadings({
    this.bp,
    this.fp,
    this.bc,
    this.cr,
    this.dropRate,
    this.brakeDuration,
    this.appliedTime,
    this.releasedTime,
  });

  factory PneumaticReadings.fromJson(Map<String, dynamic> json) =>
      _$PneumaticReadingsFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticReadingsToJson(this);
}

@JsonSerializable()
class PneumaticEvent {
  final dynamic id;
  final dynamic time;
  final dynamic status;
  final dynamic coach;
  final num? bp;
  final num? bc;
  final dynamic reason;

  PneumaticEvent({
    this.id,
    this.time,
    this.status,
    this.coach,
    this.bp,
    this.bc,
    this.reason,
  });

  factory PneumaticEvent.fromJson(Map<String, dynamic> json) =>
      _$PneumaticEventFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticEventToJson(this);
}

@JsonSerializable()
class PneumaticFault {
  final dynamic deviceId;
  final dynamic type;
  final dynamic severity;
  final dynamic description;
  final dynamic timestamp;

  PneumaticFault({
    this.deviceId,
    this.type,
    this.severity,
    this.description,
    this.timestamp,
  });

  factory PneumaticFault.fromJson(Map<String, dynamic> json) =>
      _$PneumaticFaultFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticFaultToJson(this);
}

@JsonSerializable()
class PneumaticHistoryWrapper {
  final int? limit;
  final List<PneumaticHistoryData>? data;

  PneumaticHistoryWrapper({this.limit, this.data});

  factory PneumaticHistoryWrapper.fromJson(Map<String, dynamic> json) =>
      _$PneumaticHistoryWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticHistoryWrapperToJson(this);
}

@JsonSerializable()
class PneumaticHistoryData {
  final dynamic id;
  final dynamic timestamp;
  @JsonKey(name: 'bp_raw')
  final num? bpRaw;
  @JsonKey(name: 'fp_raw')
  final num? fpRaw;
  @JsonKey(name: 'cr_raw')
  final num? crRaw;
  @JsonKey(name: 'bc_raw')
  final num? bcRaw;
  final num? bp;
  final num? fp;
  final num? cr;
  final num? bc;
  @JsonKey(name: 'brake_status')
  final dynamic brakeStatus;
  @JsonKey(name: 'brake_duration')
  final num? brakeDuration;
  @JsonKey(name: 'brake_fault')
  final dynamic brakeFault;
  @JsonKey(name: 'coach_no')
  final dynamic coachNo;
  @JsonKey(name: 'device_id')
  final dynamic deviceId;
  @JsonKey(name: 'brake_applied_time')
  final num? brakeAppliedTime;
  @JsonKey(name: 'brake_released_time')
  final num? brakeReleasedTime;
  @JsonKey(name: 'location')
  final dynamic location;
  @JsonKey(name: 'train_no')
  final dynamic trainNo;

  PneumaticHistoryData({
    this.id,
    this.timestamp,
    this.bpRaw,
    this.fpRaw,
    this.crRaw,
    this.bcRaw,
    this.bp,
    this.fp,
    this.cr,
    this.bc,
    this.brakeStatus,
    this.brakeDuration,
    this.brakeFault,
    this.coachNo,
    this.deviceId,
    this.brakeAppliedTime,
    this.brakeReleasedTime,
    this.location,
    this.trainNo,
  });

  factory PneumaticHistoryData.fromJson(Map<String, dynamic> json) =>
      _$PneumaticHistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$PneumaticHistoryDataToJson(this);
}
