// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acp_filters_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcpFiltersResponse _$AcpFiltersResponseFromJson(Map<String, dynamic> json) =>
    AcpFiltersResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AcpFilterData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcpFiltersResponseToJson(AcpFiltersResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

AcpFilterData _$AcpFilterDataFromJson(Map<String, dynamic> json) =>
    AcpFilterData(
      trainNo: json['train_no'] as String?,
      commCoachNo: json['comm_coach_no'] as String?,
      techCoachNo: json['tech_coach_no'] as String?,
    );

Map<String, dynamic> _$AcpFilterDataToJson(AcpFilterData instance) =>
    <String, dynamic>{
      'train_no': instance.trainNo,
      'comm_coach_no': instance.commCoachNo,
      'tech_coach_no': instance.techCoachNo,
    };
