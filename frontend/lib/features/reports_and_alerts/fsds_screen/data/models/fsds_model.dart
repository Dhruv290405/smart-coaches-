class FsdsAssetModel {
  final String assetId;
  final String assetName;
  final String timestamp;
  final num lightValue;
  final num smokeLevel;
  final String sensorId;
  final String locName;
  final String locId;

  FsdsAssetModel({
    required this.assetId,
    required this.assetName,
    required this.timestamp,
    required this.lightValue,
    required this.smokeLevel,
    required this.sensorId,
    required this.locName,
    required this.locId,
  });

  bool get isSmokeDetected => smokeLevel > 30; // Threshold example
  bool get isRecent {
    try {
      return DateTime.now().difference(DateTime.parse(timestamp)).inMinutes < 60;
    } catch (_) {
      return false;
    }
  }

  factory FsdsAssetModel.fromJson(Map<String, dynamic> json, String sensorId, String locName, String locId) {
    final metrics = json['metrics'] ?? {};
    final timestamp = metrics['timestamp'] ?? '';
    final values = metrics['values'] as List? ?? [];
    
    num light = 0;
    num smoke = 0;

    for (var v in values) {
      if (v['name'].toString().contains('LIGHT')) {
        light = v['value'] ?? 0;
      } else if (v['name'].toString().contains('SMOKE')) {
        smoke = v['value'] ?? 0;
      }
    }

    return FsdsAssetModel(
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      timestamp: timestamp,
      lightValue: light,
      smokeLevel: smoke,
      sensorId: sensorId,
      locName: locName,
      locId: locId,
    );
  }
}
