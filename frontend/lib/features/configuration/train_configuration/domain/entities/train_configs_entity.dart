import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configs_list_response.dart';

class TrainConfigsEntity {
  final dynamic trainId;
  final String? trainNumber;
  final String? trainName;
  final dynamic originationRegionId;
  final dynamic regionId;
  final dynamic departureStationId;
  final dynamic destinationStationId;
  final dynamic numberOfCoaches;
  final String? line;
  final String? trainOperator;
  final String? engineNumber;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String? createdBy;
  final String? originationRegionName;
  final String? regionName;
  final String? departureStationName;
  final String? destinationStationName;
  final String? entityType;
  final List<CoachEntity>? coaches;
  final bool? isMapped;
  final Map<String, dynamic>? rawJson;

  const TrainConfigsEntity({
    this.trainId,
    this.originationRegionName,
    this.regionName,
    this.departureStationName,
    this.destinationStationName,
    this.entityType,
    this.trainNumber,
    this.trainName,
    this.originationRegionId,
    this.regionId,
    this.departureStationId,
    this.destinationStationId,
    this.numberOfCoaches,
    this.line,
    this.trainOperator,
    this.engineNumber,
    this.coaches,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.isMapped,
    this.rawJson,
  });

  factory TrainConfigsEntity.fromModel(TrainConfigsItem model) {
    return TrainConfigsEntity(
      trainId: model.trainId,
      trainNumber: model.trainNumber,
      trainName: model.trainName,
      originationRegionId: model.originationRegionId,
      regionId: model.regionId,
      departureStationId: model.departureStationId,
      destinationStationId: model.destinationStationId,
      numberOfCoaches: model.numberOfCoaches,
      line: Utils.normalizeDropDownValue(model.line, Constants.lineList),
      trainOperator: Utils.normalizeDropDownValue(model.trainOperator, Constants.trainOperatorList),
      engineNumber: model.engineNumber,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
      updatedAt: model.updatedAt,
      updatedBy: model.updatedBy,
      coaches:
          model.coaches?.map((e) => CoachEntity.fromModel(e)).toList() ?? [],
      originationRegionName: model.originationRegionName,
      regionName: model.regionName,
      departureStationName: model.departureStationName,
      destinationStationName: model.destinationStationName,
      entityType: model.entityType,
      isMapped: model.isMapped,
      rawJson: model.rawJson,
    );
  }
}
