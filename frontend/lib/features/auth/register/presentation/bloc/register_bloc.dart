import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_request.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';
import 'package:smart_coach_new/features/auth/register/domain/usecases/register_usecase.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_event.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_state.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/domain/usecases/drop_down_value_usecase.dart';

@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;
  final DropDownValueUseCase dropDownValueUseCase;
  final Prefs prefs;
  bool isIdTypeIsPan = true;
  final String genderDropDownKey = 'gender';
  final String organizationTypeDropDownKey = 'organizationType';
  final String zoneDropDownKey = 'zone';
  final String divisionDropDownKey = 'division';
  final String regionDropDownKey = 'region';
  final String trainDropDownKey = 'train';
  final String roleDropDownKey = 'role';

  RegisterBloc(
      {required this.registerUseCase, required this.dropDownValueUseCase, required this.prefs})
      : super(RegisterState.initial()) {
    on<IdTypeToggled>(_onIdTypeToggled);
    on<LoadZonesDropdowns>(_onLoadZonesDropdowns);
    on<LoadDivisionsDropdowns>(_onLoadDivisionsDropdowns);
    on<LoadRegionsDropdowns>(_onLoadRegionsDropdowns);
    on<LoadAllRoles>(_onLoadAllRoles);
    on<LoadTrainsDropdowns>(_onLoadTrainsDropdowns);
    on<LoadRolesDropdowns>(_onLoadRolesDropdowns);
    on<UpdateDropdownValue>(_onUpdateDropdownValue);
    on<SubmitRegister>(_onSubmitRegister);
  }

  void _onIdTypeToggled(IdTypeToggled event, Emitter<RegisterState> emit) {
    isIdTypeIsPan = event.isIdTypeIsPan;

    emit(state.copyWith(
      isIdTypeIsPan: isIdTypeIsPan,
    ));
  }

  void _onLoadZonesDropdowns(
      LoadZonesDropdowns event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final values = await dropDownValueUseCase.loadZonesDropdowns();
      emit(state.copyWith(
        isLoading: false,
        zones: values.items,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dropdowns'));
    }
  }

  void _onLoadDivisionsDropdowns(
      LoadDivisionsDropdowns event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final values =
          await dropDownValueUseCase.loadDivisionsDropdowns(event.zoneId);

      int allIndex = (values.items ?? []).indexWhere((item) => (item.name ?? '').toLowerCase() == 'all');

      if(allIndex != -1) {
        int id = (values.items ?? [])[allIndex].divisionId!;
        add(UpdateDropdownValue(key: divisionDropDownKey, value: id));
        add(LoadRegionsDropdowns(divisionId: id));
      }

      // if ((values.items ?? []).length == 1 && (values.items ?? []).first.divisionId == -1) {
      //   add(UpdateDropdownValue(key: divisionDropDownKey, value: (values.items ?? []).first.divisionId));
      //   add(LoadRegionsDropdowns(divisionId: (values.items ?? []).first.divisionId!));
      // }

      emit(state.copyWith(
        isLoading: false,
        divisions: values.items,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dropdowns'));
    }
  }

  void _onLoadRegionsDropdowns(
      LoadRegionsDropdowns event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final values = await dropDownValueUseCase.loadRegionsDropdowns(event.divisionId);

      int allIndex = (values.items ?? []).indexWhere((item) => (item.name ?? '').toLowerCase() == 'all');

      if(allIndex != -1) {
        int regionId = (values.items ?? [])[allIndex].regionId!;
        add(UpdateDropdownValue(key: regionDropDownKey, value: [regionId]));
        if (_isTrainOperatorRole()) {
          add(LoadTrainsDropdowns(zoneId: state.registerRequest.zoneId, divisionId: state.registerRequest.divisionId, regionId: [regionId],));
        }
      }

      // if ((values.items ?? []).length == 1 && (values.items ?? []).first.regionId == -1) {
      //   int regionId = (values.items ?? []).first.regionId!;
      //   add(UpdateDropdownValue(key: regionDropDownKey, value: [regionId]));
      //   add(LoadTrainsDropdowns(zoneId: state.registerRequest.zoneId, divisionId: state.registerRequest.divisionId, regionId: [regionId],));
      // }

      emit(state.copyWith(
        isLoading: false,
        regions: values.items,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dropdowns'));
    }
  }

  bool _isTrainOperatorRole() {
    final roleId = state.registerRequest.roleId;
    if (roleId == null) return false;

    final selectedRole = state.jobRoles.firstWhere(
      (role) => role.roleId == roleId,
      orElse: () => state.jobRoles.first,
    );

    return selectedRole.name?.toLowerCase() == 'train operator';
  }

  void _onLoadAllRoles(
      LoadAllRoles event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final roles = await dropDownValueUseCase.loadAllRoles();
      emit(state.copyWith(
        isLoading: false,
        jobRoles: roles,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load roles'));
    }
  }

  void _onLoadTrainsDropdowns(
      LoadTrainsDropdowns event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final List<TrainItem> values = await dropDownValueUseCase.loadTrainsDropdowns(event.zoneId, event.divisionId, event.regionId);

      int allIndex = values.indexWhere((item) => (item.trainName ?? '').toLowerCase() == 'all');

      if(allIndex != -1) {
        int trainId = values[allIndex].trainId!;
        add(UpdateDropdownValue(key: trainDropDownKey, value: [trainId]));
      }

      // if ((values.trains ?? []).length == 1 && (values.trains ?? []).first.trainId == -1) {
      //   int trainId = (values.trains ?? []).first.trainId!;
      //   add(UpdateDropdownValue(key: trainDropDownKey, value: [trainId]));
      //   add(LoadRolesDropdowns(zoneId: state.registerRequest.zoneId, divisionId: state.registerRequest.divisionId, regionId: state.registerRequest.regionIdList, trainIds: [trainId],));
      // }

      emit(state.copyWith(
        isLoading: false,
        trains: values,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dropdowns'));
    }
  }

  void _onLoadRolesDropdowns(
      LoadRolesDropdowns event, Emitter<RegisterState> emit) async {

    state.registerRequest.roleId = null;

    emit(state.copyWith(isLoading: true, registerRequest: state.registerRequest));
    try {
      final values = await dropDownValueUseCase.loadDefaultRolesDropdowns(event.zoneId, event.divisionId, event.regionId, event.trainIds);

      if ((values.items ?? []).length == 1) {
        int roleId = (values.items ?? []).first.roleId!;
        add(UpdateDropdownValue(key: roleDropDownKey, value: roleId));
      }

      emit(state.copyWith(
        isLoading: false,
        jobRoles: values.items,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load dropdowns'));
    }
  }

  void _onUpdateDropdownValue(
      UpdateDropdownValue event, Emitter<RegisterState> emit) {
    RegisterRequest updated = state.registerRequest;

    if (event.key == genderDropDownKey) {
      updated = updated.copyWith(gender: event.value);
    } else if (event.key == organizationTypeDropDownKey) {
      updated = updated.copyWith(
        organisationType: event.value,
        organisationName: '',
      );
    } else if (event.key == zoneDropDownKey) {
      updated = updated.copyWith(zoneId: event.value);

      add(LoadDivisionsDropdowns(zoneId: event.value));
    } else if (event.key == divisionDropDownKey) {
      updated = updated.copyWith(divisionId: event.value);
    } else if (event.key == regionDropDownKey) {
      updated = updated.copyWith(regionIdList: event.value);
    } else if (event.key == trainDropDownKey) {
      updated = updated.copyWith(trainIdList: event.value);
    } else if (event.key == roleDropDownKey) {
      updated = updated.copyWith(roleId: event.value);
    }

    emit(state.copyWith(registerRequest: updated));
  }

  // void _onUpdateDropdownValue(
  //     UpdateDropdownValue event, Emitter<RegisterState> emit) {
  //   final updated = state.registerRequest;
  //
  //   if (event.key == genderDropDownKey) {
  //     updated.gender = event.value;
  //   } else if (event.key == organizationTypeDropDownKey) {
  //     updated.organisationType = event.value;
  //     updated.organisationName = '';
  //   } else if (event.key == zoneDropDownKey) {
  //     updated.zoneId = event.value;
  //   } else if (event.key == divisionDropDownKey) {
  //     updated.divisionId = event.value;
  //   } else if (event.key == regionDropDownKey) {
  //     if(event.value is List<int>) {
  //       updated.selectedRegionIds = event.value;
  //     } else {
  //       updated.regionId = event.value;
  //     }
  //   } else if (event.key == roleDropDownKey) {
  //     updated.roleId = event.value;
  //   }
  //   emit(state.copyWith(registerRequest: updated));
  // }

  void _onSubmitRegister(
      SubmitRegister event, Emitter<RegisterState> emit) async {
    log('checkDoRegister ${state.registerRequest.toJsonForApi()}');
    emit(state.copyWith(
      isSubmitting: true,
      isLoading: false,
      successMessage: null,
      errorMessage: null,
      submissionSuccess: false,
      errorList: null,
    ));
    try {
      final RegisterResponse result =
          await registerUseCase.register(state.registerRequest.toJsonForApi());
      if (result.success) {
        emit(state.copyWith(
          isSubmitting: false,
          isLoading: false,
          submissionSuccess: true,
          successMessage: result.message,
          errorList: null,
        ));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          isLoading: false,
          errorMessage: "Registration failed",
          successMessage: null,
          errorList: null,
        ));
      }
    } on MultiFieldsValidationException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        isLoading: false,
        successMessage: null,
        errorList: e.errors,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        isLoading: false,
        errorMessage: e.toString(),
        successMessage: null,
        errorList: null,
      ));
    }
  }
}
