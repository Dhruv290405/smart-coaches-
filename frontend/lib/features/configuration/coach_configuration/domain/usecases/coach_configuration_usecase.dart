import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/repositories/coach_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

@injectable
class CoachConfigurationUseCase {
  final SensorDeviceConfigurationRepository repository;

  CoachConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<CoachEntity>> fetchCoachList() => repository.fetchCoachList();

  Future<String> createCoachConfiguration(
          CoachConfigurationRequest trainConfigurationRequest) =>
      repository.createCoachConfiguration(trainConfigurationRequest);

  Future<String> editCoachConfiguration(
          int? coachId, CoachConfigurationRequest trainConfigurationRequest) =>
      repository.editCoachConfiguration(coachId, trainConfigurationRequest);

  Future<String> deleteCoachConfiguration(int? coachId) =>
      repository.deleteCoachConfiguration(coachId);

  Future<List<CoachMakeItem>> getCoachMakeList() => repository.getCoachMakeList();
  Future<List<CoachTypeItem>> getCoachTypeList() => repository.getCoachTypeList();
  Future<CoachConfigResponse> getCoachConfig(String coachNo) => repository.getCoachConfig(coachNo);
}
