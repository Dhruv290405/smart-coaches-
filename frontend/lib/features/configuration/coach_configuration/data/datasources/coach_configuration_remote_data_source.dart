import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/create_coach_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/delete_coach_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/edit_coach_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart'
    as device_response;
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

@injectable
class SensorDeviceConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  SensorDeviceConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

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

  Future<List<CoachItem>> fetchCoachList() async {
    return safeRequest(() async {
      final CoachListResponse trainListResponse = await restClient
          .getCoachList();
      if (!trainListResponse.success || trainListResponse.data == null) {
        throw Exception(trainListResponse.message);
      }
      return trainListResponse.data!;
    });
  }

  Future<String> createCoachConfiguration(
    CoachConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final CreateCoachConfigurationResponse configurationResponse =
          await restClient.createCoachConfiguration(
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editCoachConfiguration(
    int? trainId,
    CoachConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final EditCoachConfigurationResponse configurationResponse =
          await restClient.editCoachConfiguration(
            trainId,
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteCoachConfiguration(int? trainId) async {
    return safeRequest(() async {
      final DeleteCoachConfigurationResponse deleteCoachConfigurationResponse =
          await restClient.deleteCoachConfiguration(trainId);
      if (!deleteCoachConfigurationResponse.success) {
        throw Exception(deleteCoachConfigurationResponse.message);
      }
      return deleteCoachConfigurationResponse.message;
    });
  }

  Future<List<CoachMakeItem>> getCoachMakeList() async {
    return safeRequest(() async {
      final CoachMakeListResponse coachMakeListResponse = await restClient
          .getCoachMakeList();
      if (!coachMakeListResponse.success) {
        throw Exception(coachMakeListResponse.message);
      }
      return coachMakeListResponse.data ?? [];
    });
  }

  Future<List<CoachTypeItem>> getCoachTypeList() async {
    return safeRequest(() async {
      final CoachTypeListResponse coachTypeListResponse = await restClient
          .getCoachTypeList();
      if (!coachTypeListResponse.success) {
        throw Exception(coachTypeListResponse.message);
      }
      return coachTypeListResponse.data ?? [];
    });
  }

  Future<CoachConfigResponse> getCoachConfig(String coachNo) async {
    return safeRequest(() async {
      final response = await restClient.getCoachConfig(coachNo);
      if (!response.success) {
        throw ApiException(response.message);
      }
      return response;
    });
  }
}
