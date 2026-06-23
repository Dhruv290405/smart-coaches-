// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_type_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertTypeResponse _$AlertTypeResponseFromJson(Map<String, dynamic> json) =>
    AlertTypeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AlertTypeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlertTypeResponseToJson(AlertTypeResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

AlertTypeItem _$AlertTypeItemFromJson(Map<String, dynamic> json) =>
    AlertTypeItem(
      alertTypeId: (json['alert_type_id'] as num?)?.toInt(),
      alertTypeName: json['alert_type_name'] as String?,
    );

Map<String, dynamic> _$AlertTypeItemToJson(AlertTypeItem instance) =>
    <String, dynamic>{
      'alert_type_id': instance.alertTypeId,
      'alert_type_name': instance.alertTypeName,
    };
