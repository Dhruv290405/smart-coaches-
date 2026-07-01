class AcpCoachModel {
  final String coachNumber;
  final String status;
  final String updateTime;
  final bool isChainPulled;
  final String sensorId;
  final int todayCount;
  final String lastPull;
  final String reset;
  final String trainSpeed;
  final String location;
  final String rawAssetName;
  final int totalCount;
  final bool isOn;
  final bool isRecent;
  final String trainNo;
  final String deviceId;
  final String? lastTrigger;
  final String statusLabel;
  final String fsdsStatus;
  final String fsdsRecent;

  const AcpCoachModel({
    required this.coachNumber,
    required this.status,
    required this.updateTime,
    this.isChainPulled = false,
    this.sensorId = 'N/A',
    this.lastPull = 'N/A',
    this.reset = 'N/A',
    this.trainSpeed = 'N/A',
    this.location = 'Danapur',
    this.rawAssetName = '',
    this.totalCount = 0,
    this.todayCount = 0,
    this.isOn = true,
    this.isRecent = false,
    this.trainNo = 'N/A',
    this.deviceId = 'N/A',
    this.lastTrigger,
    this.statusLabel = 'Not Pulled',
    this.fsdsStatus = 'OFF',
    this.fsdsRecent = 'NO',
  });
}

class AcpHistoryEntry {
  final String sensorId;
  final String lastPull;
  final String reset;
  final String trainSpeed;
  final String location;
  final DateTime date;
  final int todayCount;
  final String status;
  final int totalCount;
  final String powerCarNo;
  final String rawAssetName;
  final String deviceId;

  const AcpHistoryEntry({
    required this.sensorId,
    required this.lastPull,
    required this.reset,
    required this.trainSpeed,
    required this.location,
    required this.date,
    this.todayCount = 0,
    this.status = '0',
    this.totalCount = 0,
    this.powerCarNo = 'N/A',
    this.rawAssetName = '',
    this.deviceId = 'N/A',
  });
}