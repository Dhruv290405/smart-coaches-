import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';

class SiUnitEntity {
  final int? id;
  final String? unit;
  final bool? isBaseUnit;

  SiUnitEntity({
    this.id,
    this.unit,
    this.isBaseUnit,
  });

  factory SiUnitEntity.fromModel(SiUnitItem model) {
    return SiUnitEntity(
      id: model.unitId,
      unit: model.unit,
      isBaseUnit: model.isBaseUnit == 1,
    );
  }
}
