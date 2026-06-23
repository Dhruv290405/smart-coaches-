import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

abstract class SensorDeviceConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();

  Future<List<CoachEntity>> fetchCoachList();

  Future<String> createCoachConfiguration(
      CoachConfigurationRequest coachConfigurationRequest);

  Future<String> editCoachConfiguration(
      int? coachId, CoachConfigurationRequest coachConfigurationRequest);

  Future<String> deleteCoachConfiguration(int? coachId);

  Future<List<CoachMakeItem>> getCoachMakeList();
  Future<List<CoachTypeItem>> getCoachTypeList();
  Future<CoachConfigResponse> getCoachConfig(String coachNo);
}
