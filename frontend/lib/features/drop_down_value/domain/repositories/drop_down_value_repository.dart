import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';

abstract class DropDownValueRepository {
  Future<ZoneListData> loadZonesDropdowns();

  Future<DivisionListData> loadDivisionsDropdowns(int zoneId);

  Future<RegionListData> loadRegionsDropdowns(int divisionId);

  Future<List<RoleItem>> loadAllRoles();

  // Future<RoleListData> loadRolesDropdowns(String organizationType);

  Future<RoleListData> loadDefaultRolesDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    List<int>? trainIds,
    bool useToken,
  );

  Future<List<TrainItem>> loadTrainsDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    bool useToken,
    int? targetUserId,
  );
}
