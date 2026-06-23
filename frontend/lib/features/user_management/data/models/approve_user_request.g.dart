// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approve_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApproveUserRequest _$ApproveUserRequestFromJson(Map<String, dynamic> json) =>
    ApproveUserRequest(
      targetUserId: (json['target_user_id'] as num?)?.toInt(),
      roleId: (json['role_id'] as num?)?.toInt(),
      approvalStatus: json['approval_status'] as String?,
    );

Map<String, dynamic> _$ApproveUserRequestToJson(ApproveUserRequest instance) =>
    <String, dynamic>{
      'target_user_id': instance.targetUserId,
      'role_id': instance.roleId,
      'approval_status': instance.approvalStatus,
    };
