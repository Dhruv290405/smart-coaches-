class BcPressureResponse {
  final bool? success;
  final int? totalDevices;
  final List<BcPressureData>? data;

  BcPressureResponse({this.success, this.totalDevices, this.data});

  factory BcPressureResponse.fromJson(Map<String, dynamic> json) {
    return BcPressureResponse(
      success: json['success'] as bool?,
      totalDevices: json['totalDevices'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BcPressureData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BcPressureData {
  final int? id;
  final String? trainNo;
  final String? techCoachNo;
  final double? bpPressure;
  final double currentPressure;
  final String? createdAt;
  final String? deviceId;
  final String? coachNumber;
  final String? coachType;
  final String? owningRly;
  final String? trainNumber;
  final double chargingTime;
  final double dischargingTime;
  final int batteryPercentage;
  final int signalStrength;
  final String? brakeAppliedTime;
  final String? brakeReleasedTime;
  final double? brakeResponseTime;
  final String? timestamp;

  BcPressureData({
    this.id,
    this.trainNo,
    this.techCoachNo,
    this.bpPressure,
    required this.currentPressure,
    this.createdAt,
    this.deviceId,
    this.coachNumber,
    this.coachType,
    this.owningRly,
    this.trainNumber,
    required this.chargingTime,
    required this.dischargingTime,
    required this.batteryPercentage,
    required this.signalStrength,
    this.brakeAppliedTime,
    this.brakeReleasedTime,
    this.brakeResponseTime,
    this.timestamp,
  });

  factory BcPressureData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return BcPressureData(
      id: json['id'] as int?,
      trainNo: json['train_no']?.toString(),
      techCoachNo: json['tech_coach_no']?.toString(),
      bpPressure: json['bp_pressure'] != null ? parseDouble(json['bp_pressure']) : null,
      currentPressure: parseDouble(json['current_pressure']),
      createdAt: json['created_at']?.toString(),
      deviceId: json['device_id']?.toString(),
      coachNumber: json['coach_number']?.toString(),
      coachType: json['coach_type']?.toString(),
      owningRly: json['owning_rly']?.toString(),
      trainNumber: json['train_number']?.toString(),
      chargingTime: parseDouble(json['charging_time']),
      dischargingTime: parseDouble(json['discharging_time']),
      batteryPercentage: parseInt(json['battery_percentage']),
      signalStrength: parseInt(json['signal_strength']),
      brakeAppliedTime: json['brake_applied_time']?.toString(),
      brakeReleasedTime: json['brake_released_time']?.toString(),
      brakeResponseTime: json['brake_response_time'] != null ? parseDouble(json['brake_response_time']) : null,
      timestamp: json['timestamp']?.toString(),
    );
  }
}
