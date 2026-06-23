import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';

class SensorCategoryEntity {
  final int? id;
  final String? name;
  final String? baseUnit;

  SensorCategoryEntity({
    this.id,
    this.name,
    this.baseUnit,
  });

  factory SensorCategoryEntity.fromModel(SensorCategoryItem model) {
    return SensorCategoryEntity(
      id: model.valueTypeId,
      name: model.name,
      baseUnit: model.baseUnit,
    );
  }
}
