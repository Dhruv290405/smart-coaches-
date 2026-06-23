import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';

class SensorTypeEntity {
  int? sensorTypeId;
  String? sensorTypeName;
  CategoryEntity? category;
  String? valueType;
  String? name;
  String? description;
  String? valueFormat;
  num? minExpectedValue;
  num? maxExpectedValue;
  String? samplingFrequency;
  String? timeInterval;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  List<UnitEntity>? units;
  List<DeviceEntity>? devices;

  List<String>? unitsNames;
  List<String>? devicesNames;

  SensorTypeEntity({
    this.sensorTypeId,
    this.sensorTypeName,
    this.category,
    this.valueType,
    this.name,
    this.description,
    this.valueFormat,
    this.minExpectedValue,
    this.maxExpectedValue,
    this.samplingFrequency,
    this.timeInterval,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.units,
    this.devices,
    this.unitsNames,
    this.devicesNames,
  });

  factory SensorTypeEntity.fromModel(SensorItem m) {
    String? createdAt =
    Utils.formatReadableDate(m.createdAt, dateFormat: Constants.dateTimeFormatToShowInTable);
    String? updatedAt =
    Utils.formatReadableDate(m.updatedAt, dateFormat: Constants.dateTimeFormatToShowInTable);

    List<String> unitNameList = [];
    List<String> devicesNames = [];

    List<UnitEntity>? unitList = m.units
        ?.map((u) {
      unitNameList.add(u.unit ?? '');
      return UnitEntity(
        unitId: u.unitId,
        unit: u.unit,
      );
    })
        .toList();

    List<DeviceEntity>? deviceList = m.devices
        ?.map((d) {
      devicesNames.add(d.shortName ?? '');
      return DeviceEntity(
        deviceId: d.deviceId,
        shortName: d.shortName,
        fullName: d.fullName,
        deviceUniqueId: d.deviceUniqueId,
      );
    })
        .toList();

    return SensorTypeEntity(
      sensorTypeId: m.sensorTypeId,
      sensorTypeName: m.sensorTypeName,
      category: m.category != null
          ? CategoryEntity(
        id: m.category?.id,
        name: m.category?.name,
      )
          : null,
      valueType: m.valueType,
      name: m.name,
      description: m.description,
      valueFormat: Utils.normalizeDropDownValue(m.valueFormat, Constants.valueFormats),
      minExpectedValue: m.minExpectedValue,
      maxExpectedValue: m.maxExpectedValue,
      samplingFrequency: m.samplingFrequency,
      timeInterval: Utils.normalizeDropDownValue(m.timeInterval, Constants.evaluationUnitValues),
      isActive: m.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: m.createdBy,
      updatedBy: m.updatedBy,
      units: unitList,
      devices: deviceList,
      unitsNames: unitNameList,
      devicesNames: devicesNames,
    );
  }

}

class CategoryEntity {
  int? id;
  String? name;

  CategoryEntity({this.id, this.name});
}

class UnitEntity {
  int? unitId;
  String? unit;

  UnitEntity({this.unitId, this.unit});
}

class DeviceEntity {
  String? deviceId;
  String? shortName;
  String? fullName;
  String? deviceUniqueId;

  DeviceEntity({this.deviceId, this.shortName, this.fullName, this.deviceUniqueId});

  factory DeviceEntity.fromModel(DeviceItem model) {
    return DeviceEntity(
      deviceId: model.deviceId,
      shortName: model.shortName,
      fullName: model.fullName,
      deviceUniqueId: model.deviceUniqueId,
    );
  }
}
