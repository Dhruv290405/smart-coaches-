import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';

class DeviceEntity {
  String? deviceId;
  String? shortName;
  String? fullName;
  String? description;
  int? numberOfSensors;
  double? frequency;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  int? isActive;
  String? dataType;
  String? timeUnit;
  int? masterModuleId;
  String? deviceUniqueId;
  String? masterModuleSerial;
  String? coachUniqueId;
  int? trainNumber;
  String? trainName;
  String? deviceTypeName;
  String? deviceModel;

  DeviceEntity({
    this.deviceId,
    this.shortName,
    this.fullName,
    this.description,
    this.numberOfSensors,
    this.frequency,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
    this.dataType,
    this.timeUnit,
    this.masterModuleId,
    this.deviceUniqueId,
    this.masterModuleSerial,
    this.coachUniqueId,
    this.trainNumber,
    this.trainName,
    this.deviceTypeName,
    this.deviceModel,
  });

  factory DeviceEntity.fromModel(DeviceItem model) {
    return DeviceEntity(
      deviceId: model.deviceId,
      shortName: model.shortName,
      fullName: model.fullName,
      description: model.description,
      numberOfSensors: model.numberOfSensors,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      createdBy: model.createdBy,
      updatedBy: model.updatedBy,
      isActive: model.isActive,
      dataType: model.dataType,
      timeUnit: model.timeUnit,
      masterModuleId: model.masterModuleId,
      deviceUniqueId: model.deviceUniqueId,
      masterModuleSerial: model.masterModuleSerial,
      coachUniqueId: model.coachUniqueId,
      trainNumber: model.trainNumber,
      trainName: model.trainName,
      deviceTypeName: model.deviceTypeName,
      deviceModel: model.deviceModel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceEntity &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;
}
