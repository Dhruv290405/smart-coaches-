import '../models/water_tank_model.dart';

class WliDummyData {
  static List<WaterTankModel> generateCoaches() {
    final coaches = <WaterTankModel>[];

    for (int i = 1; i <= 20; i++) {
      final underslungPercent = (i == 7 || i == 20) ? 15.0 : (i == 4 || i == 11 ? 35.0 : 85.0);
      final frontPercent = (i == 3 || i == 14) ? 18.0 : (i == 8 ? 38.0 : 90.0);
      final rearPercent = (i == 3) ? 20.0 : (i == 14 ? 25.0 : (i == 8 ? 40.0 : 88.0));

      // Underslung card
      coaches.add(WaterTankModel(
        source: WliSource(
          companyName: "VASP Rails Tech",
          systemType: "WLI",
          deviceId: "F24ENWR${40 + i}",
        ),
        location: WliLocation(
          coachId: "COACH_B$i",
          coachName: "B$i - AC 3 Tier",
        ),
        messageType: "METRICS",
        timestamp: "2026-04-23T15:00:00Z",
        placement: WliPlacement(
          type: "UNDERSLUNG",
          sensorCount: 1,
          position: ["CENTER"],
        ),
        assets: [
          WliAsset(
            assetId: "WLI-UND-00$i",
            assetName: "Water Tank Sensor",
            rawValue: 414,
            levelCm: 28.0,
            volumeLiters: 155.4,
            percentFull: underslungPercent,
          ),
        ],
      ));

      // Overhead card
      coaches.add(WaterTankModel(
        source: WliSource(
          companyName: "VASP Rails Tech",
          systemType: "WLI",
          deviceId: "F24ENWR${60 + i}",
        ),
        location: WliLocation(
          coachId: "COACH_B$i",
          coachName: "B$i - AC 3 Tier",
        ),
        messageType: "METRICS",
        timestamp: "2026-04-23T15:00:00Z",
        placement: WliPlacement(
          type: "OVERHEAD",
          sensorCount: 2,
          position: ["FRONT_END", "REAR_END"],
        ),
        assets: [
          WliAsset(
            assetId: "WLI-OHF-00$i",
            assetName: "Water Tank Sensor - Front",
            rawValue: 414,
            levelCm: 28.0,
            volumeLiters: 155.4,
            percentFull: frontPercent,
          ),
          WliAsset(
            assetId: "WLI-OHR-00$i",
            assetName: "Water Tank Sensor - Rear",
            rawValue: 410,
            levelCm: 27.0,
            volumeLiters: 150.2,
            percentFull: rearPercent,
          ),
        ],
      ));
    }

    return coaches;
  }
}