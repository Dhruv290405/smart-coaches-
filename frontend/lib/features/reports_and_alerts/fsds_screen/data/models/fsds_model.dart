class FsdsBypassModel {
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

  FsdsBypassModel({
    required this.assetId,
    required this.assetName,
    required this.timestamp,
    required this.isBypassed,
    required this.sensorId,
    required this.locName,
    required this.locId,
    this.trainNo = '',
    this.coachNo = '',
    this.deviceId = '',
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
    final metrics = json['metrics'] ?? {};
    final timestamp = metrics['timestamp'] ?? json['timestamp'] ?? '';
    final values = metrics['values'] as List? ?? [];
    
    bool bypassed = false;
    for (var v in values) {
      if (v['value'] == 1 || v['value'] == true) {
        bypassed = true;
        break;
      }
    }

    return FsdsBypassModel(
      assetId: json['assetId'] ?? '',
      assetName: json['assetName'] ?? '',
      timestamp: timestamp,
      isBypassed: bypassed,
      sensorId: json['sensorId'] ?? '',
      locName: json['locName'] ?? json['loc_name'] ?? '',
      locId: json['locId'] ?? json['loc_id'] ?? '',
      trainNo: json['trainNo'] ?? json['train_no'] ?? '',
      coachNo: json['coachNo'] ?? json['coach_no'] ?? '',
      deviceId: json['deviceId'] ?? json['device_id'] ?? '',
    );
  }
}
