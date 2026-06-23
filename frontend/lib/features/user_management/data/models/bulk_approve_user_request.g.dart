// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_approve_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkApproveRequest _$BulkApproveRequestFromJson(Map<String, dynamic> json) =>
    BulkApproveRequest(
      users: (json['users'] as List<dynamic>)
          .map((e) => ApproveUserRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulkApproveRequestToJson(BulkApproveRequest instance) =>
    <String, dynamic>{'users': instance.users};
