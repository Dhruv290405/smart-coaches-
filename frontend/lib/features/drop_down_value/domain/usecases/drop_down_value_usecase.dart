import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/domain/repositories/drop_down_value_repository.dart';

@injectable
class DropDownValueUseCase {
  final DropDownValueRepository repository;
  DropDownValueUseCase(this.repository);
  Future<ZoneListData> loadZonesDropdowns() => repository.loadZonesDropdowns();
  Future<DivisionListData> loadDivisionsDropdowns(int zoneId) =>
      repository.loadDivisionsDropdowns(zoneId);
  Future<RegionListData> loadRegionsDropdowns(
    int divisionId,
  ) => repository.loadRegionsDropdowns(
    divisionId,
  );

  Future<List<RoleItem>> loadAllRoles() => repository.loadAllRoles();

  // Future<RoleListData> loadRolesDropdowns(String organizationType) => //     repository.loadRolesDropdowns(organizationType);
  Future<RoleListData> loadDefaultRolesDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    List<int>? trainIds, {
    bool useToken = false,
  }) => repository.loadDefaultRolesDropdowns(
    zoneId,
    divisionId,
    regionId,
    trainIds,
    useToken,
  );
  Future<List<TrainItem>> loadTrainsDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId, {
    bool useToken = false,
    int? targetUserId,
  }) => repository.loadTrainsDropdowns(
    zoneId,
    divisionId,
    regionId,
    useToken,
    targetUserId,
  ); // Future<List<UserTrainItem>> loadUserTrains(int? userId) => repository.loadUserTrains(userId);
}
