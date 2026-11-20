/// BODR – Bad Odour Detection System (spec: "Bad Odour mathematic logic").
///
/// Combined Odour Index = [(NH3/10 + CH4/15 + H2S/5) / 3] x 100  (2 dp)
///   >= 250 CRITICAL (alert) | 90-<250 MEDIUM | < 90 Normal
/// Overall Hygiene Score % = 100 - index / 4 (index 400+ = 0 %), so the alert
/// fires at Hygiene Score 37.5 % or below.
/// Individual gas limits (NH3 > 10, CH4 > 15, H2S > 5 ppm) are shown as
/// "gas over limit" only; they do not raise alerts on their own.
/// VOC index is the original sensor value; VOC > 90 = MEDIUM (bad odour
/// generation), it is not part of the combined index.
/// Must match backend `src/utils/odourIndex.js`.
class OdourIndex {
  static const double nh3Limit = 10;
  static const double ch4Limit = 15;
  static const double h2sLimit = 5;
  static const double vocLimit = 90;

  static const double medium = 90;
  static const double critical = 250;
  static const double high = critical; // HIGH band merged into CRITICAL

  static double compute({double nh3 = 0, double ch4 = 0, double h2s = 0}) {
    double p(double v) => v.isFinite && v > 0 ? v : 0;
    final idx = ((p(nh3) / nh3Limit + p(ch4) / ch4Limit + p(h2s) / h2sLimit) / 3) * 100;
    return (idx * 100).round() / 100;
  }

  /// Combined-index level.
  static String level(double index) {
    if (index >= critical) return 'Critical';
    if (index >= medium) return 'Medium';
    return 'Normal';
  }

  /// Individual gas: CRITICAL only when strictly above its configured limit.
  static String gasLevel(double ppm, double limit) => ppm > limit ? 'Critical' : 'Normal';
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
  final double methane;
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
    this.methane = 0.0,
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
  /// Combined Odour Index; prefers the backend value, else computed locally.
  double get odourIndex =>
      serverOdourIndex ?? OdourIndex.compute(nh3: nh3, ch4: methane, h2s: h2s);

  /// Level of the combined index alone: Normal / Medium / High / Critical.
  String get indexLevel => OdourIndex.level(odourIndex);

  /// Gases above their configured limit (each is an individual CRITICAL alert).
  List<String> get gasAlerts => [
        if (nh3 > OdourIndex.nh3Limit) 'NH3',
        if (methane > OdourIndex.ch4Limit) 'CH4',
        if (h2s > OdourIndex.h2sLimit) 'H2S',
      ];

  /// Overall status = combined index level (Normal / Medium / Critical).
  String get odourStatus => indexLevel;
  double get odourThreshold => OdourIndex.critical;

  /// Same rule the backend uses to send notifications: index >= 250,
  /// i.e. Overall Hygiene Score 37.5 % or below.
  bool get hasAlert => odourStatus == 'Critical';

  /// Overall Hygiene Score % from the combined odour index, linear:
  /// index 0 -> 100 %, index 400 or more -> 0 %  (score = 100 - index / 4).
  double get hygieneScore {
    if (serverHygieneScore != null) return serverHygieneScore!;
    return (100 - odourIndex / 4).clamp(0.0, 100.0);
  }

  // Per-sensor status (BODR spec).
  String get vocStatus => voc > OdourIndex.vocLimit ? 'Medium' : 'Normal';
  String get nh3Status => OdourIndex.gasLevel(nh3, OdourIndex.nh3Limit);
  String get h2sStatus => OdourIndex.gasLevel(h2s, OdourIndex.h2sLimit);
  String get methaneStatus => OdourIndex.gasLevel(methane, OdourIndex.ch4Limit);

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

  // Gauge full-scale = 2 x the alert limit, so the limit sits at half-way.
  double get vocThreshold => 500.0;
  double get nh3Threshold => OdourIndex.nh3Limit * 2;
  double get methaneThreshold => OdourIndex.ch4Limit * 2;
  double get h2sThreshold => OdourIndex.h2sLimit * 2;
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
  final double methane;
  final double smoke;
  final double temperature;
  final double humidity;

  OdourHistoryPoint({
    required this.timestamp,
    this.odourIndex = 0.0,
    this.voc = 0.0,
    this.nh3 = 0.0,
    this.h2s = 0.0,
    this.methane = 0.0,
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
    final methane = d(j['methane'] ?? j['methane_ppm']);
    return OdourHistoryPoint(
      timestamp: j['timestamp']?.toString() ?? '',
      odourIndex: j['odour_index'] != null
          ? d(j['odour_index'])
          : OdourIndex.compute(nh3: nh3, ch4: methane, h2s: h2s),
      voc: voc,
      nh3: nh3,
      h2s: h2s,
      methane: methane,
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
