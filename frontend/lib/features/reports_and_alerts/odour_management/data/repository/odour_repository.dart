import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/odour_model.dart';

class OdourRepository {
  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      // For now, we fetch from the receive-data endpoint which might just return the last entries
      // In a real scenario, there would be a 'get' endpoint.
      // Since the user provided a POST endpoint for receiving data, 
      // we'll simulate the GET behavior or use dummy data if the endpoint doesn't support GET.
      
      // Using dummy data for now as per the "formal but mock-backed" step usually followed before full API integration.
      // But I will structure it correctly.
      
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        OdourCoachModel(
          coachNumber: "B1",
          coachType: "3AC",
          toiletPosition: "L-Side-Front",
          status: "Active",
          reading: 85,
          timestamp: DateTime.now().toIso8601String(),
          sensorId: "SENS-001",
          deviceId: "OMD-MASTER-01",
          trainNumber: "12952",
          trainName: "Rajdhani Express",
          route: "NDLS-BCT",
          isRecent: true,
        ),
        OdourCoachModel(
          coachNumber: "B2",
          coachType: "3AC",
          toiletPosition: "R-Side-Rear",
          status: "Inactive",
          reading: 20,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          sensorId: "SENS-002",
          deviceId: "OMD-MASTER-02",
          trainNumber: "12952",
          trainName: "Rajdhani Express",
          route: "NDLS-BCT",
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch odour data: $e');
    }
  }

  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(ApiConstants.odourReceiveDataApiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send odour data');
    }
  }
}
