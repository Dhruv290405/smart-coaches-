import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class ProfileData {
  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'organisation_type')
  final String? organisationType;

  @JsonKey(name: 'organisation_name')
  final String? organisationName;

  @JsonKey(name: 'zone_id')
  final int? zoneId;

  @JsonKey(name: 'division_id')
  final int? divisionId;

  @JsonKey(name: 'region_id')
  final int? regionId;

  @JsonKey(name: 'role_id')
  final int? roleId;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'approval_status')
  final String? approvalStatus;

  @JsonKey(name: 'employee_id')
  final String? employeeId;

  @JsonKey(name: 'pan_card_no')
  final String? panCardNo;

  @JsonKey(name: 'aadhar_no')
  final String? aadharNo;

  @JsonKey(name: 'aadhar_img')
  final String? aadharImg;

  @JsonKey(name: 'pan_card_image')
  final String? panCardImage;

  @JsonKey(name: 'company_id')
  final dynamic companyId;

  @JsonKey(name: 'user_image')
  final String? userImage;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'updated_date')
  final String? updatedDate;

  ProfileData({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.gender,
    this.organisationType,
    this.organisationName,
    this.zoneId,
    this.divisionId,
    this.regionId,
    this.roleId,
    this.status,
    this.approvalStatus,
    this.employeeId,
    this.panCardNo,
    this.aadharNo,
    this.aadharImg,
    this.panCardImage,
    this.companyId,
    this.userImage,
    this.createdDate,
    this.updatedDate,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId ?? 0,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: email ?? '',
      mobileNumber: mobileNumber ?? '',
      gender: gender ?? '',
      organisationType: organisationType ?? '',
      organisationName: organisationName ?? '',
      zoneId: zoneId ?? 0,
      divisionId: divisionId ?? 0,
      regionId: regionId ?? 0,
      roleId: roleId ?? 0,
      status: status ?? '',
      approvalStatus: approvalStatus ?? '',
      employeeId: employeeId ?? '',
      panCardNo: panCardNo ?? '',
      aadharNo: aadharNo ?? '',
      aadharImg: aadharImg ?? '',
      panCardImage: panCardImage ?? '',
      companyId: companyId?.toString() ?? '',
      userImage: userImage ?? '',
      createdDate: createdDate ?? '',
      updatedDate: updatedDate ?? '',
    );
  }
}