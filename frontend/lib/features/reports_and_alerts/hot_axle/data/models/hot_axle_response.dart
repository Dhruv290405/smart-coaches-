class HotAxleDashboardResponse {
  final bool? success;
  final int? totalCoaches;
  final List<HotAxleData>? data;

  HotAxleDashboardResponse({this.success, this.totalCoaches, this.data});

  factory HotAxleDashboardResponse.fromJson(Map<String, dynamic> json) {
    return HotAxleDashboardResponse(
      success: json['success'] as bool?,
      totalCoaches: json['totalCoaches'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HotAxleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotAxleResponse {
  final bool? success;
  final int? count;
  final String? deviceId;
  final List<HotAxleData>? data;

  HotAxleResponse({this.success, this.count, this.deviceId, this.data});

  factory HotAxleResponse.fromJson(Map<String, dynamic> json) {
    return HotAxleResponse(
      success: json['success'] as bool?,
      count: json['count'] as int?,
      deviceId: json['deviceId']?.toString(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HotAxleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotAxleData {
  final int? id;
  final int? trainNo;
  final String? techCoachNo;
  final String? axlePosition;
  final String? temperature;
  final String? status;
  final String? createdAt;
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
  final String? timestampDevice;
  final String? deviceId;
  final String? coachNumber;
  final String? coachType;
  final String? owningRly;
  final String? timestamp;
  final String? alertStatus;

  HotAxleData({
    this.id,
    this.trainNo,
    this.techCoachNo,
    this.axlePosition,
    this.temperature,
    this.status,
    this.createdAt,
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
    this.timestampDevice,
    this.deviceId,
    this.coachNumber,
    this.coachType,
    this.owningRly,
    this.timestamp,
    this.alertStatus,
  });

  factory HotAxleData.fromJson(Map<String, dynamic> json) {
    double parseTemp(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return HotAxleData(
      id: json['id'] as int?,
      trainNo: json['train_no'] is int ? json['train_no'] as int : int.tryParse(json['train_no']?.toString() ?? ''),
      techCoachNo: json['tech_coach_no']?.toString(),
      axlePosition: json['axle_position']?.toString(),
      temperature: json['temperature']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      a11Temp: parseTemp(json['a11_temp']),
      a12Temp: parseTemp(json['a12_temp']),
      a21Temp: parseTemp(json['a21_temp']),
      a22Temp: parseTemp(json['a22_temp']),
      a31Temp: parseTemp(json['a31_temp']),
      a32Temp: parseTemp(json['a32_temp']),
      a41Temp: parseTemp(json['a41_temp']),
      a42Temp: parseTemp(json['a42_temp']),
      batteryPercentage: parseInt(json['battery_percentage']),
      signalStrength: parseInt(json['signal_strength']),
      timestampDevice: json['timestamp_device']?.toString(),
      deviceId: json['device_id']?.toString(),
      coachNumber: json['coach_number']?.toString(),
      coachType: json['coach_type']?.toString(),
      owningRly: json['owning_rly']?.toString(),
      timestamp: json['timestamp']?.toString(),
      alertStatus: json['alert_status']?.toString(),
    );
  }
}
