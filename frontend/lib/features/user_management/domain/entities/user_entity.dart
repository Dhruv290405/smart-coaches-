class UserEntity {
  int? userId;
  String? firstName;
  String? lastName;
  String? mobileNumber;
  String? email;
  String? organisationType;
  String? createdDate;
  String? role;
  String? employeeId;
  int? zoneId;
  String? zoneName;
  int? divisionId;
  String? divisionName;
  String? regionIds;
  String? regionNames;
  String? panCardNo;
  String? aadharNo;
  int? roleId;
  String? approvalStatus;

  UserEntity({
    this.userId,
    this.firstName,
    this.lastName,
    this.mobileNumber,
    this.email,
    this.organisationType,
    this.createdDate,
    this.role,
    this.employeeId,
    this.zoneId,
    this.zoneName,
    this.divisionId,
    this.divisionName,
    this.regionIds,
    this.regionNames,
    this.panCardNo,
    this.aadharNo,
    this.roleId,
    this.approvalStatus,
  });

  UserEntity copyWith({
    int? userId,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? email,
    String? organisationType,
    String? createdDate,
    String? role,
    String? employeeId,
    int? zoneId,
    int? divisionId,
    String? regionIds,
    String? regionNames,
    String? panCardNo,
    String? aadharNo,
    int? roleId,
    String? approvalStatus,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      organisationType: organisationType ?? this.organisationType,
      createdDate: createdDate ?? this.createdDate,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      zoneId: zoneId ?? this.zoneId,
      divisionId: divisionId ?? this.divisionId,
      regionIds: regionIds ?? this.regionIds,
      regionNames: regionNames ?? this.regionNames,
      panCardNo: panCardNo ?? this.panCardNo,
      aadharNo: aadharNo ?? this.aadharNo,
      roleId: roleId ?? this.roleId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserEntity &&
              runtimeType == other.runtimeType &&
              userId == other.userId &&
              approvalStatus == other.approvalStatus;

  @override
  int get hashCode => userId.hashCode ^ approvalStatus.hashCode;
}