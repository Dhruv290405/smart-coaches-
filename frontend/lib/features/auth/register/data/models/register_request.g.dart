// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      gender: json['gender'] as String?,
      organisationType: json['organisation_type'] as String?,
      organisationName: json['organisation_name'] as String?,
      zoneId: (json['zone_id'] as num?)?.toInt(),
      divisionId: (json['division_id'] as num?)?.toInt(),
      regionIdList: (json['region_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      trainIdList: (json['train_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      roleId: (json['role_id'] as num?)?.toInt(),
      employeeId: json['employee_id'] as String?,
      panCardNo: json['pan_card_no'] as String?,
      companyId: json['company_id'] as String?,
      aadharNo: json['aadhar_no'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'mobile_number': instance.mobileNumber,
      'gender': instance.gender,
      'organisation_type': instance.organisationType,
      'organisation_name': instance.organisationName,
      'zone_id': instance.zoneId,
      'division_id': instance.divisionId,
      'region_id': instance.regionIdList,
      'train_ids': instance.trainIdList,
      'role_id': instance.roleId,
      'employee_id': instance.employeeId,
      'pan_card_no': instance.panCardNo,
      'company_id': instance.companyId,
      'aadhar_no': instance.aadharNo,
    };
