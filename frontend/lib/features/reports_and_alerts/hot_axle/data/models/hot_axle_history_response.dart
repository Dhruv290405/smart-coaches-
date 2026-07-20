class HotAxleHistoryResponse {
  final bool? success;
  final HotAxleHistoryMeta? meta;
  final List<HotAxleHistoryItem>? data;

  HotAxleHistoryResponse({this.success, this.meta, this.data});

  factory HotAxleHistoryResponse.fromJson(Map<String, dynamic> json) {
    return HotAxleHistoryResponse(
      success: json['success'] as bool?,
      meta: json['meta'] != null
          ? HotAxleHistoryMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HotAxleHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotAxleHistoryMeta {
  final int totalRecords;
  final int currentPage;
  final int totalPages;
  final int limit;

  HotAxleHistoryMeta({
    required this.totalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
  });

  factory HotAxleHistoryMeta.fromJson(Map<String, dynamic> json) {
    int parseIntVal(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return HotAxleHistoryMeta(
      totalRecords: parseIntVal(json['totalRecords']),
      currentPage: parseIntVal(json['currentPage']),
      totalPages: parseIntVal(json['totalPages']),
      limit: parseIntVal(json['limit']),
    );
  }
}

class HotAxleHistoryItem {
  final String? coachNumber;
  final String? coachType;
  final String? owningRly;
  final String? deviceId;
  final String? timestamp;
  final String? alertStatus;
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
  final double batteryVoltage;
  final String batteryStatus;

  HotAxleHistoryItem({
    this.coachNumber,
    this.coachType,
    this.owningRly,
    this.deviceId,
    this.timestamp,
    this.alertStatus,
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
    this.batteryVoltage = 0.0,
    this.batteryStatus = 'Moderate',
  });

  factory HotAxleHistoryItem.fromJson(Map<String, dynamic> json) {
    double parseTemp(dynamic val) {
      if (val == null) return 0.0;
      final d = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0;
      return d < 0 ? 0.0 : d;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final batPct = parseInt(json['battery_percentage']);
    // Derive battery status from percentage or explicit field
    String batStatus = json['battery_status']?.toString() ?? '';
    if (batStatus.isEmpty) {
      if (batPct <= 20) batStatus = 'Low';
      else if (batPct >= 80) batStatus = 'High';
      else batStatus = 'Moderate';
    }

    // Derive battery voltage from explicit field or estimate from percentage (3.0V–4.2V Li-ion range)
    double batVoltage = parseDouble(json['battery_voltage']);
    if (batVoltage <= 0 && batPct > 0) {
      batVoltage = 3.0 + (batPct / 100.0) * 1.2;
      batVoltage = double.parse(batVoltage.toStringAsFixed(2));
    }

    return HotAxleHistoryItem(
      coachNumber: json['coach_number']?.toString(),
      coachType: json['coach_type']?.toString(),
      owningRly: json['owning_rly']?.toString(),
      deviceId: json['device_id']?.toString(),
      timestamp: json['timestamp']?.toString(),
      alertStatus: json['alert_status']?.toString(),
      a11Temp: parseTemp(json['a11_temp']),
      a12Temp: parseTemp(json['a12_temp']),
      a21Temp: parseTemp(json['a21_temp']),
      a22Temp: parseTemp(json['a22_temp']),
      a31Temp: parseTemp(json['a31_temp']),
      a32Temp: parseTemp(json['a32_temp']),
      a41Temp: parseTemp(json['a41_temp']),
      a42Temp: parseTemp(json['a42_temp']),
      batteryPercentage: batPct,
      signalStrength: parseInt(json['signal_strength']),
      batteryVoltage: batVoltage,
      batteryStatus: batStatus,
    );
  }

  double get maxTemp {
    return [a11Temp, a12Temp, a21Temp, a22Temp, a31Temp, a32Temp, a41Temp, a42Temp]
        .reduce((a, b) => a > b ? a : b);
  }

  String get status {
    final raw = alertStatus ?? '';
    if (raw.isNotEmpty) {
      if (raw.toLowerCase() == 'normal') return 'Good';
      return raw;
    }
    return maxTemp > 80 ? 'Critical' : (maxTemp > 60 ? 'Warning' : 'Good');
  }
}
