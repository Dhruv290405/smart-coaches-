// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceListResponse _$DeviceListResponseFromJson(Map<String, dynamic> json) =>
    DeviceListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DeviceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceListResponseToJson(DeviceListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

DeviceItem _$DeviceItemFromJson(Map<String, dynamic> json) => DeviceItem(
  deviceId: json['device_id'] as String?,
  shortName: json['short_name'] as String?,
  fullName: json['full_name'] as String?,
  description: json['description'] as String?,
  dataType: json['data_type'] as String?,
  frequency: _parseDouble(json['frequency_secs']),
  createdAt: json['created_at'] as String?,
  createdBy: json['created_by'] as String?,
  updatedAt: json['updated_at'] as String?,
  updatedBy: json['updated_by'] as String?,
  masterModuleId: _parseInt(json['master_module_id']),
  deviceUniqueId: json['device_unique_id'] as String?,
  timeUnit: json['time_unit'] as String?,
  isActive: _parseInt(json['is_active']),
  numberOfSensors: _parseInt(json['no_of_sensors']),
  masterModuleSerial: json['master_module_serial'] as String?,
  coachUniqueId: json['coach_unique_id'] as String?,
  trainNumber: _parseInt(json['train_number']),
  trainName: json['train_name'] as String?,
  deviceTypeName: json['device_type_name'] as String?,
  deviceModel: json['device_model'] as String?,
);

Map<String, dynamic> _$DeviceItemToJson(DeviceItem instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'short_name': instance.shortName,
      'full_name': instance.fullName,
      'description': instance.description,
      'data_type': instance.dataType,
      'frequency_secs': instance.frequency,
      'created_at': instance.createdAt,
      'created_by': instance.createdBy,
      'updated_at': instance.updatedAt,
      'updated_by': instance.updatedBy,
      'master_module_id': instance.masterModuleId,
      'device_unique_id': instance.deviceUniqueId,
      'time_unit': instance.timeUnit,
      'is_active': instance.isActive,
      'no_of_sensors': instance.numberOfSensors,
      'master_module_serial': instance.masterModuleSerial,
      'coach_unique_id': instance.coachUniqueId,
      'train_number': instance.trainNumber,
      'train_name': instance.trainName,
      'device_type_name': instance.deviceTypeName,
      'device_model': instance.deviceModel,
    };
