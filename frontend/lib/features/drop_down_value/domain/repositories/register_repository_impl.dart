import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/datasources/drop_down_value_remote_data_source.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/domain/repositories/drop_down_value_repository.dart';

@Injectable(as: DropDownValueRepository)
class DropDownValueRepositoryImpl implements DropDownValueRepository {
  final DropDownValueRemoteDataSourceImpl remoteDataSource;

  DropDownValueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ZoneListData> loadZonesDropdowns() =>
      remoteDataSource.loadZonesDropdowns();

  @override
  Future<DivisionListData> loadDivisionsDropdowns(int zoneId) =>
      remoteDataSource.loadDivisionsDropdowns(zoneId);

  @override
  Future<RegionListData> loadRegionsDropdowns(int divisionId) =>
      remoteDataSource.loadRegionsDropdowns(divisionId);

  @override
  Future<List<RoleItem>> loadAllRoles() =>
      remoteDataSource.loadAllRoles();

  // @override
  // Future<RoleListData> loadRolesDropdowns(String organizationType) =>
  //     remoteDataSource.loadRolesDropdowns(organizationType);

  @override
  Future<RoleListData> loadDefaultRolesDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    List<int>? trainIds,
    bool useToken,
  ) => remoteDataSource.loadDefaultRolesDropdowns(
    zoneId,
    divisionId,
    regionId,
    trainIds,
    useToken,
  );

  @override
  Future<List<TrainItem>> loadTrainsDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    bool useToken,
    int? targetUserId,
  ) => remoteDataSource.loadTrainsDropdowns(
    zoneId,
    divisionId,
    regionId,
    useToken,
    targetUserId,
  );

  // @override
  // Future<List<UserTrainItem>> loadUserTrains(int? userId) => remoteDataSource.loadUserTrains(userId);
}
