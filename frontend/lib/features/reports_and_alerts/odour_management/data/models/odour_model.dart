class ToiletSensor {
  final String id;
  final String position;
<<<<<<< HEAD
  final num vocIndex;
  final num methanePpm;
  final num h2sPpm;
  final num nh3Ppm;
  final num srawVoc;
  final num h2sRaw;
  final num nh3Raw;
  final num temperature;
  final num humidity;
  final int longLockCount;
=======
  final num reading;
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
  final String status;
  final bool isRecent;

  ToiletSensor({
    required this.id,
    required this.position,
<<<<<<< HEAD
    required this.vocIndex,
    this.methanePpm = 0,
    this.h2sPpm = 0,
    this.nh3Ppm = 0,
    this.srawVoc = 0,
    this.h2sRaw = 0,
    this.nh3Raw = 0,
    this.temperature = 0,
    this.humidity = 0,
    this.longLockCount = 0,
=======
    required this.reading,
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
    required this.status,
    this.isRecent = false,
  });

<<<<<<< HEAD
  num get reading => vocIndex;
  bool get isBad => vocIndex > 70 || h2sPpm > 10 || nh3Ppm > 25;
  String get levelLabel {
    if (vocIndex > 70 || h2sPpm > 10 || nh3Ppm > 25) return 'High';
    if (vocIndex > 40 || h2sPpm > 5 || nh3Ppm > 15) return 'Moderate';
    return 'Low';
  }

  factory ToiletSensor.fromJson(Map<String, dynamic> json) {
    return ToiletSensor(
      id: json['id']?.toString() ?? '',
      position: json['toilet_position']?.toString() ?? '',
      vocIndex: (json['voc_index'] ?? 0).toDouble(),
      methanePpm: (json['methane_ppm'] ?? 0).toDouble(),
      h2sPpm: (json['h2s_ppm'] ?? 0).toDouble(),
      nh3Ppm: (json['nh3_ppm'] ?? 0).toDouble(),
      srawVoc: (json['sraw_voc'] ?? 0).toDouble(),
      h2sRaw: (json['h2s_raw'] ?? 0).toDouble(),
      nh3Raw: (json['nh3_raw'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      longLockCount: json['long_lock_count'] ?? 0,
      status: json['status']?.toString() ?? 'Active',
      isRecent: false,
=======
  bool get isBad => reading > 70;
  String get levelLabel => reading > 70 ? 'High' : (reading > 40 ? 'Moderate' : 'Low');

  factory ToiletSensor.fromJson(Map<String, dynamic> json) {
    return ToiletSensor(
      id: json['id'] ?? '',
      position: json['position'] ?? '',
      reading: json['reading'] ?? 0,
      status: json['status'] ?? 'Active',
      isRecent: json['isRecent'] ?? false,
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
    );
  }
}

class OdourCoachModel {
  final String coachNumber;
  final String coachType;
  final String trainNumber;
<<<<<<< HEAD
=======
  final String trainName;
  final String route;
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
  final String deviceId;
  final List<ToiletSensor> toilets;

  OdourCoachModel({
    required this.coachNumber,
    required this.coachType,
    required this.trainNumber,
<<<<<<< HEAD
=======
    required this.trainName,
    required this.route,
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
    required this.deviceId,
    required this.toilets,
  });

  bool get hasActiveAlert => toilets.any((t) => t.isBad);
  int get alertCount => toilets.where((t) => t.isBad).length;
  num get averageReading => toilets.isEmpty ? 0 : toilets.map((t) => t.reading).reduce((a, b) => a + b) / toilets.length;

  factory OdourCoachModel.fromJson(Map<String, dynamic> json) {
    return OdourCoachModel(
<<<<<<< HEAD
      coachNumber: json['coach_number']?.toString() ?? '',
      coachType: json['coach_type']?.toString() ?? '',
      trainNumber: json['train_number']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      toilets: json['toilets'] != null
          ? (json['toilets'] as List).map((e) => ToiletSensor.fromJson(e)).toList()
          : [ToiletSensor.fromJson(json)],
=======
      coachNumber: json['coachNumber'] ?? '',
      coachType: json['coachType'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      trainName: json['trainName'] ?? '',
      route: json['route'] ?? '',
      deviceId: json['deviceId'] ?? '',
      toilets: (json['toilets'] as List? ?? []).map((e) => ToiletSensor.fromJson(e)).toList(),
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
    );
  }
}
