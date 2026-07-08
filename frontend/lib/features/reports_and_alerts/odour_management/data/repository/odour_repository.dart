import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/odour_model.dart';

class OdourRepository {
  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      final uri = Uri.parse('${ApiConstants.devUrl}${ApiConstants.odourCoachesApiEndpoint}');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load odour data: ${response.statusCode}');
      }

      final body = json.decode(response.body);
      if (body['success'] != true || body['data'] == null) {
        return [];
      }

      final List<dynamic> rows = body['data'] is List ? body['data'] : [];
<<<<<<< HEAD

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final row in rows) {
        final key = '${row['train_number']}_${row['coach_number']}';
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(row as Map<String, dynamic>);
      }

      final coaches = <OdourCoachModel>[];
      for (final entry in grouped.entries) {
        final coachRows = entry.value;
        final firstRow = coachRows.first;

        final toilets = coachRows.map((row) => ToiletSensor(
          id: row['id']?.toString() ?? '',
          position: row['toilet_position']?.toString() ?? 'N/A',
          vocIndex: (row['voc_index'] ?? 0).toDouble(),
          methanePpm: (row['methane_ppm'] ?? 0).toDouble(),
          h2sPpm: (row['h2s_ppm'] ?? 0).toDouble(),
          nh3Ppm: (row['nh3_ppm'] ?? 0).toDouble(),
          srawVoc: (row['sraw_voc'] ?? 0).toDouble(),
          h2sRaw: (row['h2s_raw'] ?? 0).toDouble(),
          nh3Raw: (row['nh3_raw'] ?? 0).toDouble(),
          temperature: (row['temperature'] ?? 0).toDouble(),
          humidity: (row['humidity'] ?? 0).toDouble(),
          longLockCount: row['long_lock_count'] ?? 0,
          status: row['status']?.toString() ?? 'Active',
        )).toList();

        coaches.add(OdourCoachModel(
          coachNumber: firstRow['coach_number']?.toString() ?? '',
          coachType: firstRow['coach_type']?.toString() ?? 'N/A',
          trainNumber: firstRow['train_number']?.toString() ?? '',
          deviceId: firstRow['device_id']?.toString() ?? '',
          toilets: toilets,
        ));
=======
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (final row in rows) {
        final deviceId = row['device_id'] ?? '';
        grouped.putIfAbsent(deviceId.toString(), () => []);
        grouped[deviceId.toString()]!.add(row as Map<String, dynamic>);
      }

      final positions = [
        'Toilet 1 (Front-Left)',
        'Toilet 2 (Front-Right)',
        'Toilet 3 (Rear-Left)',
        'Toilet 4 (Rear-Right)',
      ];

      final positionMap = <String, String>{
        '1': positions[0],
        '2': positions[1],
        '3': positions[2],
        '4': positions[3],
        'Front-Left': positions[0],
        'Front-Right': positions[1],
        'Rear-Left': positions[2],
        'Rear-Right': positions[3],
        'N/A': positions[0],
      };

      final coaches = <OdourCoachModel>[];
      int coachIndex = 0;

      for (final entry in grouped.entries) {
        final deviceId = entry.key;
        final coachRows = entry.value;
        final firstRow = coachRows.first;

        final coachNumber = firstRow['coach_number']?.toString() ?? 'Coach $coachIndex';
        final coachType = firstRow['coach_type']?.toString() ?? 'N/A';
        final trainNo = firstRow['train_no']?.toString() ?? firstRow['train_number']?.toString() ?? '';
        final trainName = trainNo.isNotEmpty ? 'Train $trainNo' : 'N/A';

        final toilets = <ToiletSensor>[];
        int toiletIdx = 0;

        for (final row in coachRows) {
          final rawPos = row['toilet_position']?.toString() ?? '${toiletIdx + 1}';
          final position = positionMap[rawPos] ?? 'Toilet ${toiletIdx + 1}';
          final reading = (row['odour_reading'] ?? 0).toDouble();
          final isBad = reading > 70;
          final status = row['device_status']?.toString() ?? (isBad ? 'Alert' : 'Active');

          toilets.add(ToiletSensor(
            id: '${deviceId}_T${toiletIdx + 1}',
            position: position,
            reading: reading,
            status: status,
            isRecent: isBad,
          ));
          toiletIdx++;
        }

        coaches.add(OdourCoachModel(
          coachNumber: coachNumber,
          coachType: coachType,
          trainNumber: trainNo,
          trainName: trainName,
          route: 'N/A',
          deviceId: deviceId,
          toilets: toilets,
        ));
        coachIndex++;
>>>>>>> 76f59f6 (fix(android): fix Gradle and AGP versions for Flutter build, add keystore config)
      }

      return coaches;
    } catch (e) {
      throw Exception('Failed to fetch odour data: $e');
    }
  }

  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.devUrl}${ApiConstants.odourReceiveDataApiEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send odour data');
    }
  }
}
