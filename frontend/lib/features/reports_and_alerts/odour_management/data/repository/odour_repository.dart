import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import '../models/odour_model.dart';

final Logger _log = Logger('OdourRepo');

class OdourRepository {
  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      final apiClient = GetIt.I<ApiClient>();
      final response = await apiClient.get(ApiConstants.odourCoachesApiEndpoint);

      if (response is Map && response['success'] == true && response['data'] is List) {
        final parsed = (response['data'] as List)
            .map((map) => _buildModelFromBackend(map as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (e) {
      _log.warn('Backend unavailable ($e), using sample data.');
    }

    try {
      final userEmail = GetIt.I<Prefs>().getUser()?.email;
      if (userEmail == 'tester@example.com') return getSampleData();
    } catch (_) {}
    return [];
  }

  Stream<List<OdourCoachModel>> watchOdourData() async* {
    bool isTester = false;
    try {
      isTester = GetIt.I<Prefs>().getUser()?.email == 'tester@example.com';
    } catch (_) {}
    if (isTester) yield getSampleData();

    while (true) {
      try {
        final data = await getOdourData();
        yield data;
      } catch (e) {
        _log.warn('Poll error: $e');
      }
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  OdourCoachModel _buildModelFromBackend(Map<String, dynamic> data) {
    double _d(dynamic v, [double def = 0.0]) =>
        (v as num?)?.toDouble() ?? def;
    int _i(dynamic v, [int def = 0]) => (v as num?)?.toInt() ?? def;
    String _s(dynamic v, [String def = 'N/A']) =>
        v?.toString() ?? def;

    final vocVal = _d(data['voc_index'] ?? data['voc']);
    final h2sVal = _d(data['h2s_ppm'] ?? data['h2s']);
    final nh3Val = _d(data['nh3_ppm'] ?? data['nh3']);

    return OdourCoachModel(
      coachNumber: _s(data['coach_number'] ?? data['device_id']),
      coachType: _s(data['coach_type'], 'Unknown'),
      toiletPosition: _s(data['toilet_position']),
      status: _s(data['status'], 'Active'),
      reading: vocVal,
      timestamp: _s(data['timestamp_device'] ?? data['created_at'] ?? data['last_updated'] ?? data['timestamp'], DateTime.now().toIso8601String()),
      sensorId: _s(data['sensor_id'], 'SENS-??'),
      deviceId: _s(data['device_id'], 'OMD-??'),
      trainNumber: _s(data['train_number'], '--'),
      trainName: _s(data['train_name'], '--'),
      route: _s(data['route'], '--'),
      isRecent: true,
      voc: vocVal,
      h2s: h2sVal,
      nh3: nh3Val,
      smoke: _d(data['smoke']),
      temperature: _d(data['temperature']),
      humidity: _d(data['humidity']),
      address: _s(data['address'], 'Unknown'),
      doorStatus: _s(data['door_status'], 'Closed'),
      doorOpenEventsToday: _i(data['door_open_events_today'] ?? data['long_lock_count']),
      uCount: _i(data['u_count']),
      fCount: _i(data['f_count']),
      lastOpenedTime: _s(data['last_opened_time'], 'N/A'),
      lastClosedTime: _s(data['last_closed_time'], 'N/A'),
      totalDoorCyclesToday: _i(data['total_door_cycles_today']),
      averageOpenDuration: _s(data['average_open_duration'], 'N/A'),
      longestOpenDuration: _s(data['longest_open_duration'], 'N/A'),
      serverHygieneScore: data['hygiene_score'] != null ? _d(data['hygiene_score']) : null,
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
    ];
  }

  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final dbPayload = {
      "device_id": payload['source']?['deviceId'] ?? 'Unknown',
      "timestamp_device": payload['coach_data']?['timestamp'] ?? DateTime.now().toIso8601String(),
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