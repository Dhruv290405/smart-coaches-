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
