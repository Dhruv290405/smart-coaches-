/// Sensor Hygiene — Weighted Odour Index (0 - 1000 scale).
///   Index = 0.3 x (NH3/100 x 1000) + 0.5 x (H2S/100 x 1000) + 0.2 x (VOC/1000 x 1000)
///         = 3 x NH3 + 5 x H2S + 0.2 x VOC
/// Bands: Normal 0-250 | Moderate 250-500 | Warning 500-950 | ALERT > 950.
/// Bad odour alert when Index > 950. Must match backend `src/utils/odourIndex.js`.
class OdourIndex {
  static const double moderate = 250;
  static const double warning = 500;
  static const double alert = 950;

  static double compute({double nh3 = 0, double h2s = 0, double voc = 0}) {
    double p(double v) => v.isFinite && v > 0 ? v : 0;
    final idx = 3 * p(nh3) + 5 * p(h2s) + 0.2 * p(voc);
    return (idx.clamp(0, 1000) * 10).round() / 10;
  }

  /// Band for any value on the 0-1000 scale.
  static String level(double value) {
    if (value > alert) return 'Alert';
    if (value >= warning) return 'Warning';
    if (value >= moderate) return 'Moderate';
    return 'Normal';
  }

  /// NH3 / H2S are rated on the same 0-1000 scale the formula uses
  /// (ppm / 100 x 1000 = ppm x 10); VOC is already 0-1000.
  static String gasLevel(double ppm) => level(ppm * 10);
}

class OdourCoachModel {
  final String coachNumber;
  final String section;
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

  final double? serverOdourIndex;
  final double? serverHygieneScore;
  final String? serverVocStatus;
  final String? serverNh3Status;
  final String? serverH2sStatus;
  final String? serverSmokeStatus;
  final String? serverTempStatus;
  final String? serverHumStatus;

  OdourCoachModel({
    required this.coachNumber,
    this.section = 'Section 1',
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
    this.serverOdourIndex,
    this.serverHygieneScore,
    this.serverVocStatus,
    this.serverNh3Status,
    this.serverH2sStatus,
    this.serverSmokeStatus,
    this.serverTempStatus,
    this.serverHumStatus,
  });

  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'testing';
  /// Weighted Odour Index; prefers the backend value, else computed locally.
  double get odourIndex =>
      serverOdourIndex ?? OdourIndex.compute(nh3: nh3, h2s: h2s, voc: voc);

  /// Normal / Moderate / Warning / Alert (Index bands).
  String get odourStatus => OdourIndex.level(odourIndex);
  double get odourThreshold => OdourIndex.alert;

  /// Same rule the backend uses to send notifications: Index > 950 (ALERT).
  bool get hasAlert => odourIndex > OdourIndex.alert;

  /// Hygiene % derived from the Weighted Odour Index (100 = clean, 0 = worst).
  double get hygieneScore {
    if (serverHygieneScore != null) return serverHygieneScore!;
    return (100 - odourIndex / 10).clamp(0.0, 100.0);
  }

  // Per-sensor status on the same bands as the Index (formula scale).
  String get vocStatus => OdourIndex.level(voc);
  String get nh3Status => OdourIndex.gasLevel(nh3);
  String get h2sStatus => OdourIndex.gasLevel(h2s);

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

  // Full scale of each sensor in the formula (used for gauge fill).
  double get vocThreshold => 1000.0;
  double get nh3Threshold => 100.0;
  double get h2sThreshold => 100.0;
  double get smokeThreshold => 19.9;

  String get locationAddress => address;

  bool get isOnline => true;
  String get communicationStatus => 'Stable';
  String get lastDataReceived => timestamp;
}

class OdourHistoryPoint {
  final String timestamp;
  final double odourIndex;
  final double voc;
  final double nh3;
  final double h2s;
  final double smoke;
  final double temperature;
  final double humidity;

  OdourHistoryPoint({
    required this.timestamp,
    this.odourIndex = 0.0,
    this.voc = 0.0,
    this.nh3 = 0.0,
    this.h2s = 0.0,
    this.smoke = 0.0,
    this.temperature = 0.0,
    this.humidity = 0.0,
  });

  factory OdourHistoryPoint.fromJson(Map<String, dynamic> j) {
    double d(dynamic v, [double def = 0.0]) =>
        v == null ? def : (v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? def));
    final voc = d(j['voc']);
    final nh3 = d(j['nh3']);
    final h2s = d(j['h2s']);
    return OdourHistoryPoint(
      timestamp: j['timestamp']?.toString() ?? '',
      odourIndex: j['odour_index'] != null
          ? d(j['odour_index'])
          : OdourIndex.compute(nh3: nh3, h2s: h2s, voc: voc),
      voc: voc,
      nh3: nh3,
      h2s: h2s,
      smoke: d(j['smoke']),
      temperature: d(j['temperature']),
      humidity: d(j['humidity']),
    );
  }
}

class CoachToiletGroup {
  final String coachNumber;
  final String deviceId;
  final String coachType;
  final String trainNumber;
  final String trainName;
  final String route;
  final List<OdourCoachModel> toilets;

  CoachToiletGroup({
    required this.coachNumber,
    required this.deviceId,
    required this.coachType,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    required this.toilets,
  });

  String get displayName {
    if (coachNumber.isNotEmpty && coachNumber != deviceId && coachNumber != 'Unknown') {
      return '$deviceId ($coachNumber)';
    }
    return deviceId;
  }

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
      final groupKey = m.deviceId.isNotEmpty ? m.deviceId : m.coachNumber;
      map.putIfAbsent(groupKey, () => []).add(m);
    }
    return map.entries.map((e) {
      final first = e.value.first;
      return CoachToiletGroup(
        coachNumber: first.coachNumber,
        deviceId: first.deviceId,
        coachType: first.coachType,
        trainNumber: first.trainNumber,
        trainName: first.trainName,
        route: first.route,
        toilets: e.value,
      );
    }).toList();
  }
}
