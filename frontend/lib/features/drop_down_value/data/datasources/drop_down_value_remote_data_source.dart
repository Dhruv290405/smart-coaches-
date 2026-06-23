import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/all_roles_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/division_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/zone_list_response.dart';

@injectable
class DropDownValueRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;
  DropDownValueRemoteDataSourceImpl(this.restClient, this.prefs);
  Future<ZoneListData> loadZonesDropdowns() async {
    return safeRequest(() async {
      final ZoneListResponse zoneListResponse = await restClient.getZones();
      return (zoneListResponse.data!);
    });
  }

  Future<DivisionListData> loadDivisionsDropdowns(int zoneId) async {
    return safeRequest(() async {
      final DivisionListResponse divisionListResponse = await restClient
          .getDivisions(zoneId);
      return (divisionListResponse.data!);
    });
  }

  Future<RegionListData> loadRegionsDropdowns(int divisionId) async {
    return safeRequest(() async {
      final RegionListResponse regionListResponse = await restClient.getRegions(
        divisionId,
      );
      return (regionListResponse.data!);
    });
  }

  Future<List<RoleItem>> loadAllRoles() async {
    return safeRequest(() async {
      final AllRolesResponse allRolesResponse = await restClient.getAllRoles();
      return (allRolesResponse.data ?? []);
    });
  }

  // Future<RoleListData> loadRolesDropdowns(String organizationType) async { //   return safeRequest(() async { //     final RoleListResponse roleListResponse = await restClient.getRoles( //       organizationType, //     ); //     return (roleListResponse.data!); //   }); // }

  Future<RoleListData> loadDefaultRolesDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    List<int>? trainIds,
    bool useToken,
  ) async {
    return safeRequest(() async {
      RoleListResponse roleListResponse;
      String? regionIdsParam = _getInString(regionId);
      String? trainIdsParam = _getInString(trainIds);
      if (useToken) {
        roleListResponse = await restClient.getDefaultRoles(
          zoneId,
          divisionId,
          regionIdsParam,
          trainIdsParam,
        );
      } else {
        roleListResponse = await restClient.getDefaultRolesWithToken(
          zoneId,
          divisionId,
          regionIdsParam,
          trainIdsParam,
        );
      }
      return (roleListResponse.data!);
    });
  }

  Future<List<TrainItem>> loadTrainsDropdowns(
    int? zoneId,
    int? divisionId,
    List<int>? regionId,
    bool useToken,
    int? targetUserId,
  ) async {
    return safeRequest(() async {
      TrainListResponse trainResponse;
      String? regionIdsParam = _getInString(regionId);
      if (useToken) {
        trainResponse = await restClient.getTrainsWithToken(
          targetUserId,
          zoneId,
          divisionId,
          regionIdsParam,
        );
      } else {
        trainResponse = await restClient.getTrains(
          targetUserId,
          zoneId,
          divisionId,
          regionIdsParam,
        );
      }
      return (trainResponse.data?.trains ?? []);
    });
  }

  String? _getInString(List<int>? list) {
    return (list ?? []).join(
      ',',
    ); // String? regionIdsParam; // for (int i = 0; i < (list ?? []).length; i++) { //   regionIdsParam ??= ''; //   regionIdsParam += (list ?? [])[i].toString(); //   if (i != (list ?? []).length - 1) { //     regionIdsParam += ','; //   } // } // return regionIdsParam;
  } // Future<List<UserTrainItem>> loadUserTrains(int? userId) async { //   return safeRequest(() async { //     final UserTrainResponse userTrainResponse = await restClient //         .getUserTrains(userId); //     return (userTrainResponse.data?.trains ?? []); //   }); // }
}
