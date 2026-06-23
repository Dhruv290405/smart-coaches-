import 'package:equatable/equatable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';

abstract class UserManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserManagement extends UserManagementEvent {
  PendingUsersRequest? request;

  LoadUserManagement({this.request});
}

class ToggleUserSelection extends UserManagementEvent {
  final UserEntity? user;
  final bool actionRemoveUser;
  final bool clearAll;

  ToggleUserSelection({
    this.user,
    this.actionRemoveUser = false,
    this.clearAll = false,
  });
}

class ApproveOrRejectUsers extends UserManagementEvent {
  final List<ApproveUserRequest> approveUserRequest;

  ApproveOrRejectUsers(this.approveUserRequest);
}

class LoadTrainsDropdowns extends UserManagementEvent {
  final int? targetUserId;
  final int? zoneId;
  final int? divisionId;
  final List<int>? regionId;

  LoadTrainsDropdowns({
    required this.targetUserId,
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
  });

  @override
  List<Object?> get props => [targetUserId, zoneId, divisionId, regionId];
}

class OnChangeTrain extends UserManagementEvent {
  final int? zoneId;
  final int? divisionId;
  final String? regionId;
  final List<TrainItem>? selectedTrains;

  OnChangeTrain({
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
    this.selectedTrains,
  });

  @override
  List<Object?> get props => [zoneId, divisionId, regionId, selectedTrains];
}

class UpdateTrainAndRole extends UserManagementEvent {
  final int? targetUserId;
  final int? roleId;
  final List<int>? trainIds;

  UpdateTrainAndRole({
    required this.targetUserId,
    required this.roleId,
    required this.trainIds,
  });

  @override
  List<Object?> get props => [targetUserId, roleId, trainIds];
}
