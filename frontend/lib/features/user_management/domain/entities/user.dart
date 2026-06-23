class User {
  final int userId;
  final String name;
  final int mobileNumber;
  final String email;
  final String? gender;
  final String organisationType;
  final String organisationName;
  final int zoneId;
  final int divisionId;
  final int regionId;
  final int roleId;
  final String status;
  final String approvalStatus;
  final String createdDate;
  final String employeeId;
  final String panCardNo;
  final String userImage;

  User({
    required this.userId,
    required this.name,
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
    required this.userImage,
  });
}