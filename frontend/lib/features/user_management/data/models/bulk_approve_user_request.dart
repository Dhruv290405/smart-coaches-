import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';

part 'bulk_approve_user_request.g.dart';

@JsonSerializable()
class BulkApproveRequest {
  final List<ApproveUserRequest> users;

  BulkApproveRequest({required this.users});

  factory BulkApproveRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkApproveRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkApproveRequestToJson(this);
}
