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
  gender: json['gender'] as String?,
  organisationType: json['organisation_type'] as String?,
  organisationName: json['organisation_name'] as String?,
  zoneId: (json['zone_id'] as num?)?.toInt(),
  divisionId: (json['division_id'] as num?)?.toInt(),
  regionId: (json['region_id'] as num?)?.toInt(),
  roleId: (json['role_id'] as num?)?.toInt(),
  status: json['status'] as String?,
  approvalStatus: json['approval_status'] as String?,
  createdDate: json['created_date'] as String?,
  employeeId: json['employee_id'] as String?,
  panCardNo: json['pan_card_no'] as String?,
  panCardImage: json['pan_card_image'] == null
      ? null
      : PanCardImage.fromJson(json['pan_card_image'] as Map<String, dynamic>),
  companyId: json['company_id'],
  userImage: json['user_image'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.userId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'mobile_number': instance.mobileNumber,
  'email': instance.email,
  'gender': instance.gender,
  'organisation_type': instance.organisationType,
  'organisation_name': instance.organisationName,
  'zone_id': instance.zoneId,
  'division_id': instance.divisionId,
  'region_id': instance.regionId,
  'role_id': instance.roleId,
  'status': instance.status,
  'approval_status': instance.approvalStatus,
  'created_date': instance.createdDate,
  'employee_id': instance.employeeId,
  'pan_card_no': instance.panCardNo,
  'pan_card_image': instance.panCardImage,
  'company_id': instance.companyId,
  'user_image': instance.userImage,
};

PanCardImage _$PanCardImageFromJson(Map<String, dynamic> json) => PanCardImage(
  type: json['type'] as String,
  data: (json['data'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$PanCardImageToJson(PanCardImage instance) =>
    <String, dynamic>{'type': instance.type, 'data': instance.data};
