import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/create_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/delete_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/edit_train_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configs_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart'
    as device_response;
import 'package:smart_coach_new/features/drop_down_value/data/models/all_regions_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

@injectable
class CoachConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  CoachConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<device_response.DeviceItem>> fetchDevice({
    String? status,
    String? organisationType,
    String? fromDate,
    String? toDate,
  }) async {
    return safeRequest(() async {
      final device_response.DeviceListResponse deviceListResponse =
          await restClient.getDeviceList();
      if (!deviceListResponse.success || deviceListResponse.data == null) {
        throw Exception(deviceListResponse.message);
      }
      return deviceListResponse.data!;
    });
  }

  Future<List<TrainConfigsItem>> fetchTrainList() async {
    return safeRequest(() async {
      final TrainConfigsListResponse trainConfigsListResponse = await restClient
          .getTrainList();
      if (!trainConfigsListResponse.success || trainConfigsListResponse.data == null) {
        throw Exception(trainConfigsListResponse.message);
      }
      return trainConfigsListResponse.data ?? [];
    });
  }

  Future<String> createTrainConfiguration(
    TrainConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final CreateTrainConfigurationResponse configurationResponse =
          await restClient.createTrainConfiguration(
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editTrainConfiguration(
    int? trainId,
    TrainConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final EditTrainConfigurationResponse configurationResponse =
          await restClient.editTrainConfiguration(
            trainId,
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteTrainConfiguration(int? trainId) async {
    return safeRequest(() async {
      final DeleteTrainConfigurationResponse deleteTrainConfigurationResponse =
          await restClient.deleteTrainConfiguration(trainId);
      if (!deleteTrainConfigurationResponse.success) {
        throw Exception(deleteTrainConfigurationResponse.message);
      }
      return deleteTrainConfigurationResponse.message;
    });
  }

  Future<List<RegionItem>> getAllRegions() async {
    return safeRequest(() async {
      final AllRegionListResponse allRegionListResponse = await restClient
          .getAllRegions();
      if (!allRegionListResponse.success ||
          allRegionListResponse.data == null) {
        throw Exception(allRegionListResponse.message);
      }
      return allRegionListResponse.data?.regions ?? [];
    });
  }

  Future<List<StationItem>> getAllStations() async {
    return safeRequest(() async {
      final StationListResponse stationListResponse = await restClient
          .getAllStations();
      if (!stationListResponse.success || stationListResponse.data == null) {
        throw Exception(stationListResponse.message);
      }
      return stationListResponse.data?.stations ?? [];
    });
  }
}
