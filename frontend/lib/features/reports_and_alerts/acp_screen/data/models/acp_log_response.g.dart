// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acp_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcpLogResponse _$AcpLogResponseFromJson(Map<String, dynamic> json) =>
    AcpLogResponse(
      success: json['success'] as bool?,
      count: (json['count'] as num?)?.toInt(),
      totalRegisteredDevices: (json['total_registered_devices'] as num?)
          ?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AcpLogData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcpLogResponseToJson(AcpLogResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'total_registered_devices': instance.totalRegisteredDevices,
      'data': instance.data,
    };

AcpLogData _$AcpLogDataFromJson(Map<String, dynamic> json) => AcpLogData(
  logId: (json['log_id'] as num?)?.toInt(),
  lastHeartbeat: json['last_heartbeat'] as String?,
  lastTrigger: json['last_trigger'] as String?,
  statusText: json['status'] as String?,
  rawAssetName: json['raw_asset_name'] as String?,
  acpStatus: json['acp_status'] as String?,
  trainNo: json['train_no'] as String?,
  todayCount: (json['today_count'] as num?)?.toInt(),
  commCoachNo: json['comm_coach_no'] as String?,
  techCoachNo: json['tech_coach_no'] as String?,
  trainLocation: json['train_location'] as String?,
  powerCarNo: json['power_car_no'] as String?,
  totalCount: (json['total_count'] as num?)?.toInt(),
  deviceId: json['device_id'] as String?,
  fsdsStatus: json['fsdsStatus'] as String?,
  fsdsTimestamp: json['fsdsTimestamp'] as String?,
);

Map<String, dynamic> _$AcpLogDataToJson(AcpLogData instance) =>
    <String, dynamic>{
      'log_id': instance.logId,
      'last_heartbeat': instance.lastHeartbeat,
      'last_trigger': instance.lastTrigger,
      'status': instance.statusText,
      'raw_asset_name': instance.rawAssetName,
      'acp_status': instance.acpStatus,
      'train_no': instance.trainNo,
      'today_count': instance.todayCount,
      'comm_coach_no': instance.commCoachNo,
      'tech_coach_no': instance.techCoachNo,
      'train_location': instance.trainLocation,
      'power_car_no': instance.powerCarNo,
      'total_count': instance.totalCount,
      'device_id': instance.deviceId,
      'fsdsStatus': instance.fsdsStatus,
      'fsdsTimestamp': instance.fsdsTimestamp,
    };
