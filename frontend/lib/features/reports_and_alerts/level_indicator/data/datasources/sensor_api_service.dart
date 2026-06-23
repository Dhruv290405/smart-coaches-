import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/sensor_data.dart';

class SensorApiService {
  final String baseUrl;

  SensorApiService({required this.baseUrl});

  Future<SensorData> fetchSensorData(String sensorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/iot_water_level/get_water_level_data?sensor_id=$sensorId'),
    );

    print("response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("data: $data");
      return SensorData.fromJson(data['data']);
    } else {
      throw Exception("Failed to load sensor data");
    }
  }
}
