import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import '../models/diesel_tank_model.dart';

class DieselDataService {
  final String baseUrl;

  DieselDataService({required this.baseUrl});

  Future<List<DieselHistoryPoint>> fetchDieselHistory(
    String sensorId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (sensorId.isEmpty) return [];
    final uri = Uri.parse('$baseUrl${ApiConstants.dieselHistoryApiEndpoint}')
        .replace(
          queryParameters: {
            'sensor_id': sensorId,
            if (fromDate != null)
              'fromDate': fromDate.toUtc().toIso8601String(),
            if (toDate != null) 'toDate': toDate.toUtc().toIso8601String(),
          },
        );
    final token = GetIt.I<Prefs>().token;
    final response = await http.get(uri, headers: {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => DieselHistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load diesel history: ${response.statusCode}');
  }

  Future<List<DieselTankModel>> fetchDieselReadings({int? coachId}) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.dieselReadingsApiEndpoint}').replace(
      queryParameters: coachId != null ? {'coach_id': coachId.toString()} : null,
    );
    final token = GetIt.I<Prefs>().token;
    final response = await http.get(uri, headers: {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final List<dynamic> dataList = body['data'] is List ? body['data'] : [];
        return dataList.map((e) => DieselTankModel.fromJson(e)).toList();
      }
      return [];
    }
    throw Exception('Failed to load diesel readings: ${response.statusCode}');
  }
}
