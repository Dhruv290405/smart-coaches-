import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/create_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/delete_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/edit_master_module_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart'
    as device_response;

@injectable
class MasterModuleConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  MasterModuleConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

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

  Future<List<MasterModuleItem>> fetchMasterModuleList() async {
    return safeRequest(() async {
      final MasterModuleListResponse masterModuleListResponse = await restClient
          .getMasterModuleList();
      if (!masterModuleListResponse.success ||
          masterModuleListResponse.data == null) {
        throw Exception(masterModuleListResponse.message);
      }
      return masterModuleListResponse.data!;
    });
  }

  Future<String> createMasterModuleConfiguration(
    MasterModuleConfigurationRequest masterModuleConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final CreateMasterModuleConfigurationResponse configurationResponse =
          await restClient.createMasterModuleConfiguration(
            masterModuleConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editMasterModuleConfiguration(
    int? moduleId,
    MasterModuleConfigurationRequest masterModuleConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final EditMasterModuleConfigurationResponse configurationResponse =
          await restClient.editMasterModuleConfiguration(
            moduleId,
            masterModuleConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteMasterModuleConfiguration(int? moduleId) async {
    return safeRequest(() async {
      final DeleteMasterModuleConfigurationResponse
      deleteMasterModuleConfigurationResponse = await restClient
          .deleteMasterModuleConfiguration(moduleId);
      if (!deleteMasterModuleConfigurationResponse.success) {
        throw Exception(deleteMasterModuleConfigurationResponse.message);
      }
      return deleteMasterModuleConfigurationResponse.message;
    });
  }

  Future<List<CoachItem>> getAllCoachesList() async {
    return safeRequest(() async {
      final CoachListResponse coachListResponse = await restClient
          .getCoachList();
      if (!coachListResponse.success || coachListResponse.data == null) {
        throw Exception(coachListResponse.message);
      }
      return coachListResponse.data ?? [];
    });
  }
}
