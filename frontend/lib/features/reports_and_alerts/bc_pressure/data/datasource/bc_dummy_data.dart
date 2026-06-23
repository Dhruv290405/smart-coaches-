import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_model.dart';

class BCDummyData {
  static const String trainName = '12615/6 Grand Trunk Express';
  static const String lastUpdated = '10:46 AM';

  static List<BCPressureModel> generateCoaches() {
    final now = DateTime(2026, 3, 12, 10, 34);
    return List.generate(20, (index) {
      final id = index + 1;
      final status = id == 7 || id == 20 ? 'Critical' : (id == 4 || id == 11 || id == 17 ? 'Warning' : 'Good');
      final pressure = status == 'Critical' ? 0.6 : (status == 'Warning' ? 3.4 : 5.0);
      
      return BCPressureModel(
        deviceId: 'BC_PRESS_DEV_$id',
        coachNumber: 'Coach $id',
        coachType: 'LHB_AC_3TIER',
        owningRly: 'NR',
        trainNumber: '12301',
        readings: [
          BCPressureReading(
            currentPressure: pressure,
            chargingTime: 45.0,
            dischargingTime: 35.0,
            brakeAppliedTime: '10:32:12',
            brakeReleasedTime: status == 'Warning' ? '' : '10:32:18',
            brakeResponseTime: status == 'Warning' ? 18.0 : 6.0,
            batteryPercentage: 88,
            signalStrength: 85,
            timestamp: now.subtract(Duration(minutes: index)).toIso8601String(),
          ),
        ],
      );
    });
  }

  static Map<String, dynamic> getChartData(String coachNumber, String period) {
    final coachId = int.tryParse(coachNumber.replaceAll('Coach ', '')) ?? 1;
    if (period == 'Live' || period == '5 Sec') return _liveData(coachId);
    if (period == '1 min')   return _oneMinData(coachId);
    if (period == '5 mins')  return _fiveMinsData(coachId);
    if (period == '1 hr' || period == '2 hr') return _thirtyMinsData(coachId);
    return _twelveHrData(coachId);
  }

  static Map<String, dynamic> _twelveHrData(int id) {
    final critical = [7, 20].contains(id);
    final spots = critical
        ? [[0.0,4.0],[1.0,3.0],[2.0,2.0],[3.0,1.5],[4.0,1.0],[5.0,0.8],[6.0,0.6],[7.0,0.7],[8.0,0.6],[9.0,0.7]]
        : [[0.0,4.5],[1.0,4.2],[2.0,4.8],[3.0,4.6],[4.0,5.0],[5.0,4.8],[6.0,5.0],[7.0,4.9],[8.0,5.0],[9.0,4.9]];
    final pressures = spots.map((s) => s[1]).toList();
    return {
      'spots': spots,
      'highest': pressures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      'lowest':  pressures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
      'average': (pressures.reduce((a, b) => a + b) / pressures.length).toStringAsFixed(1),
      'brakeCount': critical ? 45 : 124,
      'xLabels': const ['2h','4h','6h','8h','10h','12h'],
    };
  }

  static Map<String, dynamic> _liveData(int id) {
    final critical = [7, 20].contains(id);
    final warning  = [4, 11, 17].contains(id);
    final spots = critical
        ? [[0.0, 3.2], [0.5, 2.8], [1.0, 1.5], [1.5, 0.8], [2.0, 0.6], [2.5, 0.6], [3.0, 0.6], [3.5, 0.7], [4.0, 0.6]]
        : warning
        ? [[0.0, 4.2], [0.5, 4.0], [1.0, 3.8], [1.5, 3.4], [2.0, 3.2], [2.5, 3.4], [3.0, 3.0], [3.5, 3.4], [4.0, 3.4]]
        : [[0.0, 3.2], [0.5, 3.5], [1.0, 5.0], [1.5, 4.8], [2.0, 5.0], [2.5, 4.9], [3.0, 5.0], [3.5, 4.8], [4.0, 5.0]];
    final pressures = spots.map((s) => s[1]).toList();
    return {
      'spots': spots,
      'highest': pressures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      'lowest':  pressures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
      'average': (pressures.reduce((a, b) => a + b) / pressures.length).toStringAsFixed(1),
      'brakeCount': critical ? 0 : (warning ? 14 : 28),
      'xLabels': const ['5 Sec', '10 Sec', '15 Sec', '20 Sec', '25 Sec'],
    };
  }

