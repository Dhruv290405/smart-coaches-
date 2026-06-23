import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/domain/usecases/drop_down_value_usecase.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';
import 'package:smart_coach_new/features/user_management/domain/usecases/user_management_usecase.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_event.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_state.dart';

@injectable
class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final DropDownValueUseCase dropDownValueUseCase;
  final UserManagementUseCase userManagementUseCase;

  List<UserEntity> _allUsers = [];
  List<UserEntity> _selectedUsers = [];
  PendingUsersRequest? request;

  UserManagementBloc({
    required this.userManagementUseCase,
    required this.dropDownValueUseCase,
  }) : super(UserManagementInitial()) {
    on<LoadUserManagement>(_onLoadUserManagement);
    on<ToggleUserSelection>(_onToggleUserSelection);
    on<ApproveOrRejectUsers>(_onApproveOrRejectUsers);
    on<LoadTrainsDropdowns>(_onLoadTrainsDropdowns);
    on<OnChangeTrain>(_onChangeTrain);
    on<UpdateTrainAndRole>(_onUpdateTrainAndRole);
  }

  void _onLoadUserManagement(
    LoadUserManagement event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());
    try {
      request = event.request;
      _allUsers = await userManagementUseCase.fetchUsers(
        request: event.request,
      );

      _selectedUsers = [];

      emit(
        UserManagementSuccess(
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    } catch (e) {
      emit(
        UserManagementFailure(
          e.toString(),
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    }
  }

  void _onToggleUserSelection(
    ToggleUserSelection event,
    Emitter<UserManagementState> emit,
  ) async {
    if (event.clearAll) {
      _selectedUsers.clear();
    } else {
      if (event.user != null) {
        if (event.actionRemoveUser) {
          if (_selectedUsers.contains(event.user)) {
            _selectedUsers.remove(event.user);
          }
        } else {
          _selectedUsers.add(event.user!);
        }
      }
    }
    emit(
      UserManagementSuccess(
        users: _allUsers,
        selectedUsers: _selectedUsers,
        request: request,
      ),
    );
  }

  void _onApproveOrRejectUsers(
    ApproveOrRejectUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      UserManagementActionInProgress(
        users: _allUsers,
        selectedUsers: _selectedUsers,
        request: request,
      ),
    );
    try {
      List<UserEntity> updatedUsers = List.from(_allUsers);

      for (ApproveUserRequest user in event.approveUserRequest) {
        int index = _allUsers.indexWhere((e) => e.userId == user.targetUserId);
        if (index != -1) {
          final updatedUser = updatedUsers[index].copyWith(
            approvalStatus: user.approvalStatus,
          );
          updatedUsers[index] = updatedUser;
        }
      }
      _allUsers = updatedUsers;

      add(ToggleUserSelection(clearAll: true));

      String message = await userManagementUseCase.approveOrRejectUsers(
        event.approveUserRequest,
      );

      emit(
        UserManagementActionSuccess(
          message,
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    } catch (e) {
      emit(
        UserManagementFailure(
          e.toString(),
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    }
  }

  void _onLoadTrainsDropdowns(
    LoadTrainsDropdowns event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      UserManagementLoading(
        users: _allUsers,
        selectedUsers: _selectedUsers,
        request: request,
      ),
    );
    try {

      final List<TrainItem> trains = await dropDownValueUseCase
          .loadTrainsDropdowns(
            event.zoneId,
            event.divisionId,
            event.regionId,
            targetUserId: event.targetUserId,
            useToken: true,
          );

      List<int> selectedTrainIds = trains
          // .where((item) => item.isMapped == true)
          .map((item) => item.trainId!)
          .toList();

      print('checkLength selectedTrainIds: $selectedTrainIds');

      final RoleListData roleListData = await dropDownValueUseCase
          .loadDefaultRolesDropdowns(
            event.zoneId,
            event.divisionId,
            event.regionId,
            selectedTrainIds,
            useToken: true,
          );
      List<RoleItem>? roles = roleListData.items;
      print('checkLength roles: ${roles?.length}');
      emit(
        LoadTrainsSuccess(
          trains,
          roles,
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    } catch (e) {
      emit(
        UserManagementFailure(
          e.toString(),
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    }
  }

  void _onChangeTrain(
    OnChangeTrain event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      UserManagementActionInProgress(
        users: _allUsers,
        selectedUsers: _selectedUsers,
        request: request,
      ),
    );
    try {
      List<int> selectedTrainIds = (event.selectedTrains ?? [])
          .where((item) => item.isMapped == true)
          .map((va) => va.trainId!)
          .toList();

      String regionIds = event.regionId ?? '';
      List<int> regionIdsList = [];
      if (regionIds.isNotEmpty) {
        regionIdsList = regionIds.split(',').map((e) => int.parse(e)).toList();
      }

      final RoleListData roleListData = await dropDownValueUseCase
          .loadDefaultRolesDropdowns(
            event.zoneId,
            event.divisionId,
            regionIdsList,
            selectedTrainIds,
            useToken: true,
          );
      List<RoleItem>? roles = roleListData.items;

      emit(
        LoadTrainsSuccess(
          event.selectedTrains,
          roles,
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    } catch (e) {
      emit(
        UserManagementFailure(
          e.toString(),
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    }
  }

  void _onUpdateTrainAndRole(
    UpdateTrainAndRole event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(
      UserManagementActionInProgress(
        users: _allUsers,
        selectedUsers: _selectedUsers,
        request: request,
      ),
    );
    try {
      await userManagementUseCase.changeRole(event.roleId, event.targetUserId);

      String changeTrainMessage = await userManagementUseCase.changeTrain(
        event.targetUserId,
        event.trainIds,
      );

      emit(
        UserManagementActionSuccess(
          changeTrainMessage,
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );

      add(ToggleUserSelection(clearAll: true));

      add(LoadUserManagement());
    } catch (e) {
      emit(
        UserManagementFailure(
          e.toString(),
          users: _allUsers,
          selectedUsers: _selectedUsers,
          request: request,
        ),
      );
    }
  }
}
