class BCPressureModel {
  final String deviceId;
  final String coachNumber;
  final String coachType;
  final String owningRly;
  final String trainNumber;
  final List<BCPressureReading> readings;

  BCPressureModel({
    required this.deviceId,
    required this.coachNumber,
    required this.coachType,
    required this.owningRly,
    required this.trainNumber,
    required this.readings,
  });

  BCPressureReading? get latestReading => readings.isNotEmpty ? readings.first : null;

  String get status {
    final pressure = latestReading?.currentPressure ?? 0.0;
    if (pressure > 5.2 || pressure < 4.5) return 'Critical';
    if (pressure > 5.1 || pressure < 4.7) return 'Warning';
    return 'Good';
  }

  // Fields for compatibility with reports and cards
  double get pressure => latestReading?.currentPressure ?? 0.0;
  String get brakeApplied => latestReading?.brakeAppliedTime ?? '';
  String get brakeReleased => latestReading?.brakeReleasedTime ?? '';
  String? get warningMessage => status != 'Good' ? 'Pressure threshold exceeded' : null;
  DateTime get lastUpdated => DateTime.tryParse(latestReading?.timestamp ?? '')?.toUtc() ?? DateTime.now().toUtc();

  String getFormattedLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    if (difference.inMinutes < 1) return 'Updated just now';
    if (difference.inMinutes < 60) return 'Updated ${difference.inMinutes}m ago';
    if (difference.inHours < 24) return 'Updated ${difference.inHours}hr ago';
    return 'Updated ${difference.inDays}d ago';
  }

  factory BCPressureModel.fromJson(Map<String, dynamic> json) {
    var readingsList = (json['readings'] as List? ?? [])
        .map((e) => BCPressureReading.fromJson(e))
        .toList();
    
    return BCPressureModel(
      deviceId: json['device_id'] ?? '',
      coachNumber: json['coach_number'] ?? '',
      coachType: json['coach_type'] ?? '',
      owningRly: json['owning_rly'] ?? '',
      trainNumber: json['train_number'] ?? '',
      readings: readingsList,
    );
  }
}

class BCPressureReading {
  final double currentPressure;
  final double chargingTime;
  final double dischargingTime;
  final String brakeAppliedTime;
  final String brakeReleasedTime;
  final double brakeResponseTime;
  final int batteryPercentage;
  final int signalStrength;
  final String timestamp;

  BCPressureReading({
    required this.currentPressure,
    required this.chargingTime,
    required this.dischargingTime,
    required this.brakeAppliedTime,
    required this.brakeReleasedTime,
    required this.brakeResponseTime,
    required this.batteryPercentage,
    required this.signalStrength,
    required this.timestamp,
  });

  factory BCPressureReading.fromJson(Map<String, dynamic> json) {
    return BCPressureReading(
      currentPressure: (json['current_pressure'] ?? 0.0).toDouble(),
      chargingTime: (json['charging_time'] ?? 0.0).toDouble(),
      dischargingTime: (json['discharging_time'] ?? 0.0).toDouble(),
      brakeAppliedTime: json['brake_applied_time'] ?? '',
      brakeReleasedTime: json['brake_released_time'] ?? '',
      brakeResponseTime: (json['brake_response_time'] ?? 0.0).toDouble(),
      batteryPercentage: json['battery_percentage'] ?? 0,
      signalStrength: json['signal_strength'] ?? 0,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class BCHistoryEntry {
  final String coachNumber;
  final String sensorId;
  final double pressure;
  final String status;
  final String brakeApplied;
  final String brakeReleased;
  final String brakeResponseTime;
  final String location;
  final DateTime date;

  const BCHistoryEntry({
    required this.coachNumber,
    required this.sensorId,
    required this.pressure,
    required this.status,
    required this.brakeApplied,
    required this.brakeReleased,
    required this.brakeResponseTime,
    required this.location,
    required this.date,
  });
}