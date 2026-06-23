class WaterTankModel {
  final WliSource source;
  final WliLocation location;
  final String messageType;
  final String timestamp;
  final WliPlacement placement;
  final List<WliAsset> assets;

  WaterTankModel({
    required this.source,
    required this.location,
    required this.messageType,
    required this.timestamp,
    required this.placement,
    required this.assets,
  });

  String get coachNumber => location.coachId;
  double get averagePercent => assets.isEmpty 
      ? 0.0 
      : assets.map((e) => e.percentFull).reduce((a, b) => a + b) / assets.length;

  String get status {
    if (averagePercent < 20) return 'Critical';
    if (averagePercent < 40) return 'Warning';
    return 'Good';
  }

  factory WaterTankModel.fromJson(Map<String, dynamic> json) {
    return WaterTankModel(
      source: WliSource.fromJson(json['source'] ?? {}),
      location: WliLocation.fromJson(json['location'] ?? {}),
      messageType: json['messageType'] ?? '',
      timestamp: json['timestamp'] ?? '',
      placement: WliPlacement.fromJson(json['placement'] ?? {}),
      assets: (json['assets'] as List? ?? [])
          .map((e) => WliAsset.fromJson(e))
          .toList(),
    );
  }
}

class WliSource {
  final String companyName;
  final String systemType;
  final String deviceId;

  WliSource({required this.companyName, required this.systemType, required this.deviceId});

  factory WliSource.fromJson(Map<String, dynamic> json) {
    return WliSource(
      companyName: json['companyName'] ?? '',
      systemType: json['systemType'] ?? '',
      deviceId: json['deviceId'] ?? '',
    );
  }
}

class WliLocation {
  final String coachId;
  final String coachName;

  WliLocation({required this.coachId, required this.coachName});

  factory WliLocation.fromJson(Map<String, dynamic> json) {
    return WliLocation(
      coachId: json['coachId'] ?? '',
      coachName: json['coachName'] ?? '',
    );
  }
}

class WliPlacement {
  final String type;
  final int sensorCount;
  final List<String> position;

  WliPlacement({required this.type, required this.sensorCount, required this.position});

  factory WliPlacement.fromJson(Map<String, dynamic> json) {
    return WliPlacement(
      type: json['type'] ?? '',
      sensorCount: json['sensorCount'] ?? 0,
      position: List<String>.from(json['position'] ?? []),
    );
  }
}

class WliAsset {
  final String assetId;
  final String assetName;
  final int rawValue;
  final double levelCm;
  final double volumeLiters;
  final double percentFull;

  WliAsset({
    required this.assetId,
    required this.assetName,
    required this.rawValue,
    required this.levelCm,
    required this.volumeLiters,
    required this.percentFull,
  });

  factory WliAsset.fromJson(Map<String, dynamic> json) {
    return WliAsset(
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      rawValue: json['rawValue'] ?? 0,
      levelCm: (json['levelCm'] ?? 0.0).toDouble(),
      volumeLiters: (json['volumeLiters'] ?? 0.0).toDouble(),
      percentFull: (json['percentFull'] ?? 0.0).toDouble(),
    );
  }
}
