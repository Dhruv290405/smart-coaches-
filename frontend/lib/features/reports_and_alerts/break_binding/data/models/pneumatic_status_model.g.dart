// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pneumatic_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PneumaticStatusResponse _$PneumaticStatusResponseFromJson(
  Map<String, dynamic> json,
) => PneumaticStatusResponse(
  success: json['success'] as bool,
  context: json['context'] == null
      ? null
      : PneumaticContext.fromJson(json['context'] as Map<String, dynamic>),
  state: json['state'],
  brakeStatus: json['brakeStatus'],
  alerts: json['alerts'] == null
      ? null
      : PneumaticAlerts.fromJson(json['alerts'] as Map<String, dynamic>),
  readings: json['readings'] == null
      ? null
      : PneumaticReadings.fromJson(json['readings'] as Map<String, dynamic>),
  recentEvents: (json['recentEvents'] as List<dynamic>?)
      ?.map((e) => PneumaticEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  activeFaults: (json['activeFaults'] as List<dynamic>?)
      ?.map((e) => PneumaticFault.fromJson(e as Map<String, dynamic>))
      .toList(),
  history: json['history'] == null
      ? null
      : PneumaticHistoryWrapper.fromJson(
          json['history'] as Map<String, dynamic>,
        ),
  lastUpdated: json['lastUpdated'],
);

Map<String, dynamic> _$PneumaticStatusResponseToJson(
  PneumaticStatusResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'context': instance.context,
  'state': instance.state,
  'brakeStatus': instance.brakeStatus,
  'alerts': instance.alerts,
  'readings': instance.readings,
  'recentEvents': instance.recentEvents,
  'activeFaults': instance.activeFaults,
  'history': instance.history,
  'lastUpdated': instance.lastUpdated,
};

PneumaticContext _$PneumaticContextFromJson(Map<String, dynamic> json) =>
    PneumaticContext(
      deviceId: json['deviceId'],
      coachNo: json['coach_no'],
      trainNo: json['Train_no'],
      technicalId: json['technical_id'],
      location: json['location'],
    );

Map<String, dynamic> _$PneumaticContextToJson(PneumaticContext instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'coachNo': instance.coachNo,
      'trainNo': instance.trainNo,
      'technicalId': instance.technicalId,
      'location': instance.location,
    };

PneumaticAlerts _$PneumaticAlertsFromJson(Map<String, dynamic> json) =>
    PneumaticAlerts(
      binding: json['binding_residual'],
      bindingSevere: json['binding_severe'],
      leakage: json['leakage'],
      cr: json['cr_overcharge'],
      dv: json['dv_defect'],
      emergency: json['emergency'],
    );

Map<String, dynamic> _$PneumaticAlertsToJson(PneumaticAlerts instance) =>
    <String, dynamic>{
      'binding_residual': instance.binding,
      'binding_severe': instance.bindingSevere,
      'leakage': instance.leakage,
      'cr_overcharge': instance.cr,
      'dv_defect': instance.dv,
      'emergency': instance.emergency,
    };

PneumaticReadings _$PneumaticReadingsFromJson(Map<String, dynamic> json) =>
    PneumaticReadings(
      bp: json['bp'] as num?,
      fp: json['fp'] as num?,
      bc: json['bc'] as num?,
      cr: json['cr'] as num?,
      dropRate: json['dropRate'],
      brakeDuration: json['brakeDuration'] as num?,
      appliedTime: json['appliedTime'] as num?,
      releasedTime: json['releasedTime'] as num?,
    );

Map<String, dynamic> _$PneumaticReadingsToJson(PneumaticReadings instance) =>
    <String, dynamic>{
      'bp': instance.bp,
      'fp': instance.fp,
      'bc': instance.bc,
      'cr': instance.cr,
      'dropRate': instance.dropRate,
      'brakeDuration': instance.brakeDuration,
      'appliedTime': instance.appliedTime,
      'releasedTime': instance.releasedTime,
    };

PneumaticEvent _$PneumaticEventFromJson(Map<String, dynamic> json) =>
    PneumaticEvent(
      id: json['id'],
      time: json['time'],
      status: json['status'],
      coach: json['coach'],
      bp: json['bp'] as num?,
      bc: json['bc'] as num?,
      reason: json['reason'],
    );

Map<String, dynamic> _$PneumaticEventToJson(PneumaticEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'status': instance.status,
      'coach': instance.coach,
      'bp': instance.bp,
      'bc': instance.bc,
      'reason': instance.reason,
    };

PneumaticFault _$PneumaticFaultFromJson(Map<String, dynamic> json) =>
    PneumaticFault(
      deviceId: json['deviceId'],
      type: json['type'],
      severity: json['severity'],
      description: json['description'],
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$PneumaticFaultToJson(PneumaticFault instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'type': instance.type,
      'severity': instance.severity,
      'description': instance.description,
      'timestamp': instance.timestamp,
    };

PneumaticHistoryWrapper _$PneumaticHistoryWrapperFromJson(
  Map<String, dynamic> json,
) => PneumaticHistoryWrapper(
  limit: (json['limit'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => PneumaticHistoryData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PneumaticHistoryWrapperToJson(
  PneumaticHistoryWrapper instance,
) => <String, dynamic>{'limit': instance.limit, 'data': instance.data};

PneumaticHistoryData _$PneumaticHistoryDataFromJson(
  Map<String, dynamic> json,
) => PneumaticHistoryData(
  id: json['id'],
  timestamp: json['timestamp'],
  bpRaw: json['bp_raw'] as num?,
  fpRaw: json['fp_raw'] as num?,
  crRaw: json['cr_raw'] as num?,
  bcRaw: json['bc_raw'] as num?,
  bp: json['bp'] as num?,
  fp: json['fp'] as num?,
  cr: json['cr'] as num?,
  bc: json['bc'] as num?,
  brakeStatus: json['brake_status'],
  brakeDuration: json['brake_duration'] as num?,
  brakeFault: json['brake_fault'],
  coachNo: json['coach_no'],
  deviceId: json['device_id'],
  brakeAppliedTime: json['brake_applied_time'] as num?,
  brakeReleasedTime: json['brake_released_time'] as num?,
  location: json['location'],
  trainNo: json['train_no'],
);

Map<String, dynamic> _$PneumaticHistoryDataToJson(
  PneumaticHistoryData instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp,
  'bp_raw': instance.bpRaw,
  'fp_raw': instance.fpRaw,
  'cr_raw': instance.crRaw,
  'bc_raw': instance.bcRaw,
  'bp': instance.bp,
  'fp': instance.fp,
  'cr': instance.cr,
  'bc': instance.bc,
  'brake_status': instance.brakeStatus,
  'brake_duration': instance.brakeDuration,
  'brake_fault': instance.brakeFault,
  'coach_no': instance.coachNo,
  'device_id': instance.deviceId,
  'brake_applied_time': instance.brakeAppliedTime,
  'brake_released_time': instance.brakeReleasedTime,
  'location': instance.location,
  'train_no': instance.trainNo,
};
