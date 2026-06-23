import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';

class AcpDummyData {
  static const String trainName = '12615/6 Grand Trunk Express';
  static const String trainNumber = '12615/6 Grand Tr...';
  static const String lastUpdated = '10:46 AM';

  static const List<int> offCoachIds = [4, 7, 11, 20];

  static List<AcpCoachModel> generateCoaches() {
    return List.generate(20, (index) {
      final id = index + 1;
      final isOff = offCoachIds.contains(id);
      final coachCode = 'C${id.toString().padLeft(2, '0')}';
      return AcpCoachModel(
        coachNumber: 'Coach $id',
        status: isOff ? 'OFF' : 'ON',
        updateTime: isOff ? '10:42 AM' : '${(index % 15) + 1}m ago',
        isChainPulled: isOff,
        sensorId: 'ACP-B5-${id.toString().padLeft(2, '0')}',
        lastPull: isOff ? '10:42 AM' : '09:15 AM',
        reset: isOff ? 'Not done' : 'Done',
        trainSpeed: '${55 + (index * 3) % 30} km/h',
        location: _locations[index % _locations.length],
      );
    });
  }

  static const List<String> _locations = [
    'Ratlam', 'Ujjain', 'Bhopal', 'Itarsi', 'Nagpur',
    'Noida', 'Agra', 'Mathura', 'Delhi', 'Gwalior',
  ];

  static List<AcpHistoryEntry> getHistory(String coachNumber, String period, {DateTime? from, DateTime? to}) {
    final now = DateTime(2026, 3, 12);
    final allEntries = _allHistory[coachNumber] ?? _defaultHistory(coachNumber);

    DateTime cutoff;
    if (period == '7 Days') {
      cutoff = now.subtract(const Duration(days: 7));
    } else if (period == '30 Days') {
      cutoff = now.subtract(const Duration(days: 30));
    } else if (period == 'Custom' && from != null && to != null) {
      return allEntries.where((e) =>
      !e.date.isBefore(from) && !e.date.isAfter(to.add(const Duration(days: 1)))
      ).toList();
    } else {
      cutoff = now.subtract(const Duration(days: 1));
    }

    return allEntries.where((e) => e.date.isAfter(cutoff)).toList();
  }

  static List<AcpHistoryEntry> _defaultHistory(String coachNumber) {
    final id = int.tryParse(coachNumber.replaceAll('Coach ', '')) ?? 1;
    return [
      AcpHistoryEntry(
        sensorId: 'ACP-B5-${id.toString().padLeft(2, '0')}',
        lastPull: 'Today | 10:42 AM',
        reset: 'Not done',
        trainSpeed: '62 km/h',
        location: 'Ratlam',
        date: DateTime(2026, 3, 12, 10, 42),
      ),
    ];
  }

