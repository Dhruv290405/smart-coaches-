import 'package:json_annotation/json_annotation.dart';

part 'acp_log_response.g.dart';

@JsonSerializable()
class AcpLogResponse {
  final bool? success;
  final int? count;
  @JsonKey(name: 'total_registered_devices')
  final int? totalRegisteredDevices;
  final List<AcpLogData>? data;

  AcpLogResponse({this.success, this.count, this.totalRegisteredDevices, this.data});

  factory AcpLogResponse.fromJson(Map<String, dynamic> json) =>
      _$AcpLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcpLogResponseToJson(this);
}

@JsonSerializable()
class AcpLogData {
  @JsonKey(name: 'log_id')
  final int? logId;
  @JsonKey(name: 'last_heartbeat')
  final String? lastHeartbeat;
  @JsonKey(name: 'last_trigger')
  final String? lastTrigger;
  @JsonKey(name: 'status')
  final String? statusText;
  @JsonKey(name: 'raw_asset_name')
  final String? rawAssetName;
  @JsonKey(name: 'acp_status')
  final String? acpStatus;
  @JsonKey(name: 'train_no')
  final String? trainNo;
  @JsonKey(name: 'today_count')
  final int? todayCount;
  @JsonKey(name: 'comm_coach_no')
  final String? commCoachNo;
  @JsonKey(name: 'tech_coach_no')
  final String? techCoachNo;
  @JsonKey(name: 'train_location')
  final String? trainLocation;
  @JsonKey(name: 'power_car_no')
  final String? powerCarNo;
  @JsonKey(name: 'total_count')
  final int? totalCount;
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'totalized_count')
  final int? totalizedCount;
  final String? fsdsStatus;
  final String? fsdsTimestamp;

  String? get lastUpdated => lastHeartbeat;

  AcpLogData({
    this.logId,
    this.lastHeartbeat,
    this.lastTrigger,
    this.statusText,
    this.rawAssetName,
    this.acpStatus,
    this.trainNo,
    this.todayCount,
    this.commCoachNo,
    this.techCoachNo,
    this.trainLocation,
    this.powerCarNo,
    this.totalCount,
    this.deviceId,
    this.totalizedCount,
    this.fsdsStatus,
    this.fsdsTimestamp,
  });

  factory AcpLogData.fromJson(Map<String, dynamic> json) {
    String? _safeString(dynamic val) {
      if (val == null || val == 'null') return null;
      return val.toString();
    }
    return AcpLogData(
      logId: json['log_id'] as int?,
      lastHeartbeat: _safeString(json['last_heartbeat']),
      lastTrigger: _safeString(json['last_trigger']),
      statusText: _safeString(json['status']),
      rawAssetName: json['raw_asset_name'] as String?,
      acpStatus: _safeString(json['acp_status']),
      trainNo: _safeString(json['train_no']),
      todayCount: (json['today_count'] as num?)?.toInt(),
      commCoachNo: _safeString(json['comm_coach_no']),
      techCoachNo: _safeString(json['tech_coach_no']),
      trainLocation: json['train_location'] as String?,
      powerCarNo: _safeString(json['power_car_no']),
      totalCount: (json['total_count'] as num?)?.toInt(),
      deviceId: _safeString(json['device_id']),
      totalizedCount: (json['totalized_count'] as num?)?.toInt(),
      fsdsStatus: json['fsds_status']?.toString(),
      fsdsTimestamp: _safeString(json['fsds_timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'last_heartbeat': lastHeartbeat,
      'last_trigger': lastTrigger,
      'status': statusText,
      'raw_asset_name': rawAssetName,
      'acp_status': acpStatus,
      'train_no': trainNo,
      'comm_coach_no': commCoachNo,
      'tech_coach_no': techCoachNo,
      'train_location': trainLocation,
      'power_car_no': powerCarNo,
      'total_count': totalCount,
      'today_count': todayCount,
      'device_id': deviceId,
      'totalized_count': totalizedCount,
      'fsds_status': fsdsStatus,
      'fsds_timestamp': fsdsTimestamp,
    };
  }
}
