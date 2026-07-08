class FsdsBypassModel {
  final int id;
  final String assetId;
  final String assetName;
  final String timestamp;
  final bool isBypassed;
  final String sensorId;
  final String locName;
  final String locId;
  final String trainNo;
  final String coachNo;
  final String deviceId;
  final int fireStatus;
<<<<<<< HEAD
  final int methaneLevel;
=======
  final int smokeLevel;
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)

  FsdsBypassModel({
    this.id = 0,
    required this.assetId,
    required this.assetName,
    required this.timestamp,
    required this.isBypassed,
    this.sensorId = '',
    this.locName = '',
    this.locId = '',
    this.trainNo = '',
    this.coachNo = '',
    this.deviceId = '',
    this.fireStatus = 0,
<<<<<<< HEAD
    this.methaneLevel = 0,
=======
    this.smokeLevel = 0,
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
  });

  bool get isRecent {
    try {
      return DateTime.now().difference(DateTime.parse(timestamp)).inMinutes < 60;
    } catch (_) {
      return false;
    }
  }

  String get statusText => isBypassed ? 'Bypassed' : 'Normal';
  String get statusCode => isBypassed ? '1' : '0';

  factory FsdsBypassModel.fromJson(Map<String, dynamic> json) {
    final ts = _normalizeTimestamp(json['timestamp'] ?? '');

    final fStatus = _parseInt(json['fire_status']);
<<<<<<< HEAD
    final sLevel = _parseInt(json['methane_level']);
=======
    final sLevel = _parseInt(json['smoke_level']);
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)

    return FsdsBypassModel(
      id: _parseInt(json['id']),
      assetId: (json['asset_id'] ?? json['assetId'] ?? '').toString(),
      assetName: (json['asset_name'] ?? json['assetName'] ?? '').toString(),
      timestamp: ts,
      isBypassed: fStatus == 1,
      sensorId: (json['sensorId'] ?? '').toString(),
      locName: (json['loc_name'] ?? json['locName'] ?? '').toString(),
      locId: (json['loc_id'] ?? json['locId'] ?? '').toString(),
      trainNo: (json['train_no'] ?? json['trainNo'] ?? '').toString(),
      coachNo: (json['asset_name'] ?? json['coachNo'] ?? '').toString(),
      deviceId: (json['device_id'] ?? json['deviceId'] ?? '').toString(),
      fireStatus: fStatus,
<<<<<<< HEAD
      methaneLevel: sLevel,
=======
      smokeLevel: sLevel,
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _normalizeTimestamp(String ts) {
    if (ts.isEmpty) return DateTime.now().toIso8601String();
    if (ts.contains('T')) return ts;
    return ts.replaceFirst(' ', 'T');
  }
}
