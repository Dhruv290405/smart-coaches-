class WaterTankModel {
  final WliSource source;
  final WliLocation location;
  final String messageType;
  final String timestamp;
  final WliPlacement placement;
  final List<WliAsset> assets;
  final String coachType;
  final String trainNo;

  WaterTankModel({
    required this.source,
    required this.location,
    required this.messageType,
    required this.timestamp,
    required this.placement,
    required this.assets,
    this.coachType = '',
    this.trainNo = '',
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
    final rawPercent = (json['percent_full'] is double)
        ? json['percent_full'] as double
        : double.tryParse(json['percent_full']?.toString() ?? '') ?? 0.0;
    final percentFull = rawPercent <= 1.0 ? rawPercent * 100 : rawPercent;
    final rawTimestamp = json['timestamp']?.toString() ?? '';
    final placementType = json['placement_type']?.toString() ?? 'UNDERSLUNG';
    final trainNo = json['train_no']?.toString() ?? '';
    final coachIdRaw = json['coach_id'];

    final String coachIdStr;
    if (coachIdRaw is int) {
      coachIdStr = coachIdRaw.toString();
    } else {
      coachIdStr = coachIdRaw?.toString() ?? '';
    }

    // Format timestamp from MySQL format (YYYY-MM-DD HH:MM:SS) or ISO
    String formattedTimestamp = rawTimestamp;
    try {
      final rawTs = rawTimestamp.contains('T')
          ? rawTimestamp
          : rawTimestamp.replaceFirst(' ', 'T');
      final parsed = DateTime.parse(rawTs).toLocal();
      formattedTimestamp = parsed.toIso8601String();
    } catch (_) {
    }

    final coachNameStr = trainNo.isNotEmpty ? '${trainNo}_$coachName' : coachName;

    return WaterTankModel(
      source: WliSource(
        companyName: 'VASP Rails Tech',
        systemType: 'WLI',
        deviceId: deviceId.isNotEmpty ? deviceId : 'WLI-$trainNo-$coachIdStr',
      ),
      location: WliLocation(
        coachId: coachIdStr,
        coachName: coachNameStr,
      ),
      messageType: 'METRICS',
      timestamp: formattedTimestamp,
      placement: WliPlacement(type: placementType, sensorCount: 1, position: ['CENTER']),
      coachType: json['coach_type']?.toString() ?? '',
      trainNo: trainNo,
      assets: [
        WliAsset(
          assetId: 'WLI-$deviceId',
          assetName: 'Water Tank Sensor',
          levelCm: 0.0,
          volumeLiters: 0.0,
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