  static Map<String, dynamic> _oneMinData(int id) {
    final critical = [7, 20].contains(id);
    final spots = critical
        ? [[0.0,3.0],[1.0,2.0],[2.0,1.2],[3.0,0.8],[4.0,0.6],[5.0,0.7],[6.0,0.6],[7.0,0.8],[8.0,0.6],[9.0,0.6],[10.0,0.7],[11.0,0.6]]
        : [[0.0,4.8],[1.0,5.0],[2.0,4.9],[3.0,5.0],[4.0,4.8],[5.0,5.0],[6.0,4.7],[7.0,5.0],[8.0,4.9],[9.0,5.0],[10.0,4.8],[11.0,5.0]];
    final pressures = spots.map((s) => s[1]).toList();
    return {
      'spots': spots,
      'highest': pressures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      'lowest':  pressures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
      'average': (pressures.reduce((a, b) => a + b) / pressures.length).toStringAsFixed(1),
      'brakeCount': critical ? 2 : 12,
      'xLabels': const ['10s','20s','30s','40s','50s','60s'],
    };
  }

  static Map<String, dynamic> _fiveMinsData(int id) {
    final critical = [7, 20].contains(id);
    final spots = critical
        ? [[0.0,3.5],[1.0,2.8],[2.0,1.5],[3.0,0.8],[4.0,0.6],[5.0,1.0],[6.0,0.6],[7.0,0.8],[8.0,0.7],[9.0,0.6]]
        : [[0.0,4.5],[1.0,5.0],[2.0,4.8],[3.0,5.0],[4.0,4.9],[5.0,5.0],[6.0,4.7],[7.0,5.0],[8.0,4.9],[9.0,5.0]];
    final pressures = spots.map((s) => s[1]).toList();
    return {
      'spots': spots,
      'highest': pressures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      'lowest':  pressures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
      'average': (pressures.reduce((a, b) => a + b) / pressures.length).toStringAsFixed(1),
      'brakeCount': critical ? 5 : 22,
      'xLabels': const ['1m','2m','3m','4m','5m'],
    };
  }

  static Map<String, dynamic> _thirtyMinsData(int id) {
    final critical = [7, 20].contains(id);
    final spots = critical
        ? [[0.0,4.0],[1.0,3.5],[2.0,2.5],[3.0,1.5],[4.0,0.8],[5.0,0.6],[6.0,0.8],[7.0,0.6],[8.0,0.7],[9.0,0.6]]
        : [[0.0,4.0],[1.0,4.5],[2.0,5.0],[3.0,4.8],[4.0,5.0],[5.0,4.9],[6.0,5.0],[7.0,4.8],[8.0,5.0],[9.0,4.9]];
    final pressures = spots.map((s) => s[1]).toList();
    return {
      'spots': spots,
      'highest': pressures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
      'lowest':  pressures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
      'average': (pressures.reduce((a, b) => a + b) / pressures.length).toStringAsFixed(1),
      'brakeCount': critical ? 18 : 58,
      'xLabels': const ['5m','10m','15m','20m','25m','30m'],
    };
  }

  static List<BCHistoryEntry> getHistory(String coachNumber, String period, {DateTime? from, DateTime? to}) {
    final now = DateTime(2026, 3, 12);
    final all = _allHistory[coachNumber] ?? _defaultHistory(coachNumber);
    DateTime cutoff;
    if (period == '7 Days') {
      cutoff = now.subtract(const Duration(days: 7));
    } else if (period == '30 Days') cutoff = now.subtract(const Duration(days: 30));
    else if (period == 'Custom' && from != null && to != null) {
      return all.where((e) => !e.date.isBefore(from) && !e.date.isAfter(to.add(const Duration(days: 1)))).toList();
    } else {
      cutoff = now.subtract(const Duration(days: 1));
    }
    return all.where((e) => e.date.isAfter(cutoff)).toList();
  }

  static List<BCHistoryEntry> _defaultHistory(String coachNumber) {
    final id = int.tryParse(coachNumber.replaceAll('Coach ', '')) ?? 1;
    return [
      BCHistoryEntry(coachNumber: coachNumber, sensorId: 'BC-B7-${id.toString().padLeft(2,'0')}', pressure: 5.0, status: 'Good', brakeApplied: '10:32:12', brakeReleased: '10:32:18', brakeResponseTime: '6 sec', location: 'Ratlam', date: DateTime(2026, 3, 12, 10, 32)),
    ];
  }

