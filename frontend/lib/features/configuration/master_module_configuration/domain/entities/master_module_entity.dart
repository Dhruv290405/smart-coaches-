import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class MasterModuleEntity {
  final int? moduleId;
  final String? moduleUniqueId;
  final String? makeModel;
  final String? firmwareVersion;
  final String? serialNumber;
  final String? installationDate;
  final String? location;
  final String? placementType;
  final String? simNo;
  final String? serviceProviderPrimary;
  final String? serviceProviderSecondary;
  final String? activationDate;
  final String? simStatus;
  final String? batteryReplacementDate;
  final bool dualProfileSupported;
  final bool loraEnabled;
  final bool esimEnabled;
  final int? batteryCapacity;
  final String? batteryType;
  final int? createdBy;
  final String? createdDate;
  final int? updatedBy;
  final String? updatedDate;
  final String? rechargeDate;
  final String? batteryRechargeDate;
  final String? createdByName;
  final String? updatedByName;
  final CoachEntity? coach;
  final TrainEntity? train;
  final List<String> deviceNames;
  final List<DeviceEntity>? devices;

  const MasterModuleEntity({
    this.moduleId,
    this.moduleUniqueId,
    this.makeModel,
    this.firmwareVersion,
    this.serialNumber,
    this.installationDate,
    this.location,
    this.placementType,
    this.simNo,
    this.serviceProviderPrimary,
    this.serviceProviderSecondary,
    this.activationDate,
    this.simStatus,
    this.batteryReplacementDate,
    this.dualProfileSupported = false,
    this.loraEnabled = false,
    this.esimEnabled = false,
    this.batteryCapacity,
    this.batteryType,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.rechargeDate,
    this.batteryRechargeDate,
    this.createdByName,
    this.updatedByName,
    this.coach,
    this.train,
    this.deviceNames = const [],
    this.devices,
  });

  factory MasterModuleEntity.fromModel(MasterModuleItem model) {
    List<DeviceEntity>? devices = model.devices
        ?.map(DeviceEntity.fromModel)
        .toList();
    return MasterModuleEntity(
      moduleId: model.moduleId,
      moduleUniqueId: model.moduleUniqueId,
      makeModel: model.makeModel,
      firmwareVersion: model.firmwareVersion,
      serialNumber: model.serialNumber,
      installationDate: model.installationDate,
      location: Utils.normalizeDropDownValue(
        model.location,
        Constants.locationList,
      ),
      placementType: Utils.normalizeDropDownValue(
        model.placementType,
        Constants.placementTypeList,
      ),
      simNo: model.simNo,
      serviceProviderPrimary: Utils.normalizeDropDownValue(
        model.serviceProviderPrimary,
        Constants.serviceProviderList,
      ),
      serviceProviderSecondary: Utils.normalizeDropDownValue(
        model.serviceProviderSecondary,
        Constants.serviceProviderList,
      ),
      activationDate: model.activationDate,
      simStatus: Utils.normalizeDropDownValue(
        model.simStatus,
        Constants.simStatusList,
      ),
      batteryReplacementDate: model.batteryReplacementDate,
      dualProfileSupported: model.dualProfileSupported ?? false,
      loraEnabled: model.loraEnabled ?? false,
      esimEnabled: model.esimEnabled ?? false,
      batteryCapacity: model.batteryCapacity,
      batteryType: Utils.normalizeDropDownValue(
        model.batteryType,
        Constants.batteryTypeList,
      ),
      createdBy: model.createdBy,
      createdDate: model.createdDate,
      updatedBy: model.updatedBy,
      updatedDate: model.updatedDate,
      rechargeDate: model.rechargeDate,
      batteryRechargeDate: model.batteryRechargeDate,
      createdByName: model.createdByName,
      updatedByName: model.updatedByName,
      coach: model.coach != null ? CoachEntity.fromModel(model.coach!) : null,
      train: model.train != null ? TrainEntity.fromModel(model.train!) : null,
      deviceNames: devices?.map((e) =>
        (e.fullName != null && e.fullName!.isNotEmpty)
            ? e.fullName!
            : (e.shortName != null && e.shortName!.isNotEmpty)
                ? e.shortName!
                : e.deviceUniqueId ?? ''
      ).toList() ?? [],
      devices: devices,
    );
  }
}
