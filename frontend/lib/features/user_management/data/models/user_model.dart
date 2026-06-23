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
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'organisation_type')
  final String? organisationType;
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @JsonKey(name: 'role')
  final String? role;
  @JsonKey(name: 'employee_id')
  final String? employeeId;
  @JsonKey(name: 'zone_id')
  final int? zoneId;
  @JsonKey(name: 'zone_name')
  final String? zoneName;
  @JsonKey(name: 'division_id')
  final int? divisionId;
  @JsonKey(name: 'division_name')
  final String? divisionName;
  @JsonKey(name: 'region_ids')
  final String? regionIds;
  @JsonKey(name: 'region_names')
  final String? regionNames;
  @JsonKey(name: 'pan_card_no')
  final String? panCardNo;
  @JsonKey(name: 'aadhar_no')
  final String? aadharNo;
  @JsonKey(name: 'role_id')
  final int? roleId;
  @JsonKey(name: 'approval_status')
  final String? approvalStatus;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
    required this.organisationType,
    required this.createdDate,
    required this.role,
    required this.employeeId,
    required this.zoneId,
    required this.zoneName,
    required this.divisionId,
    required this.divisionName,
    required this.regionIds,
    required this.regionNames,
    required this.panCardNo,
    required this.aadharNo,
    required this.roleId,
    required this.approvalStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
