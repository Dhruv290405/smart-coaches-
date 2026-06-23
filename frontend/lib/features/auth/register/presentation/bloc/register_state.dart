import 'package:equatable/equatable.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_request.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/domain/entities/organization_item.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool submissionSuccess;
  final String? successMessage;
  final String? errorMessage;
  final List<String>? errorList;
  final bool isIdTypeIsPan;

  final List<OrganizationItem> organizationTypes;
  final List<ZoneItem> zones;
  final List<DivisionItem> divisions;
  final List<RegionItem> regions;
  final List<TrainItem> trains;
  final List<RoleItem> jobRoles;
  final RegisterRequest registerRequest;

  const RegisterState({
    required this.isLoading,
    required this.isSubmitting,
    required this.submissionSuccess,
    required this.successMessage,
    required this.errorMessage,
    required this.isIdTypeIsPan,
    required this.errorList,
    required this.organizationTypes,
    required this.zones,
    required this.divisions,
    required this.regions,
    required this.trains,
    required this.jobRoles,
    required this.registerRequest,
  });

  factory RegisterState.initial() => RegisterState(
    isLoading: false,
    isSubmitting: false,
    submissionSuccess: false,
    successMessage: null,
    isIdTypeIsPan: true,
    errorMessage: null,
    errorList: null,
    organizationTypes: [
      OrganizationItem(id: '0', name: OrganizationType.indianRailways.name),
      OrganizationItem(id: '1', name: OrganizationType.contractor.name),
    ],
    zones: [],
    divisions: [],
    regions: [],
    trains: [],
    jobRoles: [],
    registerRequest: RegisterRequest(),
  );

  RegisterState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? submissionSuccess,
    String? successMessage,
    bool? isIdTypeIsPan,
    String? errorMessage,
    List<String>? errorList,
    List<OrganizationItem>? organizationTypes,
    List<ZoneItem>? zones,
    List<DivisionItem>? divisions,
    List<RegionItem>? regions,
    List<TrainItem>? trains,
    List<RoleItem>? jobRoles,
    RegisterRequest? registerRequest,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      successMessage: successMessage ?? this.successMessage,
      isIdTypeIsPan: isIdTypeIsPan ?? this.isIdTypeIsPan,
      errorMessage: errorMessage,
      errorList: errorList,
      organizationTypes: organizationTypes ?? this.organizationTypes,
      zones: zones ?? this.zones,
      divisions: divisions ?? this.divisions,
      regions: regions ?? this.regions,
      trains: trains ?? this.trains,
      jobRoles: jobRoles ?? this.jobRoles,
      registerRequest: registerRequest ?? this.registerRequest,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    submissionSuccess,
    isIdTypeIsPan,
    errorMessage,
    organizationTypes,
    zones,
    divisions,
    regions,
    trains,
    jobRoles,
    registerRequest,
    errorList,
  ];
}
