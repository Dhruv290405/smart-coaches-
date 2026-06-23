import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;

  final String? email;
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

  final String? status;

  @JsonKey(name: 'approval_status')
  final String? approvalStatus;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'employee_id')
  final String? employeeId;

  @JsonKey(name: 'pan_card_no')
  final String? panCardNo;

  @JsonKey(name: 'pan_card_image')
  final PanCardImage? panCardImage;

  @JsonKey(name: 'company_id')
  final dynamic companyId;

  @JsonKey(name: 'user_image')
  final String? userImage;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
    this.gender,
    required this.organisationType,
    required this.organisationName,
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
    required this.roleId,
    required this.status,
    required this.approvalStatus,
    required this.createdDate,
    required this.employeeId,
    required this.panCardNo,
    required this.panCardImage,
    this.companyId,
    required this.userImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class PanCardImage {
  final String type;
  final List<int> data;

  PanCardImage({
    required this.type,
    required this.data,
  });

  factory PanCardImage.fromJson(Map<String, dynamic> json) =>
      _$PanCardImageFromJson(json);

  Map<String, dynamic> toJson() => _$PanCardImageToJson(this);
}
