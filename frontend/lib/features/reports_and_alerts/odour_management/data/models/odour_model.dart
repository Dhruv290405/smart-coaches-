class ToiletSensor {
  final String id;
  final String position;
  final num reading;
  final String status;
  final bool isRecent;

  ToiletSensor({
    required this.id,
    required this.position,
    required this.reading,
    required this.status,
    this.isRecent = false,
  });

  bool get isBad => reading > 70;
  String get levelLabel => reading > 70 ? 'High' : (reading > 40 ? 'Moderate' : 'Low');

  factory ToiletSensor.fromJson(Map<String, dynamic> json) {
    return ToiletSensor(
      id: json['id'] ?? '',
      position: json['position'] ?? '',
      reading: json['reading'] ?? 0,
      status: json['status'] ?? 'Active',
      isRecent: json['isRecent'] ?? false,
    );
  }
}

class OdourCoachModel {
  final String coachNumber;
  final String coachType;
  final String trainNumber;
  final String trainName;
  final String route;
  final String deviceId;
  final List<ToiletSensor> toilets;

  OdourCoachModel({
    required this.coachNumber,
    required this.coachType,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    required this.deviceId,
    required this.toilets,
  });

  bool get hasActiveAlert => toilets.any((t) => t.isBad);
  int get alertCount => toilets.where((t) => t.isBad).length;
  num get averageReading => toilets.isEmpty ? 0 : toilets.map((t) => t.reading).reduce((a, b) => a + b) / toilets.length;

  factory OdourCoachModel.fromJson(Map<String, dynamic> json) {
    return OdourCoachModel(
      coachNumber: json['coachNumber'] ?? '',
      coachType: json['coachType'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      trainName: json['trainName'] ?? '',
      route: json['route'] ?? '',
      deviceId: json['deviceId'] ?? '',
      toilets: (json['toilets'] as List? ?? []).map((e) => ToiletSensor.fromJson(e)).toList(),
    );
  }
}
