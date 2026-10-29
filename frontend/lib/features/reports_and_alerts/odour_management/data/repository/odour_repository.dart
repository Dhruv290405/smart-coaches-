import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import '../models/odour_model.dart';

final Logger _log = Logger('OdourRepo');

class OdourRepository {
  static final Map<int, List<OdourCoachModel>> _cacheByUser = {};

  Future<List<OdourCoachModel>> getOdourData() async {
    final results = await Future.wait([
      _fetchFromEndpoint(ApiConstants.odourCoachesApiEndpoint, 'Section 1'),
      _fetchFromEndpoint(ApiConstants.odourSection2ApiEndpoint, 'Section 2'),
    ]);

    final parsed = <OdourCoachModel>[...results[0], ...results[1]];
    try {
      final userId = GetIt.I<Prefs>().userId;
      if (userId != null && parsed.isNotEmpty) {
        _cacheByUser[userId] = List<OdourCoachModel>.unmodifiable(parsed);
      }
    } catch (_) {}
    if (parsed.isNotEmpty) return parsed;

    try {
      final userEmail = GetIt.I<Prefs>().getUser()?.email;
      if (userEmail == 'tester@example.com') return getSampleData();
    } catch (_) {}
    return [];
  }

  Future<List<OdourCoachModel>> _fetchFromEndpoint(
    String endpoint,
    String section,
  ) async {
    try {
      final apiClient = GetIt.I<ApiClient>();
      final response = await apiClient.get(endpoint);

      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        return (response['data'] as List)
            .map(
              (map) =>
                  _buildModelFromBackend(map as Map<String, dynamic>, section),
            )
            .toList();
      }
    } catch (e) {
      _log.warn('$endpoint unavailable ($e).');
    }
    return [];
  }

  Stream<List<OdourCoachModel>> watchOdourData() async* {
    try {
      final cached = _cacheByUser[GetIt.I<Prefs>().userId];
      if (cached != null && cached.isNotEmpty) yield cached;
    } catch (_) {}

    while (true) {
      try {
        final combined = <OdourCoachModel>[];
        final section1 = _fetchFromEndpoint(
          ApiConstants.odourCoachesApiEndpoint,
          'Section 1',
        );
        final section2 = _fetchFromEndpoint(
          ApiConstants.odourSection2ApiEndpoint,
          'Section 2',
        );

        final first = await section1;
        combined.addAll(first);
        if (combined.isNotEmpty) yield List.unmodifiable(combined);

        final second = await section2;
        combined.addAll(second);
        yield List.unmodifiable(combined);

        final userId = GetIt.I<Prefs>().userId;
        if (userId != null && combined.isNotEmpty) {
          _cacheByUser[userId] = List<OdourCoachModel>.unmodifiable(combined);
        }
      } catch (e) {
        _log.warn('Poll error: $e');
      }
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  OdourCoachModel _buildModelFromBackend(
    Map<String, dynamic> data, [
    String section = 'Section 1',
  ]) {
    double d(dynamic v, [double def = 0.0]) => v == null
        ? def
        : (v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? def));
    int i(dynamic v, [int def = 0]) => v == null
        ? def
        : (v is num ? v.toInt() : (int.tryParse(v.toString()) ?? def));
    String s(dynamic v, [String def = 'N/A']) => v?.toString() ?? def;

    final vocVal = d(data['voc_index'] ?? data['voc']);
    final h2sVal = d(data['h2s_ppm'] ?? data['h2s']);
    final nh3Val = d(data['nh3_ppm'] ?? data['nh3']);

    return OdourCoachModel(
      coachNumber: s(data['coach_number'] ?? data['device_id']),
      section: section,
      coachType: s(data['coach_type'], 'Unknown'),
      toiletPosition: s(data['toilet_position']),
      status: s(data['status'], 'Active'),
      reading: vocVal,
      timestamp: s(
        data['timestamp_device'] ??
            data['created_at'] ??
            data['last_updated'] ??
            data['timestamp'],
        DateTime.now().toIso8601String(),
      ),
      sensorId: s(data['sensor_id'], 'SENS-??'),
      deviceId: s(data['device_id'], 'OMD-??'),
      trainNumber: s(data['train_number'], '--'),
      trainName: s(data['train_name'], '--'),
      route: s(data['route'], '--'),
      isRecent: true,
      voc: vocVal,
      h2s: h2sVal,
      nh3: nh3Val,
      smoke: d(data['smoke']),
      temperature: d(data['temperature']),
      humidity: d(data['humidity']),
      address: s(data['address'], 'Unknown'),
      doorStatus: s(data['door_status'], 'Closed'),
      doorOpenEventsToday: i(
        data['door_open_events_today'] ?? data['long_lock_count'],
      ),
      uCount: i(data['u_count']),
      fCount: i(data['f_count']),
      lastOpenedTime: s(data['last_opened_time'], 'N/A'),
      lastClosedTime: s(data['last_closed_time'], 'N/A'),
      totalDoorCyclesToday: i(data['total_door_cycles_today']),
      averageOpenDuration: s(data['average_open_duration'], 'N/A'),
      longestOpenDuration: s(data['longest_open_duration'], 'N/A'),
      serverHygieneScore: data['hygiene_score'] != null
          ? d(data['hygiene_score'])
          : null,
      serverVocStatus: data['voc_status']?.toString(),
      serverNh3Status: data['nh3_status']?.toString(),
      serverH2sStatus: data['h2s_status']?.toString(),
      serverSmokeStatus: data['smoke_status']?.toString(),
      serverTempStatus: data['temp_status']?.toString(),
      serverHumStatus: data['hum_status']?.toString(),
    );
  }

  List<OdourCoachModel> getSampleData() {
    return [
      OdourCoachModel(
        coachNumber: "B1",
        coachType: "3AC",
        toiletPosition: "Toilet-1-Front-Left",
        status: "Active",
        reading: 950.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-001",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 950.0,
        h2s: 0.08,
        nh3: 0.8,
        smoke: 6.5,
        temperature: 32.5,
        humidity: 65.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 142,
        lastOpenedTime: "14:45",
        lastClosedTime: "14:47",
        totalDoorCyclesToday: 142,
        averageOpenDuration: "2 mins",
        longestOpenDuration: "8 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Closed", "time": "14:47"},
          {"event": "Door Opened", "time": "14:45"},
          {"event": "Door Closed", "time": "14:15"},
          {"event": "Door Opened", "time": "14:12"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "B1",
        coachType: "3AC",
        toiletPosition: "Toilet-2-Front-Right",
        status: "Active",
        reading: 450.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-002",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 450.0,
        h2s: 0.02,
        nh3: 0.1,
        smoke: 2.5,
        temperature: 30.5,
        humidity: 60.0,
        doorStatus: "Open",
        doorOpenEventsToday: 89,
        lastOpenedTime: "14:55",
        lastClosedTime: "14:20",
        totalDoorCyclesToday: 89,
        averageOpenDuration: "3 mins",
        longestOpenDuration: "12 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Opened", "time": "14:55"},
          {"event": "Door Closed", "time": "14:20"},
          {"event": "Door Opened", "time": "14:15"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "B2",
        coachType: "3AC",
        toiletPosition: "Toilet-3-Rear-Left",
        status: "Inactive",
        reading: 120.0,
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        sensorId: "SENS-003",
        deviceId: "OMD-MASTER-02",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        voc: 120.0,
        h2s: 0.01,
        nh3: 0.05,
        smoke: 1.2,
        temperature: 28.0,
        humidity: 50.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 22,
        lastOpenedTime: "12:45",
        lastClosedTime: "12:47",
        totalDoorCyclesToday: 22,
        averageOpenDuration: "5 mins",
        longestOpenDuration: "15 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Closed", "time": "12:47"},
          {"event": "Door Opened", "time": "12:45"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "A1",
        coachType: "2AC",
        toiletPosition: "Toilet-1-Front-Left",
        status: "Active",
        reading: 710.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-004",
        deviceId: "OMD-MASTER-03",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 710.0,
        h2s: 0.06,
        nh3: 0.5,
        smoke: 4.0,
        temperature: 31.0,
        humidity: 58.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 67,
        lastOpenedTime: "14:30",
        lastClosedTime: "14:33",
        totalDoorCyclesToday: 67,
        averageOpenDuration: "2 mins",
        longestOpenDuration: "7 mins",
      ),
      OdourCoachModel(
        coachNumber: "C1",
        coachType: "CC",
        toiletPosition: "Toilet-1-Front",
        status: "Active",
        reading: 380.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-005",
        deviceId: "OMD-MASTER-04",
        trainNumber: "12002",
        trainName: "Shatabdi Express",
        route: "NDLS-HBJ",
        isRecent: true,
        voc: 380.0,
        h2s: 0.03,
        nh3: 0.15,
        smoke: 2.0,
        temperature: 29.5,
        humidity: 55.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 54,
        lastOpenedTime: "14:10",
        lastClosedTime: "14:12",
        totalDoorCyclesToday: 54,
        averageOpenDuration: "1 min",
        longestOpenDuration: "5 mins",
      ),
      // Section 2 sample coaches (tester demo) so both sections are visible
      OdourCoachModel(
        coachNumber: "B1",
        section: "Section 2",
        coachType: "3AC",
        toiletPosition: "Toilet-2-Front-Right",
        status: "Active",
        reading: 420.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-002",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 420.0,
        h2s: 0.04,
        nh3: 0.3,
        smoke: 3.0,
        temperature: 30.0,
        humidity: 60.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 67,
        lastOpenedTime: "14:30",
        lastClosedTime: "14:33",
        totalDoorCyclesToday: 67,
        averageOpenDuration: "2 mins",
        longestOpenDuration: "7 mins",
      ),
      OdourCoachModel(
        coachNumber: "S2",
        section: "Section 2",
        coachType: "Sleeper",
        toiletPosition: "Toilet-4-Rear-Right",
        status: "Active",
        reading: 380.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-008",
        deviceId: "OMD-MASTER-06",
        trainNumber: "12627",
        trainName: "Karnataka Express",
        route: "SBC-NDLS",
        isRecent: true,
        voc: 380.0,
        h2s: 0.03,
        nh3: 0.15,
        smoke: 2.0,
        temperature: 29.5,
        humidity: 55.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 54,
        lastOpenedTime: "14:10",
        lastClosedTime: "14:12",
        totalDoorCyclesToday: 54,
        averageOpenDuration: "1 min",
        longestOpenDuration: "5 mins",
      ),
    ];
  }

  Future<List<OdourHistoryPoint>> getOdourHistory(
    String deviceId,
    String section,
  ) async {
    try {
      final apiClient = GetIt.I<ApiClient>();
      final response = await apiClient.get(
        ApiConstants.odourHistoryApiEndpoint,
        queryParams: {'deviceId': deviceId, 'section': section},
      );
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        return (response['data'] as List)
            .map((e) => OdourHistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _log.warn('Odour history unavailable ($e).');
    }
    return [];
  }

  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final dbPayload = {
      "device_id": payload['source']?['deviceId'] ?? 'Unknown',
      "timestamp_device":
          payload['coach_data']?['timestamp'] ??
          DateTime.now().toIso8601String(),
      "temperature": payload['coach_data']?['temperature'] ?? 0.0,
      "humidity": payload['coach_data']?['humidity'] ?? 0.0,
      "voc_index": (payload['coach_data']?['voc'] ?? 0.0).toInt(),
      "methane_ppm": payload['coach_data']?['methane_ppm'] ?? 0.0,
      "h2s_ppm": payload['coach_data']?['h2s'] ?? 0.0,
      "nh3_ppm": payload['coach_data']?['nh3'] ?? 0.0,
      "long_lock_count": payload['coach_data']?['door_events_today'] ?? 0,
    };

    try {
      final apiClient = GetIt.I<ApiClient>();
      await apiClient.post(ApiConstants.odourReceiveDataApiEndpoint, dbPayload);
    } catch (e) {
      _log.warn('sendOdourData failed: $e');
    }
  }
}
