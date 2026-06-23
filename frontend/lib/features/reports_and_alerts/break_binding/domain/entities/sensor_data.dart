class SensorData {
  final int trainId;
  final int coachId;
  final String sensorId;
  final double value;
  final DateTime timestamp;

  SensorData({
    required this.trainId,
    required this.coachId,
    required this.sensorId,
    required this.value,
    required this.timestamp,
  });
}
