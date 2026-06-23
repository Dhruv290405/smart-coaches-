class ProfileEntity {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String gender;
  final String organisationType;
  final String organisationName;
  final int zoneId;
  final int divisionId;
  final int regionId;
  final int roleId;
  final String status;
  final String approvalStatus;
  final String employeeId;
  final String panCardNo;
  final String aadharNo;
  final String? aadharImg;
  final String? panCardImage;
  final String companyId;
  final String? userImage;
  final String createdDate;
  final String updatedDate;

  ProfileEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.gender,
    required this.organisationType,
    required this.organisationName,
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
    required this.roleId,
    required this.status,
    required this.approvalStatus,
    required this.employeeId,
    required this.panCardNo,
    required this.aadharNo,
    required this.aadharImg,
    required this.panCardImage,
    required this.companyId,
    required this.userImage,
    required this.createdDate,
    required this.updatedDate,
  });
}