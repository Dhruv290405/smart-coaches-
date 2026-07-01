class WaterTankModel {
  final WliSource source;
  final WliLocation location;
  final String messageType;
  final String timestamp;
  final WliPlacement placement;
  final List<WliAsset> assets;
  final String coachType;

  WaterTankModel({
    required this.source,
    required this.location,
    required this.messageType,
    required this.timestamp,
    required this.placement,
    required this.assets,
    this.coachType = '',
  });

  String get coachNumber => location.coachId;
  double get averagePercent => assets.isEmpty 
      ? 0.0 
      : assets.map((e) => e.percentFull).reduce((a, b) => a + b) / assets.length;

  String get status {
    if (averagePercent < 25) return 'Critical';
    if (averagePercent < 50) return 'Warning';
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

  factory WaterTankModel.fromFlatJson(Map<String, dynamic> json) {
    final deviceId = json['device_id']?.toString() ?? '';
    final coachName = json['coach_name']?.toString() ?? json['tech_coach_no']?.toString() ?? '';
    final percentFull = (json['percent_full'] is double)
        ? json['percent_full'] as double
        : double.tryParse(json['percent_full']?.toString() ?? '') ?? 0.0;
    final levelCm = (json['level_cm'] is double)
        ? json['level_cm'] as double
        : double.tryParse(json['level_cm']?.toString() ?? '') ?? 0.0;
    final volumeLiters = (json['volume_liters'] is double)
        ? json['volume_liters'] as double
        : double.tryParse(json['volume_liters']?.toString() ?? '') ?? 0.0;
    final placementType = json['placement_type']?.toString() ?? 'UNDERSLUNG';
    final rawTimestamp = json['timestamp']?.toString() ?? '';
    final trainNo = json['train_no']?.toString() ?? '';
    final coachIdRaw = json['coach_id'];

    final String coachIdStr;
    if (coachIdRaw is int) {
      coachIdStr = coachIdRaw.toString();
    } else {
      coachIdStr = coachIdRaw?.toString() ?? '';
    }

    // Extract train prefix from device_id for filtering
    final deviceIdParts = deviceId.split('_');
    final trainPrefix = deviceIdParts.length > 1 ? deviceIdParts[0] : trainNo;

    // Format timestamp properly
    String formattedTimestamp = rawTimestamp;
    try {
      final parsed = DateTime.parse(rawTimestamp);
      formattedTimestamp = parsed.toLocal().toIso8601String();
    } catch (_) {
      // keep original if parsing fails
    }

    final coachNameStr = trainNo.isNotEmpty ? '${trainNo}_${coachName}' : coachName;

    return WaterTankModel(
      source: WliSource(
        companyName: 'VASP Rails Tech',
        systemType: 'WLI',
        deviceId: deviceId.isNotEmpty ? deviceId : 'WLI-${trainNo}-${coachIdStr}',
      ),
      location: WliLocation(
        coachId: coachIdStr,
        coachName: coachNameStr,
      ),
      messageType: 'METRICS',
      timestamp: formattedTimestamp,
      placement: WliPlacement(type: placementType, sensorCount: 1, position: ['CENTER']),
      coachType: json['coach_type']?.toString() ?? '',
      assets: [
        WliAsset(
          assetId: 'WLI-${deviceId}',
          assetName: 'Water Tank Sensor',
          levelCm: levelCm,
          volumeLiters: volumeLiters,
          percentFull: percentFull,
        ),
      ],
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
  final double levelCm;
  final double volumeLiters;
  final double percentFull;

  WliAsset({
    required this.assetId,
    required this.assetName,
    required this.levelCm,
    required this.volumeLiters,
    required this.percentFull,
  });

  factory WliAsset.fromJson(Map<String, dynamic> json) {
    return WliAsset(
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      levelCm: (json['levelCm'] ?? 0.0).toDouble(),
      volumeLiters: (json['volumeLiters'] ?? 0.0).toDouble(),
      percentFull: (json['percentFull'] ?? 0.0).toDouble(),
    );
  }
}
