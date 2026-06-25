import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/water_tank_model.dart';

class WliDataService {
  final String baseUrl;

  WliDataService({required this.baseUrl});

  Future<List<WaterTankModel>> fetchWliCoaches() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.wliCoachesApiEndpoint}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final List<dynamic> dataList = body['data'] is List ? body['data'] : [];
        return dataList.map((e) => WaterTankModel.fromFlatJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
    throw Exception('Failed to load WLI data: ${response.statusCode}');
  }
}
