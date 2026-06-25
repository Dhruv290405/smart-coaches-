class HotAxleCoachModel {
  final String deviceId;
  final String coachNumber;
  final String coachType;
  final String owningRly;
  final String trainNo;
  final String timestamp;
  final double a11Temp;
  final double a12Temp;
  final double a21Temp;
  final double a22Temp;
  final double a31Temp;
  final double a32Temp;
  final double a41Temp;
  final double a42Temp;
  final int batteryPercentage;
  final int signalStrength;
  final String? apiStatus;

  HotAxleCoachModel({
    required this.deviceId,
    required this.coachNumber,
    required this.coachType,
    required this.owningRly,
    required this.trainNo,
    required this.timestamp,
    required this.a11Temp,
    required this.a12Temp,
    required this.a21Temp,
    required this.a22Temp,
    required this.a31Temp,
    required this.a32Temp,
    required this.a41Temp,
    required this.a42Temp,
    required this.batteryPercentage,
    required this.signalStrength,
    this.apiStatus,
  });

  double get maxTemp {
    return [
      a11Temp, a12Temp, a21Temp, a22Temp,
      a31Temp, a32Temp, a41Temp, a42Temp
    ].reduce((a, b) => a > b ? a : b);
  }

  String get status {
    if (apiStatus != null && apiStatus!.isNotEmpty) return apiStatus!;
    return maxTemp > 80 ? 'Critical' : (maxTemp > 60 ? 'Warning' : 'Good');
  }

  bool get isAlert => maxTemp > 60;

  int get axlesMonitored => 8;
  int get axlesIssue => [
    a11Temp, a12Temp, a21Temp, a22Temp,
    a31Temp, a32Temp, a41Temp, a42Temp
  ].where((t) => t > 60).length;
  String get updateTime => timestamp;

  List<AxleModel> get axles => [
    AxleModel(axleNumber: 1, status: a11Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a11Temp}°C', currentTemp: '${a11Temp}°C', sensorId: 'A11', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 2, status: a12Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a12Temp}°C', currentTemp: '${a12Temp}°C', sensorId: 'A12', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 3, status: a21Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a21Temp}°C', currentTemp: '${a21Temp}°C', sensorId: 'A21', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 4, status: a22Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a22Temp}°C', currentTemp: '${a22Temp}°C', sensorId: 'A22', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 5, status: a31Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a31Temp}°C', currentTemp: '${a31Temp}°C', sensorId: 'A31', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 6, status: a32Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a32Temp}°C', currentTemp: '${a32Temp}°C', sensorId: 'A32', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 7, status: a41Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a41Temp}°C', currentTemp: '${a41Temp}°C', sensorId: 'A41', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
    AxleModel(axleNumber: 8, status: a42Temp > 60 ? 'Warning' : 'Good', maxTemp: '${a42Temp}°C', currentTemp: '${a42Temp}°C', sensorId: 'A42', speed: 'N/A', detectedAt: timestamp, location: 'N/A', lastMaintenance: 'N/A', updateTime: timestamp),
  ];

  factory HotAxleCoachModel.fromJson(Map<String, dynamic> json) {
    return HotAxleCoachModel(
      deviceId: json['device_id'] ?? '',
      coachNumber: json['coach_number'] ?? '',
      coachType: json['coach_type'] ?? '',
      owningRly: json['owning_rly'] ?? '',
      trainNo: json['train_no']?.toString() ?? '',
      timestamp: json['timestamp'] ?? '',
      a11Temp: (json['a11_temp'] ?? 0.0).toDouble(),
      a12Temp: (json['a12_temp'] ?? 0.0).toDouble(),
      a21Temp: (json['a21_temp'] ?? 0.0).toDouble(),
      a22Temp: (json['a22_temp'] ?? 0.0).toDouble(),
      a31Temp: (json['a31_temp'] ?? 0.0).toDouble(),
      a32Temp: (json['a32_temp'] ?? 0.0).toDouble(),
      a41Temp: (json['a41_temp'] ?? 0.0).toDouble(),
      a42Temp: (json['a42_temp'] ?? 0.0).toDouble(),
      batteryPercentage: json['battery_percentage'] ?? 0,
      signalStrength: json['signal_strength'] ?? 0,
    );
  }
}

class AxleModel {
  final int axleNumber;
  final String status;
  final String maxTemp;
  final String currentTemp;
  final String sensorId;
  final String speed;
  final String detectedAt;
  final String location;
  final String lastMaintenance;
  final String updateTime;

  const AxleModel({
    required this.axleNumber,
    required this.status,
    required this.maxTemp,
    required this.currentTemp,
    required this.sensorId,
    required this.speed,
    required this.detectedAt,
    required this.location,
    required this.lastMaintenance,
    required this.updateTime,
  });
}

class AxleHistoryEntry {
  final String coachNumber;
  final int axleNumber;
  final String sensorId;
  final String maxTemp;
  final String status;
  final String speed;
  final String detectedAt;
  final String location;
  final DateTime date;

  const AxleHistoryEntry({
    required this.coachNumber,
    required this.axleNumber,
    required this.sensorId,
    required this.maxTemp,
    required this.status,
    required this.speed,
    required this.detectedAt,
    required this.location,
    required this.date,
  });
}