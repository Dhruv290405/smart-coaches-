class OdourCoachModel {
  final String coachNumber;
  final String coachType;
  final String toiletPosition;
  final String status;
  final num reading;
  final String timestamp;
  final String sensorId;
  final String deviceId;
  final String trainNumber;
  final String trainName;
  final String route;
  final bool isRecent;

  final double voc;
  final double h2s;
  final double nh3;
  final double smoke;
  final double temperature;
  final double humidity;
  final String address;
  final String doorStatus;
  final int doorOpenEventsToday;
  final int uCount;
  final int fCount;
  final String lastOpenedTime;
  final String lastClosedTime;
  final int totalDoorCyclesToday;
  final String averageOpenDuration;
  final String longestOpenDuration;
  final List<Map<String, String>> recentDoorEventsTimeline;

  final double? serverHygieneScore;
  final String? serverVocStatus;
  final String? serverNh3Status;
  final String? serverH2sStatus;
  final String? serverSmokeStatus;
  final String? serverTempStatus;
  final String? serverHumStatus;

  OdourCoachModel({
    required this.coachNumber,
    required this.coachType,
    required this.toiletPosition,
    required this.status,
    required this.reading,
    required this.timestamp,
    required this.sensorId,
    required this.deviceId,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    this.isRecent = false,
    this.voc = 0.0,
    this.h2s = 0.0,
    this.nh3 = 0.0,
    this.smoke = 0.0,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.address = 'Unknown',
    this.doorStatus = 'Closed',
    this.doorOpenEventsToday = 0,
    this.uCount = 0,
    this.fCount = 0,
    this.lastOpenedTime = 'N/A',
    this.lastClosedTime = 'N/A',
    this.totalDoorCyclesToday = 0,
    this.averageOpenDuration = 'N/A',
    this.longestOpenDuration = 'N/A',
    this.recentDoorEventsTimeline = const [],
    this.serverHygieneScore,
    this.serverVocStatus,
    this.serverNh3Status,
    this.serverH2sStatus,
    this.serverSmokeStatus,
    this.serverTempStatus,
    this.serverHumStatus,
  });

  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'testing';
  bool get hasAlert => hygieneScore < 50;

  double get hygieneScore {
    if (serverHygieneScore != null) return serverHygieneScore!;
    double score = 100.0;
    if (nh3 > 1.0) score -= 40;
    else if (nh3 > 0.2) score -= 20;

    if (h2s > 0.1) score -= 30;
    else if (h2s > 0.05) score -= 15;

    if (voc > 1000) score -= 20;
    else if (voc > 800) score -= 10;

    if (smoke > 10) score -= 10;
    else if (smoke > 5) score -= 5;

    return score.clamp(0.0, 100.0);
  }

  String get vocStatus {
    if (serverVocStatus != null) return serverVocStatus!;
    return voc < 800 ? 'Good' : (voc <= 1000 ? 'Warning' : 'Critical');
  }

  String get nh3Status {
    if (serverNh3Status != null) return serverNh3Status!;
    return nh3 < 0.2 ? 'Good' : (nh3 <= 1.0 ? 'Warning' : 'Critical');
  }

  String get h2sStatus {
    if (serverH2sStatus != null) return serverH2sStatus!;
    return h2s < 0.05 ? 'Good' : (h2s <= 0.1 ? 'Warning' : 'Critical');
  }

  String get smokeStatus {
    if (serverSmokeStatus != null) return serverSmokeStatus!;
    return smoke <= 9.9 ? 'Good' : (smoke <= 19.9 ? 'Warning' : 'Critical');
  }

  String get tempStatus {
    if (serverTempStatus != null) return serverTempStatus!;
    if (temperature < 20.0) return 'Cold';
    if (temperature > 35.0) return 'Hot';
    return 'Normal';
  }

  String get humidityStatus {
    if (serverHumStatus != null) return serverHumStatus!;
    if (humidity < 30.0) return 'Dry';
    if (humidity > 70.0) return 'Humid';
    return 'Normal';
  }

  double get vocThreshold => 1000.0;
  double get nh3Threshold => 1.0;
  double get h2sThreshold => 0.1;
  double get smokeThreshold => 19.9;

  String get locationAddress => address;

  bool get isOnline => true;
  String get communicationStatus => 'Stable';
  String get lastDataReceived => timestamp;
}

class CoachToiletGroup {
  final String coachNumber;
  final String coachType;
  final String trainNumber;
  final String trainName;
  final String route;
  final List<OdourCoachModel> toilets;

  CoachToiletGroup({
    required this.coachNumber,
    required this.coachType,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    required this.toilets,
  });

  int get totalToilets => toilets.length;
  int get activeToilets => toilets.where((t) => t.isActive).length;
  int get alertToilets => toilets.where((t) => t.hasAlert).length;
  String get worstStatus {
    if (toilets.any((t) => t.hasAlert)) return 'Alert';
    if (toilets.any((t) => !t.isActive)) return 'Inactive';
    return 'Good';
  }

  static List<CoachToiletGroup> groupByCoach(List<OdourCoachModel> models) {
    final map = <String, List<OdourCoachModel>>{};
    for (final m in models) {
      map.putIfAbsent(m.coachNumber, () => []).add(m);
    }
    return map.entries.map((e) {
      final first = e.value.first;
      return CoachToiletGroup(
        coachNumber: e.key,
        coachType: first.coachType,
        trainNumber: first.trainNumber,
        trainName: first.trainName,
        route: first.route,
        toilets: e.value,
      );
    }).toList();
  }
}
