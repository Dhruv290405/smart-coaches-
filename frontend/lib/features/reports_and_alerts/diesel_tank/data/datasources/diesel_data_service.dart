import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/diesel_tank_model.dart';

class DieselDataService {
  final String baseUrl;

  DieselDataService({required this.baseUrl});

  Future<List<DieselTankModel>> fetchDieselReadings({int? coachId}) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.dieselReadingsApiEndpoint}').replace(
      queryParameters: coachId != null ? {'coach_id': coachId.toString()} : null,
    );
    final response = await http.get(uri);

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
