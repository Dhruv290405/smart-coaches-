import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/user_management/data/datasources/user_manaagement_remote_data_source.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository.dart';

@Injectable(as: UserManagementRepository)
class UserManagementRepositoryRepositoryImpl
    implements UserManagementRepository {
  final UserManagementRemoteDataSourceImpl remoteDataSource;

  UserManagementRepositoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserEntity>> fetchUsers({PendingUsersRequest? request}) async {
    final models = await remoteDataSource.fetchUsers(request: request);
    return models
        .map((m) => UserEntity(
              userId: m.userId,
              firstName: m.firstName,
              lastName: m.lastName,
              mobileNumber: m.mobileNumber,
              email: m.email,
              organisationType: m.organisationType,
              createdDate: m.createdDate,
              role: m.role,
              employeeId: m.employeeId,
              zoneId: m.zoneId,
              zoneName: m.zoneName,
              divisionId: m.divisionId,
              regionIds: m.regionIds,
              regionNames: m.regionNames,
              divisionName: m.divisionName,
              panCardNo: m.panCardNo,
              aadharNo: m.aadharNo,
              roleId: m.roleId,
              approvalStatus: m.approvalStatus,
            ))
        .toList();
  }

  @override
  Future<String> approveOrRejectUsers(List<ApproveUserRequest> usersIdList) {
    return remoteDataSource.approveOrRejectUsers(usersIdList);
  }

  @override
  Future<String> changeRole(int? roleId, int? targetUserId) {
    return remoteDataSource.changeRole(roleId, targetUserId);
  }

  @override
  Future<String> changeTrain(int? targetUserId, List<int>? trainIds) {
    return remoteDataSource.changeTrain(targetUserId, trainIds);
  }
}
