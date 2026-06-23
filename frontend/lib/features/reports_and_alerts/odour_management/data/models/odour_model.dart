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
  });

  bool get isActive => status.toLowerCase() == 'active';
  
  // High reading might indicate bad odour? Let's assume > 70 is bad.
  bool get hasAlert => reading > 70; 
}
