// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: (json['user_id'] as num?)?.toInt(),
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  email: json['email'] as String?,
  organisationType: json['organisation_type'] as String?,
  createdDate: json['created_date'] as String?,
  role: json['role'] as String?,
  employeeId: json['employee_id'] as String?,
  zoneId: (json['zone_id'] as num?)?.toInt(),
  zoneName: json['zone_name'] as String?,
  divisionId: (json['division_id'] as num?)?.toInt(),
  divisionName: json['division_name'] as String?,
  regionIds: json['region_ids'] as String?,
  regionNames: json['region_names'] as String?,
  panCardNo: json['pan_card_no'] as String?,
  aadharNo: json['aadhar_no'] as String?,
  roleId: (json['role_id'] as num?)?.toInt(),
  approvalStatus: json['approval_status'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.userId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'mobile_number': instance.mobileNumber,
  'email': instance.email,
  'organisation_type': instance.organisationType,
  'created_date': instance.createdDate,
  'role': instance.role,
  'employee_id': instance.employeeId,
  'zone_id': instance.zoneId,
  'zone_name': instance.zoneName,
  'division_id': instance.divisionId,
  'division_name': instance.divisionName,
  'region_ids': instance.regionIds,
  'region_names': instance.regionNames,
  'pan_card_no': instance.panCardNo,
  'aadhar_no': instance.aadharNo,
  'role_id': instance.roleId,
  'approval_status': instance.approvalStatus,
};