  static final Map<String, List<BCHistoryEntry>> _allHistory = {
    'Coach 4': [
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 3.4, status: 'Warning',  brakeApplied: '10:32:12', brakeReleased: 'Delayed', brakeResponseTime: '18 sec', location: 'Ratlam',  date: DateTime(2026, 3, 12, 10, 32)),
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 4.2, status: 'Warning',  brakeApplied: '08:14:05', brakeReleased: '08:14:22', brakeResponseTime: '17 sec', location: 'Ujjain',  date: DateTime(2026, 3, 11,  8, 14)),
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 5.0, status: 'Good',     brakeApplied: '11:05:30', brakeReleased: '11:05:37', brakeResponseTime: '7 sec',  location: 'Bhopal',  date: DateTime(2026, 3, 10, 11,  5)),
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 3.8, status: 'Warning',  brakeApplied: '09:22:00', brakeReleased: 'Delayed', brakeResponseTime: '20 sec', location: 'Itarsi',  date: DateTime(2026, 3,  8,  9, 22)),
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 5.0, status: 'Good',     brakeApplied: '07:48:10', brakeReleased: '07:48:16', brakeResponseTime: '6 sec',  location: 'Nagpur',  date: DateTime(2026, 3,  5,  7, 48)),
      BCHistoryEntry(coachNumber: 'Coach 4', sensorId: 'BC-B7-04', pressure: 5.0, status: 'Good',     brakeApplied: '14:30:00', brakeReleased: '14:30:08', brakeResponseTime: '8 sec',  location: 'Agra',    date: DateTime(2026, 2, 20, 14, 30)),
    ],
    'Coach 7': [
      BCHistoryEntry(coachNumber: 'Coach 7', sensorId: 'BC-B7-07', pressure: 0.6, status: 'Critical', brakeApplied: 'N/A',      brakeReleased: 'N/A',     brakeResponseTime: 'N/A',    location: 'Ratlam',  date: DateTime(2026, 3, 12, 10, 42)),
      BCHistoryEntry(coachNumber: 'Coach 7', sensorId: 'BC-B7-07', pressure: 1.2, status: 'Critical', brakeApplied: 'N/A',      brakeReleased: 'N/A',     brakeResponseTime: 'N/A',    location: 'Ujjain',  date: DateTime(2026, 3, 11,  9, 10)),
      BCHistoryEntry(coachNumber: 'Coach 7', sensorId: 'BC-B7-07', pressure: 3.0, status: 'Warning',  brakeApplied: '06:55:22', brakeReleased: 'Delayed', brakeResponseTime: '22 sec', location: 'Gwalior', date: DateTime(2026, 3,  9, 16,  0)),
      BCHistoryEntry(coachNumber: 'Coach 7', sensorId: 'BC-B7-07', pressure: 5.0, status: 'Good',     brakeApplied: '09:30:00', brakeReleased: '09:30:06', brakeResponseTime: '6 sec',  location: 'Noida',   date: DateTime(2026, 3,  1,  9, 30)),
      BCHistoryEntry(coachNumber: 'Coach 7', sensorId: 'BC-B7-07', pressure: 4.8, status: 'Good',     brakeApplied: '07:45:00', brakeReleased: '07:45:07', brakeResponseTime: '7 sec',  location: 'Delhi',   date: DateTime(2026, 2, 15,  7, 45)),
    ],
    'Coach 11': [
      BCHistoryEntry(coachNumber: 'Coach 11', sensorId: 'BC-B7-11', pressure: 3.4, status: 'Warning', brakeApplied: '10:32:12', brakeReleased: 'Delayed',  brakeResponseTime: '16 sec', location: 'Ratlam',  date: DateTime(2026, 3, 12, 10, 32)),
      BCHistoryEntry(coachNumber: 'Coach 11', sensorId: 'BC-B7-11', pressure: 3.8, status: 'Warning', brakeApplied: '13:15:00', brakeReleased: 'Delayed',  brakeResponseTime: '19 sec', location: 'Mathura', date: DateTime(2026, 3, 11, 13, 15)),
      BCHistoryEntry(coachNumber: 'Coach 11', sensorId: 'BC-B7-11', pressure: 5.0, status: 'Good',    brakeApplied: '11:00:00', brakeReleased: '11:00:07', brakeResponseTime: '7 sec',  location: 'Agra',    date: DateTime(2026, 3,  6, 11,  0)),
      BCHistoryEntry(coachNumber: 'Coach 11', sensorId: 'BC-B7-11', pressure: 4.9, status: 'Good',    brakeApplied: '08:30:00', brakeReleased: '08:30:07', brakeResponseTime: '7 sec',  location: 'Bhopal',  date: DateTime(2026, 2, 25,  8, 30)),
    ],
    'Coach 17': [
      BCHistoryEntry(coachNumber: 'Coach 17', sensorId: 'BC-B7-17', pressure: 2.8, status: 'Warning', brakeApplied: '10:32:12', brakeReleased: 'Delayed',  brakeResponseTime: '21 sec', location: 'Ratlam',  date: DateTime(2026, 3, 12, 10, 32)),
      BCHistoryEntry(coachNumber: 'Coach 17', sensorId: 'BC-B7-17', pressure: 4.0, status: 'Warning', brakeApplied: '07:20:00', brakeReleased: 'Delayed',  brakeResponseTime: '15 sec', location: 'Ujjain',  date: DateTime(2026, 3, 10,  7, 20)),
      BCHistoryEntry(coachNumber: 'Coach 17', sensorId: 'BC-B7-17', pressure: 5.0, status: 'Good',    brakeApplied: '09:00:00', brakeReleased: '09:00:08', brakeResponseTime: '8 sec',  location: 'Itarsi',  date: DateTime(2026, 3,  5,  9,  0)),
    ],
    'Coach 20': [
      BCHistoryEntry(coachNumber: 'Coach 20', sensorId: 'BC-B7-20', pressure: 0.6, status: 'Critical', brakeApplied: 'N/A',     brakeReleased: 'N/A',     brakeResponseTime: 'N/A',    location: 'Ratlam',  date: DateTime(2026, 3, 12, 10, 42)),
      BCHistoryEntry(coachNumber: 'Coach 20', sensorId: 'BC-B7-20', pressure: 0.8, status: 'Critical', brakeApplied: 'N/A',     brakeReleased: 'N/A',     brakeResponseTime: 'N/A',    location: 'Ujjain',  date: DateTime(2026, 3, 11,  8, 55)),
      BCHistoryEntry(coachNumber: 'Coach 20', sensorId: 'BC-B7-20', pressure: 2.5, status: 'Warning',  brakeApplied: '14:44:00',brakeReleased: 'Delayed',  brakeResponseTime: '24 sec', location: 'Nagpur',  date: DateTime(2026, 3,  7, 14, 44)),
      BCHistoryEntry(coachNumber: 'Coach 20', sensorId: 'BC-B7-20', pressure: 5.0, status: 'Good',     brakeApplied: '10:00:00',brakeReleased: '10:00:06', brakeResponseTime: '6 sec',  location: 'Noida',   date: DateTime(2026, 2, 28, 10,  0)),
    ],
  };

  static const List<Map<String, dynamic>> alerts = [
    {
      'type': 'critical',
      'title': 'Critical: BC Pressure Failure',
      'coach': 'Coach 7',
      'time': 'Today, 10:42 AM',
      'detail': 'Pressure: 0.6 Kg/cm²  |  Threshold: 3.5 Kg/cm²',
      'note': 'Brake failure risk — Immediate inspection required',
    },
    {
      'type': 'critical',
      'title': 'Critical: BC Pressure Failure',
      'coach': 'Coach 20',
      'time': 'Today, 10:42 AM',
      'detail': 'Pressure: 0.6 Kg/cm²  |  Threshold: 3.5 Kg/cm²',
      'note': 'Brake failure risk — Immediate inspection required',
    },
    {
      'type': 'warning',
      'title': 'Warning: Brake Release Delay',
      'coach': 'Coach 4',
      'time': 'Today, 10:34 AM',
      'detail': 'Pressure: 3.4 Kg/cm²  |  Response: 18 sec',
      'note': 'Release delay detected — Monitor closely',
    },
    {
      'type': 'warning',
      'title': 'Warning: Brake Release Delay',
      'coach': 'Coach 11',
      'time': 'Today, 10:34 AM',
      'detail': 'Pressure: 3.4 Kg/cm²  |  Response: 16 sec',
      'note': 'Release delay detected — Monitor closely',
    },
    {
      'type': 'warning',
      'title': 'Warning: Pressure Below Threshold',
      'coach': 'Coach 17',
      'time': 'Today, 10:34 AM',
      'detail': 'Pressure: 2.8 Kg/cm²  |  Threshold: 3.5 Kg/cm²',
      'note': 'Pressure below safe limit',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Brake Delay',
      'coach': 'Coach 3',
      'time': 'Yesterday, 06:10 AM',
      'detail': 'Resolved by: Ramesh Kumar',
      'note': 'Brakes restored to normal operation',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Low BC Pressure',
      'coach': 'Coach 9',
      'time': '10 Mar, 02:15 PM',
      'detail': 'Resolved by: Suresh Singh',
      'note': 'Pressure refilled and sensor recalibrated',
    },
  ];

  static Map<String, int> getSummary(String period) {
    if (period == '30 Days') return {'total': 20, 'good': 13, 'warning': 5, 'critical': 2};
    if (period == '7 Days')  return {'total': 20, 'good': 15, 'warning': 3, 'critical': 2};
    return {'total': 20, 'good': 15, 'warning': 3, 'critical': 2}; // Live
  }
}