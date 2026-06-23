// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
  userId: (json['user_id'] as num?)?.toInt(),
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  gender: json['gender'] as String?,
  organisationType: json['organisation_type'] as String?,
  organisationName: json['organisation_name'] as String?,
  zoneId: (json['zone_id'] as num?)?.toInt(),
  divisionId: (json['division_id'] as num?)?.toInt(),
  regionId: (json['region_id'] as num?)?.toInt(),
  roleId: (json['role_id'] as num?)?.toInt(),
  status: json['status'] as String?,
  approvalStatus: json['approval_status'] as String?,
  employeeId: json['employee_id'] as String?,
  panCardNo: json['pan_card_no'] as String?,
  aadharNo: json['aadhar_no'] as String?,
  aadharImg: json['aadhar_img'] as String?,
  panCardImage: json['pan_card_image'] as String?,
  companyId: json['company_id'],
  userImage: json['user_image'] as String?,
  createdDate: json['created_date'] as String?,
  updatedDate: json['updated_date'] as String?,
);

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'mobile_number': instance.mobileNumber,
      'gender': instance.gender,
      'organisation_type': instance.organisationType,
      'organisation_name': instance.organisationName,
      'zone_id': instance.zoneId,
      'division_id': instance.divisionId,
      'region_id': instance.regionId,
      'role_id': instance.roleId,
      'status': instance.status,
      'approval_status': instance.approvalStatus,
      'employee_id': instance.employeeId,
      'pan_card_no': instance.panCardNo,
      'aadhar_no': instance.aadharNo,
      'aadhar_img': instance.aadharImg,
      'pan_card_image': instance.panCardImage,
      'company_id': instance.companyId,
      'user_image': instance.userImage,
      'created_date': instance.createdDate,
      'updated_date': instance.updatedDate,
    };
