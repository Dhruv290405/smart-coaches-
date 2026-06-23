class SensorData {
  final int id;
  final String sensorId;
  final double waterLevel;
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.sensorId,
    required this.waterLevel,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sensorId: json['sensor_id']?.toString() ?? '',
      waterLevel: (json['water_level'] is double)
          ? (json['water_level'] as num).toDouble()
          : double.tryParse(json['water_level']?.toString() ?? '') ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