  static final Map<String, List<AcpHistoryEntry>> _allHistory = {
    'Coach 4': [
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: 'Today | 10:42 AM', reset: 'Not done', trainSpeed: '62 km/h', location: 'Ratlam', date: DateTime(2026, 3, 12, 10, 42)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: 'Yesterday | 08:15 AM', reset: 'Done', trainSpeed: '71 km/h', location: 'Ujjain', date: DateTime(2026, 3, 11, 8, 15)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: '10 Mar | 02:30 PM', reset: 'Done', trainSpeed: '58 km/h', location: 'Bhopal', date: DateTime(2026, 3, 10, 14, 30)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: '08 Mar | 11:45 AM', reset: 'Done', trainSpeed: '65 km/h', location: 'Itarsi', date: DateTime(2026, 3, 8, 11, 45)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: '05 Mar | 06:20 AM', reset: 'Done', trainSpeed: '73 km/h', location: 'Nagpur', date: DateTime(2026, 3, 5, 6, 20)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: '20 Feb | 03:10 PM', reset: 'Done', trainSpeed: '60 km/h', location: 'Agra', date: DateTime(2026, 2, 20, 15, 10)),
      AcpHistoryEntry(sensorId: 'ACP-B5-04', lastPull: '04 Feb | 10:42 AM', reset: 'Done', trainSpeed: '73 km/h', location: 'Ratlam', date: DateTime(2026, 2, 4, 10, 42)),
    ],
    'Coach 7': [
      AcpHistoryEntry(sensorId: 'ACP-B5-07', lastPull: 'Today | 10:42 AM', reset: 'Not done', trainSpeed: '55 km/h', location: 'Ratlam', date: DateTime(2026, 3, 12, 10, 42)),
      AcpHistoryEntry(sensorId: 'ACP-B5-07', lastPull: '09 Mar | 04:00 PM', reset: 'Done', trainSpeed: '68 km/h', location: 'Gwalior', date: DateTime(2026, 3, 9, 16, 0)),
      AcpHistoryEntry(sensorId: 'ACP-B5-07', lastPull: '01 Mar | 09:30 AM', reset: 'Done', trainSpeed: '72 km/h', location: 'Noida', date: DateTime(2026, 3, 1, 9, 30)),
      AcpHistoryEntry(sensorId: 'ACP-B5-07', lastPull: '15 Feb | 07:45 AM', reset: 'Done', trainSpeed: '61 km/h', location: 'Delhi', date: DateTime(2026, 2, 15, 7, 45)),
    ],
    'Coach 11': [
      AcpHistoryEntry(sensorId: 'ACP-B5-11', lastPull: 'Today | 10:42 AM', reset: 'Not done', trainSpeed: '67 km/h', location: 'Ratlam', date: DateTime(2026, 3, 12, 10, 42)),
      AcpHistoryEntry(sensorId: 'ACP-B5-11', lastPull: '11 Mar | 01:15 PM', reset: 'Done', trainSpeed: '74 km/h', location: 'Mathura', date: DateTime(2026, 3, 11, 13, 15)),
      AcpHistoryEntry(sensorId: 'ACP-B5-11', lastPull: '06 Mar | 11:00 AM', reset: 'Done', trainSpeed: '59 km/h', location: 'Agra', date: DateTime(2026, 3, 6, 11, 0)),
      AcpHistoryEntry(sensorId: 'ACP-B5-11', lastPull: '25 Feb | 08:30 AM', reset: 'Done', trainSpeed: '66 km/h', location: 'Bhopal', date: DateTime(2026, 2, 25, 8, 30)),
      AcpHistoryEntry(sensorId: 'ACP-B5-11', lastPull: '10 Feb | 05:45 PM', reset: 'Done', trainSpeed: '70 km/h', location: 'Itarsi', date: DateTime(2026, 2, 10, 17, 45)),
    ],
    'Coach 20': [
      AcpHistoryEntry(sensorId: 'ACP-B5-20', lastPull: 'Today | 10:42 AM', reset: 'Not done', trainSpeed: '78 km/h', location: 'Ratlam', date: DateTime(2026, 3, 12, 10, 42)),
      AcpHistoryEntry(sensorId: 'ACP-B5-20', lastPull: '07 Mar | 02:45 PM', reset: 'Done', trainSpeed: '63 km/h', location: 'Ujjain', date: DateTime(2026, 3, 7, 14, 45)),
      AcpHistoryEntry(sensorId: 'ACP-B5-20', lastPull: '28 Feb | 10:00 AM', reset: 'Done', trainSpeed: '69 km/h', location: 'Nagpur', date: DateTime(2026, 2, 28, 10, 0)),
    ],
  };

  static List<MapEntry<String, bool>> getBarData(String period) {
    if (period == '7 Days') {
      return const [
        MapEntry('C04', false), MapEntry('C07', false), MapEntry('C11', false), MapEntry('C20', false),
        MapEntry('C01', true), MapEntry('C02', true), MapEntry('C03', true),
      ];
    } else if (period == '30 Days') {
      return const [
        MapEntry('C04', false), MapEntry('C07', false), MapEntry('C11', false), MapEntry('C20', false),
        MapEntry('C03', false), MapEntry('C08', false), MapEntry('C15', false),
        MapEntry('C01', true), MapEntry('C02', true), MapEntry('C05', true),
      ];
    } else {
      // Live
      return const [
        MapEntry('C01', true), MapEntry('C02', true), MapEntry('C03', true),
        MapEntry('C04', false), MapEntry('C05', true), MapEntry('C06', true),
        MapEntry('C07', false),
      ];
    }
  }

  static Map<String, int> getSummary(String period) {
    if (period == '30 Days') return {'total': 20, 'on': 13, 'off': 7};
    if (period == '7 Days') return {'total': 20, 'on': 16, 'off': 4};
    return {'total': 20, 'on': 16, 'off': 4};
  }

  static const List<Map<String, dynamic>> alerts = [
    {
      'type': 'emergency',
      'title': 'Emergency: Chain Pulled',
      'coach': 'Coach 20',
      'time': 'Today, 10:42 AM',
      'location': 'Ratlam Section',
      'reset': 'Not Reset',
    },
    {
      'type': 'emergency',
      'title': 'Emergency: Chain Pulled',
      'coach': 'Coach 11',
      'time': 'Today, 10:42 AM',
      'location': 'Ratlam Section',
      'reset': 'Not Reset',
    },
    {
      'type': 'emergency',
      'title': 'Emergency: Chain Pulled',
      'coach': 'Coach 7',
      'time': 'Today, 10:42 AM',
      'location': 'Ratlam Section',
      'reset': 'Not Reset',
    },
    {
      'type': 'emergency',
      'title': 'Emergency: Chain Pulled',
      'coach': 'Coach 4',
      'time': 'Today, 10:42 AM',
      'location': 'Ratlam Section',
      'reset': 'Not Reset',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: False Chain Pull',
      'coach': 'Coach 3',
      'time': 'Yesterday, 06:10 AM',
      'location': 'Ujjain Section',
      'resolvedBy': 'Ramesh Kumar',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: False Chain Pull',
      'coach': 'Coach 8',
      'time': '10 Mar, 02:15 PM',
      'location': 'Bhopal Section',
      'resolvedBy': 'Suresh Singh',
    },
  ];
}