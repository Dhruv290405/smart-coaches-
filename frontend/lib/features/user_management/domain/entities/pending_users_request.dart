class PendingUsersRequest {
  final List<String>? statusList;
  final List<String>? organizationTypeList;
  final String? fromDate;
  final String? toDate;

  PendingUsersRequest({
    this.statusList,
    this.organizationTypeList,
    this.fromDate,
    this.toDate,
  });
}
