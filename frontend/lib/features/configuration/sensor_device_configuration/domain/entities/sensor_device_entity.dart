import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_list_response.dart';

class SensorDeviceEntity {
  final int? sensorConfigId;
  final int? sensorTypeId;
  final String? sensorTypeName;
  final String? deviceId;
  final int? sensorMakeId;
  final String? installDate;
  final String? placement;
  final String? location;
  final String? remarks;
  final int? masterModuleId;
  final int? coachId;
  final String? shortName;
  final String? fullName;
  final String? description;
  final String? dataType;
  final double? frequencySecs;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;
  final String? deviceUniqueId;
  final String? timeUnit;
  final bool? isActive;
  final int? noOfSensors;
  final String? name;
  final int? moduleId;
  final String? moduleUniqueId;
  final String? makeModel;
  final String? firmwareVersion;
  final String? serialNumber;
  final String? installationDate;
  final String? placementType;
  final String? simNo;
  final String? serviceProviderPrimary;
  final String? serviceProviderSecondary;
  final String? activationDate;
  final String? simStatus;
  final String? rechargeDate;
  final String? batteryReplacementDate;
  final bool? dualProfileSupported;
  final bool? loraEnabled;
  final bool? esimEnabled;
  final int? batteryCapacity;
  final String? batteryType;
  final String? batteryRechargeDate;
  final String? createdDate;
  final String? updatedDate;
  final String? entityType;
  final int? trainId;
  final String? coachUniqueId;
  final String? coachDisplayId;
  final int? makeOfCoach;
  final int? typeOfCoach;
  final int? manufacturingYear;
  final int? position;
  final int? noOfMasterModule;
  final String? coachStatus;
  final int? totalDevicesAttached;
  final String? techCoachNo;
  final String? commCoachNo;
  final String? trainNo;
  final String? status;

  const SensorDeviceEntity({
    this.sensorConfigId,
    this.sensorTypeId,
    this.sensorTypeName,
    this.deviceId,
    this.sensorMakeId,
    this.installDate,
    this.placement,
    this.location,
    this.remarks,
    this.masterModuleId,
    this.coachId,
    this.shortName,
    this.fullName,
    this.description,
    this.dataType,
    this.frequencySecs,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deviceUniqueId,
    this.timeUnit,
    this.isActive,
    this.noOfSensors,
    this.name,
    this.moduleId,
    this.moduleUniqueId,
    this.makeModel,
    this.firmwareVersion,
    this.serialNumber,
    this.installationDate,
    this.placementType,
    this.simNo,
    this.serviceProviderPrimary,
    this.serviceProviderSecondary,
    this.activationDate,
    this.simStatus,
    this.rechargeDate,
    this.batteryReplacementDate,
    this.dualProfileSupported,
    this.loraEnabled,
    this.esimEnabled,
    this.batteryCapacity,
    this.batteryType,
    this.batteryRechargeDate,
    this.createdDate,
    this.updatedDate,
    this.entityType,
    this.trainId,
    this.coachUniqueId,
    this.coachDisplayId,
    this.makeOfCoach,
    this.typeOfCoach,
    this.manufacturingYear,
    this.position,
    this.noOfMasterModule,
    this.coachStatus,
    this.totalDevicesAttached,
    this.techCoachNo,
    this.commCoachNo,
    this.trainNo,
    this.status,
  });

  factory SensorDeviceEntity.fromModel(SensorDeviceItem model) {
    return SensorDeviceEntity(
      sensorConfigId: model.sensorConfigId,
      sensorTypeId: model.sensorTypeId,
      sensorTypeName: model.sensorTypeName,
      deviceId: model.deviceId,
      sensorMakeId: model.sensorMakeId,
      installDate: model.installDate,
      placement: model.placement,
      location: model.location,
      remarks: model.remarks,
      masterModuleId: model.masterModuleId,
      coachId: model.coachId,
      shortName: model.shortName,
      fullName: model.fullName,
      description: model.description,
      dataType: model.dataType,
      frequencySecs: model.frequencySecs,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
      updatedAt: model.updatedAt,
      updatedBy: model.updatedBy,
      deviceUniqueId: model.deviceUniqueId,
      timeUnit: model.timeUnit,
      isActive: model.isActive,
      noOfSensors: model.noOfSensors,
      name: model.name,
      moduleId: model.moduleId,
      moduleUniqueId: model.moduleUniqueId,
      makeModel: model.makeModel,
      firmwareVersion: model.firmwareVersion,
      serialNumber: model.serialNumber,
      installationDate: model.installationDate,
      placementType: model.placementType,
      simNo: model.simNo,
      serviceProviderPrimary: model.serviceProviderPrimary,
      serviceProviderSecondary: model.serviceProviderSecondary,
      activationDate: model.activationDate,
      simStatus: model.simStatus,
      rechargeDate: model.rechargeDate,
      batteryReplacementDate: model.batteryReplacementDate,
      dualProfileSupported: model.dualProfileSupported,
      loraEnabled: model.loraEnabled,
      esimEnabled: model.esimEnabled,
      batteryCapacity: model.batteryCapacity,
      batteryType: model.batteryType,
      batteryRechargeDate: model.batteryRechargeDate,
      createdDate: model.createdDate,
      updatedDate: model.updatedDate,
      entityType: model.entityType,
      trainId: model.trainId,
      coachUniqueId: model.coachUniqueId,
      coachDisplayId: model.coachDisplayId,
      makeOfCoach: model.makeOfCoach,
      typeOfCoach: model.typeOfCoach,
      manufacturingYear: model.manufacturingYear,
      position: model.position,
      noOfMasterModule: model.noOfMasterModule,
      coachStatus: model.coachStatus,
      totalDevicesAttached: model.totalDevicesAttached,
      techCoachNo: model.techCoachNo,
      commCoachNo: model.commCoachNo,
      trainNo: model.trainNo,
      status: model.status,
    );
  }
}
