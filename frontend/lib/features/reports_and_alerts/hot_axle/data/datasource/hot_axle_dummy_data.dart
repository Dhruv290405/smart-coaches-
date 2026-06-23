import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class HotAxleDummyData {
  static const String trainName = '12615/6 Grand Trunk Express';
  static const String lastUpdated = '10:46 AM';

  static List<HotAxleCoachModel> generateCoaches() {
    return List.generate(20, (index) {
      final id = index + 1;
      return _buildCoach(id);
    });
  }

  static HotAxleCoachModel _buildCoach(int id) {
    double baseTemp = 40.0 + (id % 10);
    double a11 = baseTemp, a12 = baseTemp, a21 = baseTemp, a22 = baseTemp;
    double a31 = baseTemp, a32 = baseTemp, a41 = baseTemp, a42 = baseTemp;

    if (id == 4)  { a21 = 82.5; }
    if (id == 11) { a31 = 75.0; }
    if (id == 7)  { a11 = 92.0; a32 = 88.5; }
    if (id == 20) { a22 = 85.0; a41 = 90.2; a42 = 87.8; }

    return HotAxleCoachModel(
      deviceId: "HA_DEV_${100670 + id}",
      coachNumber: "1006${70 + id}",
      coachType: id % 2 == 0 ? "LHB_AC_2TIER" : "LHB_AC_3TIER",
      owningRly: "SEC",
      timestamp: "2026-04-21T22:15:00.000Z",
      a11Temp: a11, a12Temp: a12, a21Temp: a21, a22Temp: a22,
      a31Temp: a31, a32Temp: a32, a41Temp: a41, a42Temp: a42,
      batteryPercentage: 85 + (id % 15),
      signalStrength: -60 - (id % 10),
    );
  }

  static List<AxleModel> _buildAxles(int coachId, String coachStatus) {
    return List.generate(8, (i) {
      final axleNum = i + 1;
      return AxleModel(
        axleNumber: axleNum,
        status: 'Good',
        maxTemp: '45°C',
        currentTemp: '45°C',
        sensorId: 'AX-C$coachId-A$axleNum',
        speed: '72 km/h',
        detectedAt: 'Today',
        location: 'Ratlam',
        lastMaintenance: 'Jan 2026',
        updateTime: 'now',
      );
    });
  }

  static List<AxleHistoryEntry> getHistory(String coachNumber, String period, {DateTime? from, DateTime? to}) {
    final now = DateTime(2026, 3, 12);
    final all = _allHistory[coachNumber] ?? [];
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

  static final Map<String, List<AxleHistoryEntry>> _allHistory = {
    'Coach 4': [
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 4, sensorId: 'AX-C04-A04', maxTemp: '108°C', status: 'Warning',  speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',   date: DateTime(2026, 3, 12, 10, 39)),
    ],
  };

  static const List<Map<String, dynamic>> alerts = [
    {
      'type': 'critical',
      'title': 'Critical: Axle 3 Overheat (Temp 112°C)',
      'coach': 'Coach 7',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 3  |  Sensor: AX-C07-A03  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 6 Overheat (Temp 109°C)',
      'coach': 'Coach 7',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 6  |  Sensor: AX-C07-A06  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 2 Overheat (Temp 108°C)',
      'coach': 'Coach 20',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 2  |  Sensor: AX-C20-A02  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 5 Overheat (Temp 106°C)',
      'coach': 'Coach 20',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 5  |  Sensor: AX-C20-A05  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'warning',
      'title': 'Warning: Axle 4 Overheat (Temp 108°C)',
      'coach': 'Coach 4',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 4  |  Sensor: AX-C04-A04  |  Speed: 72 km/h',
      'note': 'Monitor closely — Location: Near Nagda',
    },
    {
      'type': 'warning',
      'title': 'Warning: Axle 4 Overheat (Temp 98°C)',
      'coach': 'Coach 11',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 4  |  Sensor: AX-C11-A04  |  Speed: 72 km/h',
      'note': 'Monitor closely — Location: Near Nagda',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Critical Overheat',
      'coach': 'Coach 3',
      'time': 'Yesterday, 06:10 AM',
      'detail': 'Axle 2  |  Resolved by: Ramesh Kumar',
      'note': 'Axle cooled and re-lubricated — Normal temperature restored',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Axle Sensor Offline',
      'coach': 'Coach 9',
      'time': '10 Mar, 02:15 PM',
      'detail': 'Axle 6  |  Resolved by: Suresh Singh',
      'note': 'Sensor replaced — Data transmission restored',
    },
  ];

  static Map<String, int> getSummary() => {
    'total': 20, 'good': 16, 'warning': 2, 'critical': 2,
    'totalAxles': 160, 'axlesGood': 153, 'axlesIssue': 7,
  };
}
